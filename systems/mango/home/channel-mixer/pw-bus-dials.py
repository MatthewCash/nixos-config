#!/usr/bin/env python3

import sys
import threading

import pulsectl
from PySide6.QtCore import QEvent, QObject, Qt, QTimer, Signal
from PySide6.QtGui import QColor, QFont, QPalette
from PySide6.QtWidgets import QApplication, QFrame, QHBoxLayout, QLabel, QProxyStyle, QSlider, QStyle, QVBoxLayout, QWidget


SINKS = [
    ("games", "Games"),
    ("instruments", "Instruments"),
    ("media", "Media"),
    ("voice", "Voice"),
]

APP_ID = "channel-mixer"
APP_NAME = "Channel Mixer"
FONT_FAMILY = "Aurebesh"

COMMIT_DELAY_MS = 35
ANIMATION_INTERVAL_MS = 16
REFRESH_DELAY_MS = 25
WINDOW_WIDTH = 620
WINDOW_HEIGHT = 600
SLIDER_MIN_WIDTH = 110
SLIDER_MIN_HEIGHT = 380


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


def single_shot_timer(parent, timeout):
    timer = QTimer(parent)
    timer.setSingleShot(True)
    timer.timeout.connect(timeout)
    return timer


class PulseBackend:
    def __init__(self, events):
        self.events = events
        self.pulse = pulsectl.Pulse("pw-bus-mixer")
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

    def toggle_mute(self, sink, muted):
        try:
            self.pulse.mute(sink, muted)
        except pulsectl.PulseError:
            pass

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


def bus_slider():
    slider = QSlider(Qt.Orientation.Vertical)
    slider.setRange(0, 100)
    slider.setSingleStep(1)
    slider.setPageStep(5)
    slider.setTracking(True)
    slider.setMinimumSize(SLIDER_MIN_WIDTH, SLIDER_MIN_HEIGHT)
    return slider


class SinkSlider(QFrame):
    def __init__(self, sink, label, backend):
        super().__init__()
        self.sink = sink
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
        title_font = self.title.font()
        title_font.setFamily(FONT_FAMILY)
        title_font.setPointSize(15)
        title_font.setBold(True)
        self.title.setFont(title_font)

        self.value_label = QLabel("--")
        self.value_label.setObjectName("value")
        self.value_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        value_font = QFont(FONT_FAMILY)
        value_font.setStyleHint(QFont.StyleHint.Monospace)
        value_font.setPointSize(14)
        value_font.setBold(True)
        self.value_label.setFont(value_font)

        self.slider = bus_slider()
        self.styled_widgets = (self, self.title, self.value_label, self.slider)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(9, 9, 9, 9)
        layout.setSpacing(6)
        layout.addWidget(self.title, alignment=Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(self.slider, alignment=Qt.AlignmentFlag.AlignCenter)
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
            if delta and self.sink_info is not None:
                step = 1 if delta > 0 else -1
                value = max(self.slider.minimum(), min(self.slider.maximum(), self.slider.value() + step))
                self.pending_volume = None
                self.set_display_volume(value)
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
        if self.sink_info is not None and self.pending_volume is not None:
            self.backend.set_volume(self.sink_info, self.pending_volume)

    def toggle_mute(self):
        if self.sink_info is not None:
            self.set_muted(not self.is_muted)
            self.backend.toggle_mute(self.sink_info, self.is_muted)

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
        info = sinks.get(self.sink)
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
        self.backend = PulseBackend(self.events)

        self.sliders = [SinkSlider(sink, label, self.backend) for sink, label in SINKS]

        layout = QHBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(9)
        for slider in self.sliders:
            layout.addWidget(slider)

        self.refresh_timer = single_shot_timer(self, self.refresh)

        self.refresh()

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
            width: 76px;
            height: 28px;
            margin: 0 -29px;
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
