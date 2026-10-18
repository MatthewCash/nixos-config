#!/usr/bin/env python3

import sys
import threading

import pulsectl
import rtmidi
from PySide6.QtCore import QEvent, QObject, Qt, QTimer, Signal
from PySide6.QtGui import QColor, QFont, QPalette
from PySide6.QtWidgets import QApplication, QFrame, QHBoxLayout, QLabel, QProxyStyle, QSizePolicy, QSlider, QStyle, QVBoxLayout, QWidget


FADERS = [
    ("sink", "games", "Games"),
    ("piano", "piano", "Piano"),
    ("sink", "media", "Media"),
    ("sink", "voice", "Voice"),
]

APP_ID = "channel-mixer"
APP_NAME = "Channel Mixer"
FONT_FAMILY = "Aurebesh"

COMMIT_DELAY_MS = 35
ANIMATION_INTERVAL_MS = 16
REFRESH_DELAY_MS = 25
WINDOW_WIDTH = 620
WINDOW_HEIGHT = 600
SLIDER_MIN_WIDTH = 92
SLIDER_MIN_HEIGHT = 120
SLIDER_HORIZONTAL_MARGIN = 6
MIXER_SPACING = 9
LABEL_VERTICAL_PADDING = 16
PIANO_DEFAULT_VOLUME = 60
PIANO_MIDI_OUTPUT_MATCH = "smk25"
PIANO_VOLUME_CC = 7
# MIDI dial -> piano volume.
# Fix for min/max sticking: configure the SMK25V2 knob in the 25KEY editor as
# relative/endless (CC 20, channel 1, Left=0, Right=1) so it sends 0 (CCW) or
# 1 (CW) per click with no endpoints. Absolute 0-127 mode always gets stuck
# at the ends because the hardware stops sending events there.
PIANO_MIDI_INPUT_MATCH = "SMK25V2"
PIANO_DIAL_CC = 20
PIANO_DIAL_CHANNEL = 0
PIANO_DIAL_RELATIVE = True
PIANO_DIAL_STEP = 1
MIDI_RECONNECT_MS = 1000
MELODIC_CHANNELS = [channel for channel in range(16) if channel != 9]


class LargeSliderStyle(QProxyStyle):
    def pixelMetric(self, metric, option=None, widget=None):
        value = super().pixelMetric(metric, option, widget)
        if metric == QStyle.PixelMetric.PM_SliderThickness:
            return round(value * 2.0)
        if metric == QStyle.PixelMetric.PM_SliderLength:
            return round(value * 1.8)
        return value


class PulseEvents(QObject):
    changed = Signal()
    piano_volume_changed = Signal(int)


def single_shot_timer(parent, timeout):
    timer = QTimer(parent)
    timer.setSingleShot(True)
    timer.timeout.connect(timeout)
    return timer


class PulseBackend:
    def __init__(self, events):
        self.events = events
        self.pulse = pulsectl.Pulse("pw-bus-mixer")
        self.midi_out = None
        self.midi_output_port = None
        self.midi_in = None
        self.midi_in_port = None
        self.last_dial_value = None
        self.piano_volume = PIANO_DEFAULT_VOLUME
        self.event_pulse = None
        self.stop_event = threading.Event()
        self.event_thread = threading.Thread(target=self.listen, daemon=True)
        self.event_thread.start()

    def list_sinks(self):
        try:
            return {
                sink.name: (sink, min(round(sink.volume.value_flat * 100), 100), bool(sink.mute))
                for sink in self.pulse.sink_list()
            }
        except pulsectl.PulseError:
            return {}

    def set_volume(self, sink, value):
        try:
            self.pulse.volume_set_all_chans(sink, value / 100)
        except pulsectl.PulseError:
            pass

    def adjust_volume(self, sink, offset):
        try:
            self.pulse.volume_change_all_chans(sink, offset / 100)
        except pulsectl.PulseError:
            pass

    def toggle_mute(self, sink):
        try:
            current = next(candidate for candidate in self.pulse.sink_list() if candidate.name == sink.name)
            self.pulse.mute(current, not bool(current.mute))
        except (StopIteration, pulsectl.PulseError):
            pass

    def find_piano_output_port(self):
        # NOTE: every rtmidi.MidiIn/MidiOut construction opens a kernel
        # ALSA sequencer client that is only released by delete(). The
        # enumerator below must always be deleted, otherwise each call
        # permanently leaks one client until "Cannot allocate memory"
        # wedges all MIDI on the system.
        enumerator = None
        try:
            enumerator = rtmidi.MidiOut()
            ports = enumerator.get_ports()
        except Exception:
            return None
        finally:
            if enumerator is not None:
                try:
                    enumerator.delete()
                except Exception:
                    pass
        for index, port in enumerate(ports):
            if port.startswith(f"{PIANO_MIDI_OUTPUT_MATCH}:{PIANO_MIDI_OUTPUT_MATCH} "):
                return index, port
        return None

    def connect_piano(self):
        if self.midi_out is not None:
            try:
                if self.midi_output_port in self.midi_out.get_ports():
                    return True
            except rtmidi.RtMidiError:
                pass

        self.close_piano()
        candidate = self.find_piano_output_port()
        if candidate is None:
            return False

        try:
            self.midi_out = rtmidi.MidiOut()
            self.midi_out.open_port(candidate[0])
            self.midi_output_port = candidate[1]
            return True
        except rtmidi.RtMidiError:
            self.close_piano()
            return False

    def set_piano_volume(self, volume):
        self.piano_volume = max(0, min(100, volume))
        if not self.connect_piano():
            return

        midi_value = round(self.piano_volume * 127 / 100)
        midi_out = self.midi_out
        if midi_out is None:
            return

        try:
            for channel in MELODIC_CHANNELS:
                midi_out.send_message([0xB0 | channel, PIANO_VOLUME_CC, midi_value])
        except rtmidi.RtMidiError:
            self.close_piano()

    def close_piano(self):
        if self.midi_out is not None:
            try:
                self.midi_out.close_port()
            except rtmidi.RtMidiError:
                pass
            try:
                if not self.midi_out.is_deleted:
                    self.midi_out.delete()
            except rtmidi.RtMidiError:
                pass
        self.midi_out = None
        self.midi_output_port = None

    def find_piano_input_port(self):
        # See find_piano_output_port: the enumerator must be delete()d.
        enumerator = None
        try:
            enumerator = rtmidi.MidiIn()
            ports = enumerator.get_ports()
        except Exception:
            return None
        finally:
            if enumerator is not None:
                try:
                    enumerator.delete()
                except Exception:
                    pass
        for index, port in enumerate(ports):
            if PIANO_MIDI_INPUT_MATCH.lower() in port.lower():
                return index, port
        return None

    def ensure_midi_input(self):
        if self.midi_in is not None:
            try:
                if self.midi_in_port in self.midi_in.get_ports():
                    return True
            except rtmidi.RtMidiError:
                pass
            self.close_midi_input()

        candidate = self.find_piano_input_port()
        if candidate is None:
            return False

        try:
            self.midi_in = rtmidi.MidiIn()
            self.midi_in.ignore_types(sysex=False, timing=True, active_sense=True)
            self.midi_in.open_port(candidate[0])
            self.midi_in_port = candidate[1]
            self.midi_in.set_callback(self.handle_midi_message)
            self.last_dial_value = None
            return True
        except rtmidi.RtMidiError:
            self.close_midi_input()
            return False

    def handle_midi_message(self, event, data=None):
        message, _delta = event
        if len(message) < 3:
            return
        status, cc_num, cc_val = message[0], message[1], message[2]
        if status & 0xF0 != 0xB0:
            return
        if (status & 0x0F) != PIANO_DIAL_CHANNEL:
            return
        if cc_num != PIANO_DIAL_CC:
            return

        # Relative/endless mode: each message is one click, 0 = CCW (-step),
        # >=1 = CW (+step). No endpoints, never snaps, mixes with mouse.
        if PIANO_DIAL_RELATIVE:
            step = -PIANO_DIAL_STEP if cc_val == 0 else PIANO_DIAL_STEP
            volume = max(0, min(100, self.piano_volume + step))
            if volume == self.piano_volume:
                return
            self.set_piano_volume(volume)
            try:
                self.events.piano_volume_changed.emit(volume)
            except RuntimeError:
                pass
            return

        # Absolute fallback: apply dial movement as a delta to the current
        # volume instead of snapping to the dial's absolute position. This
        # avoids sharp jumps when the volume was changed with the mouse.
        # NOTE: absolute mode still gets stuck at 0/127 since the hardware
        # stops sending events at the ends; prefer relative mode above.
        if self.last_dial_value is None:
            self.last_dial_value = cc_val
            return

        delta_raw = cc_val - self.last_dial_value
        self.last_dial_value = cc_val
        if delta_raw == 0:
            return
        # Endless-encoder wrap: 127 -> 0 is +1, 0 -> 127 is -1.
        if delta_raw < -64:
            delta_raw += 128
        elif delta_raw > 64:
            delta_raw -= 128

        step = round(delta_raw * 100 / 127)
        if step == 0:
            step = 1 if delta_raw > 0 else -1

        volume = max(0, min(100, self.piano_volume + step))
        if volume == self.piano_volume:
            return
        self.set_piano_volume(volume)
        try:
            self.events.piano_volume_changed.emit(volume)
        except RuntimeError:
            pass

    def close_midi_input(self):
        if self.midi_in is not None:
            try:
                self.midi_in.cancel_callback()
            except rtmidi.RtMidiError:
                pass
            try:
                self.midi_in.close_port()
            except rtmidi.RtMidiError:
                pass
            try:
                if not self.midi_in.is_deleted:
                    self.midi_in.delete()
            except rtmidi.RtMidiError:
                pass
        self.midi_in = None
        self.midi_in_port = None
        self.last_dial_value = None

    def listen(self):
        while not self.stop_event.is_set():
            try:
                self.event_pulse = pulsectl.Pulse("pw-bus-mixer-events")
                self.event_pulse.event_mask_set("sink")
                self.event_pulse.event_callback_set(lambda _event: self.events.changed.emit())
                self.event_pulse.event_listen()
            except pulsectl.PulseError:
                if not self.stop_event.wait(0.5):
                    self.events.changed.emit()
            finally:
                if self.event_pulse is not None:
                    try:
                        self.event_pulse.close()
                    except pulsectl.PulseError:
                        pass
                    self.event_pulse = None

    def close(self):
        self.stop_event.set()
        if self.event_pulse is not None:
            try:
                self.event_pulse.event_listen_stop()
            except pulsectl.PulseError:
                pass
        self.event_thread.join(timeout=1)
        try:
            self.pulse.close()
        except pulsectl.PulseError:
            pass
        self.close_midi_input()
        self.close_piano()


def bus_slider():
    slider = QSlider(Qt.Orientation.Vertical)
    slider.setRange(0, 100)
    slider.setSingleStep(1)
    slider.setPageStep(5)
    slider.setTracking(True)
    slider.setMinimumSize(SLIDER_MIN_WIDTH, SLIDER_MIN_HEIGHT)
    slider.setSizePolicy(QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Expanding)
    return slider


class SinkSlider(QFrame):
    def __init__(self, kind, target, label, backend):
        super().__init__()
        self.kind = kind
        self.target = target
        self.backend = backend
        self.sink_info = None
        self.is_muted = False
        self.dragging = False
        self.has_volume = False
        self.animation_target = None
        self.pending_volume = None
        self.setFrameShape(QFrame.Shape.NoFrame)

        self.title = QLabel(label[:4])
        self.title.setObjectName("title")
        self.title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        title_font = self.title.font()
        title_font.setFamily(FONT_FAMILY)
        title_font.setPointSize(15)
        title_font.setBold(True)
        self.title.setFont(title_font)
        self.title.setMinimumHeight(self.title.fontMetrics().height() + (LABEL_VERTICAL_PADDING * 2))

        self.value_label = QLabel("--")
        self.value_label.setObjectName("value")
        self.value_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        value_font = QFont(FONT_FAMILY)
        value_font.setStyleHint(QFont.StyleHint.Monospace)
        value_font.setPointSize(14)
        value_font.setBold(True)
        self.value_label.setFont(value_font)
        self.value_label.setMinimumHeight(self.value_label.fontMetrics().height() + (LABEL_VERTICAL_PADDING * 2))

        self.slider = bus_slider()
        self.styled_widgets = (self, self.title, self.value_label, self.slider)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(SLIDER_HORIZONTAL_MARGIN, 9, SLIDER_HORIZONTAL_MARGIN, 9)
        layout.setSpacing(8)
        layout.addWidget(self.title, alignment=Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(self.slider, 1, alignment=Qt.AlignmentFlag.AlignHCenter)
        layout.addWidget(self.value_label, alignment=Qt.AlignmentFlag.AlignCenter)

        for widget in self.styled_widgets:
            widget.installEventFilter(self)

        self.commit_timer = single_shot_timer(self, self.commit_volume)

        self.animation_timer = QTimer(self)
        self.animation_timer.timeout.connect(self.animate_volume)

        self.slider.valueChanged.connect(self.changed)

    def set_value_from_box_position(self, position):
        groove = self.slider.geometry()
        top = groove.top()
        bottom = groove.bottom()
        y = max(top, min(bottom, position.y()))
        ratio = (bottom - y) / max(1, bottom - top)
        value = round(self.slider.minimum() + ratio * (self.slider.maximum() - self.slider.minimum()))
        self.slider.setValue(value)

    def box_position_from_event(self, event):
        return self.mapFromGlobal(event.globalPosition().toPoint())

    def eventFilter(self, watched, event):
        event_type = event.type()
        if event_type == QEvent.Type.MouseButtonPress:
            if event.button() == Qt.MouseButton.RightButton:
                self.toggle_mute()
                return True
            if event.button() == Qt.MouseButton.LeftButton:
                self.dragging = True
                self.animation_timer.stop()
                self.set_value_from_box_position(self.box_position_from_event(event))
                return True
        if event_type == QEvent.Type.MouseMove and self.dragging and event.buttons() & Qt.MouseButton.LeftButton:
            self.set_value_from_box_position(self.box_position_from_event(event))
            return True
        if event_type == QEvent.Type.MouseButtonRelease and event.button() == Qt.MouseButton.LeftButton:
            self.dragging = False
            return True
        if event_type == QEvent.Type.Wheel:
            delta = event.angleDelta().y()
            if delta and (self.kind == "piano" or self.sink_info is not None):
                step = 1 if delta > 0 else -1
                value = max(self.slider.minimum(), min(self.slider.maximum(), self.slider.value() + step))
                self.pending_volume = None
                self.set_display_volume(value)
                if self.kind == "piano":
                    self.backend.set_piano_volume(value)
                else:
                    self.backend.adjust_volume(self.sink_info, step)
                return True
        return super().eventFilter(watched, event)

    def changed(self, value):
        self.animation_timer.stop()
        self.has_volume = True
        self.value_label.setText(f"{value}")
        self.pending_volume = value
        self.commit_timer.start(COMMIT_DELAY_MS)

    def commit_volume(self):
        if self.pending_volume is None:
            return
        if self.kind == "piano":
            self.backend.set_piano_volume(self.pending_volume)
        elif self.sink_info is not None:
            self.backend.set_volume(self.sink_info, self.pending_volume)

    def toggle_mute(self):
        if self.kind == "sink" and self.sink_info is not None:
            self.backend.toggle_mute(self.sink_info)

    def set_muted(self, muted):
        if self.is_muted == muted:
            return

        self.is_muted = muted
        for widget in self.styled_widgets:
            widget.setProperty("muted", muted)
            widget.style().unpolish(widget)
            widget.style().polish(widget)
            widget.update()

    def set_display_volume(self, volume):
        self.slider.blockSignals(True)
        self.slider.setValue(volume)
        self.slider.blockSignals(False)
        self.value_label.setText(f"{volume}")

    def start_volume_animation(self, volume):
        if not self.has_volume:
            self.has_volume = True
            self.set_display_volume(volume)
            return

        self.animation_target = volume
        if not self.animation_timer.isActive():
            self.animation_timer.start(ANIMATION_INTERVAL_MS)

    def animate_volume(self):
        if self.animation_target is None:
            self.animation_timer.stop()
            return

        current = self.slider.value()
        delta = self.animation_target - current
        if delta == 0:
            self.animation_target = None
            self.animation_timer.stop()
            return

        step = max(1, abs(delta) // 3)
        self.set_display_volume(current + (step if delta > 0 else -step))

    def refresh(self, sinks):
        if self.kind == "piano":
            self.sink_info = None
            self.setEnabled(True)
            self.set_muted(False)
            if not self.has_volume:
                self.has_volume = True
                self.set_display_volume(self.backend.piano_volume)
                self.backend.set_piano_volume(self.backend.piano_volume)
            elif not self.dragging and self.slider.value() != self.backend.piano_volume:
                self.set_display_volume(self.backend.piano_volume)
            return

        info = sinks.get(self.target)
        if info is None:
            self.sink_info = None
            self.has_volume = False
            self.animation_timer.stop()
            self.setEnabled(False)
            self.value_label.setText("--")
            return

        self.sink_info, volume, muted = info
        self.setEnabled(True)
        self.set_muted(muted)
        if self.slider.value() != volume:
            self.start_volume_animation(volume)
        elif not self.animation_timer.isActive():
            self.value_label.setText(f"{volume}")


class Mixer(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle(APP_NAME)
        self.setObjectName("mixer")
        self.events = PulseEvents(self)
        self.events.changed.connect(self.pipewire_changed)
        self.events.piano_volume_changed.connect(self.piano_volume_changed)
        self.backend = PulseBackend(self.events)

        self.sliders = [SinkSlider(kind, target, label, self.backend) for kind, target, label in FADERS]

        layout = QHBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(MIXER_SPACING)
        for slider in self.sliders:
            layout.addWidget(slider)

        self.refresh_timer = single_shot_timer(self, self.refresh)

        self.midi_timer = QTimer(self)
        self.midi_timer.timeout.connect(self.backend.ensure_midi_input)
        self.midi_timer.start(MIDI_RECONNECT_MS)
        self.backend.ensure_midi_input()

        self.refresh()

    def piano_volume_changed(self, volume):
        for slider in self.sliders:
            if slider.kind == "piano" and not slider.dragging:
                slider.set_display_volume(volume)

    def pipewire_changed(self):
        if not self.refresh_timer.isActive():
            self.refresh_timer.start(REFRESH_DELAY_MS)

    def refresh(self):
        sinks = self.backend.list_sinks()
        for slider in self.sliders:
            slider.refresh(sinks)

    def closeEvent(self, event):
        self.backend.close()
        super().closeEvent(event)


def main():
    app = QApplication(sys.argv)
    app.setApplicationName(APP_ID)
    app.setDesktopFileName(APP_ID)
    app.setStyle(LargeSliderStyle(app.style()))
    highlight = app.palette().color(QPalette.ColorRole.Highlight)
    muted_highlight = QColor(highlight)
    muted_highlight.setHsl(
        highlight.hslHue(),
        round(highlight.hslSaturation() * 0.55),
        round(highlight.lightness() * 0.9),
        175,
    )

    stylesheet = """
        QWidget#mixer {
            background: transparent;
        }
        SinkSlider {
            background-color: #40404040;
            border: none;
            border-radius: 0px;
        }
        QLabel {
            background: transparent;
            border: none;
        }
        QLabel[muted="true"] {
            color: rgba(145, 145, 145, 210);
        }
        QSlider {
            background: transparent;
        }
        QSlider::groove:vertical {
            width: 18px;
            border-radius: 9px;
            background: rgba(8, 8, 8, 170);
            border: 1px solid rgba(255, 255, 255, 48);
        }
        QSlider::add-page:vertical {
            width: 18px;
            border-radius: 9px;
            background: palette(highlight);
        }
        QSlider::sub-page:vertical {
            width: 18px;
            border-radius: 9px;
            background: rgba(5, 5, 5, 165);
        }
        QSlider::handle:vertical {
            width: 64px;
            height: 28px;
            margin: 0 -23px;
            border-radius: 0px;
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                stop:0 rgba(92, 92, 92, 245),
                stop:0.45 rgba(36, 36, 36, 245),
                stop:1 rgba(8, 8, 8, 235));
            border: 1px solid rgba(0, 0, 0, 210);
        }
        QLabel#title[muted="true"] {
            color: rgba(245, 82, 82, 235);
        }
        QLabel#value[muted="true"] {
            color: rgba(92, 92, 92, 220);
        }
        QSlider[muted="true"]::add-page:vertical {
            background: __MUTED_HIGHLIGHT__;
        }
        QSlider[muted="true"]::handle:vertical {
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                stop:0 rgba(58, 58, 58, 235),
                stop:0.45 rgba(24, 24, 24, 240),
                stop:1 rgba(4, 4, 4, 235));
            border-color: rgba(0, 0, 0, 220);
        }
    """
    app.setStyleSheet(stylesheet.replace(
        "__MUTED_HIGHLIGHT__",
        f"rgba({muted_highlight.red()}, {muted_highlight.green()}, {muted_highlight.blue()}, {muted_highlight.alpha()})",
    ))

    mixer = Mixer()
    mixer.setWindowFlag(Qt.WindowType.FramelessWindowHint)
    mixer.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
    mixer.resize(WINDOW_WIDTH, WINDOW_HEIGHT)
    mixer.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
