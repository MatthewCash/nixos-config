#!/usr/bin/env python3

import os
import socket
import struct
import subprocess
import sys
import wave
from pathlib import Path

from PySide6.QtCore import Qt, QTimer
from PySide6.QtGui import QColor, QFont, QPainter, QPalette
from PySide6.QtWidgets import QApplication, QFrame, QGridLayout, QLabel, QVBoxLayout, QWidget


APP_ID = "looper"
APP_NAME = "Looper"
FONT_FAMILY = "Aurebesh"
WINDOW_WIDTH = 650
WINDOW_HEIGHT = 215
SLOTS_PER_INSTRUMENT = 5
LOOPER_NAME = "sl-looper"
OSC_PORT = 19951
LOOP_SECONDS = 240
CONNECT_RETRY_MS = 1000
SAVE_DELAY_MS = 250
LOAD_DELAY_MS = 250

INSTRUMENTS = [
    ("piano", "Piano", ("smk25:left", "smk25:right")),
    ("guitar", "Guitar", ("guitar-rack-dsp:out_0", "guitar-rack-dsp:out_1")),
]

PLAYBACK_PORTS = (
    "alsa_output.pci-0000_00_1f.3.analog-stereo:playback_FL",
    "alsa_output.pci-0000_00_1f.3.analog-stereo:playback_FR",
)


def state_dir():
    root = os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state"))
    path = Path(root) / "looper"
    path.mkdir(parents=True, exist_ok=True)
    return path


def wav_duration_text(path):
    try:
        with wave.open(str(path), "rb") as wav:
            seconds = wav.getnframes() / max(1, wav.getframerate())
    except (FileNotFoundError, OSError, wave.Error):
        return "empty"

    if seconds < 60:
        return f"{seconds:.1f}s"
    minutes = int(seconds // 60)
    return f"{minutes}:{int(seconds % 60):02d}"


def osc_pad(data):
    return data + (b"\0" * ((4 - (len(data) % 4)) % 4))


def osc_string(value):
    return osc_pad(value.encode() + b"\0")


def osc_message(path, *args):
    tags = ","
    payload = b""
    for arg in args:
        if isinstance(arg, int):
            tags += "i"
            payload += struct.pack(">i", arg)
        elif isinstance(arg, float):
            tags += "f"
            payload += struct.pack(">f", arg)
        else:
            tags += "s"
            payload += osc_string(str(arg))
    return osc_string(path) + osc_string(tags) + payload


def pipewire_ports(direction):
    try:
        result = subprocess.run(["pw-link", direction], check=True, capture_output=True, text=True)
    except subprocess.SubprocessError:
        return set()
    return set(line.strip() for line in result.stdout.splitlines() if line.strip())


def link_ports(source, target):
    return subprocess.run(["pw-link", source, target], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False).returncode in (0, 1)


class SooperLooper:
    def __init__(self, root):
        self.root = root
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.process = subprocess.Popen([
            "sooperlooper",
            "-q",
            "-l", str(len(INSTRUMENTS) * SLOTS_PER_INSTRUMENT),
            "-c", "2",
            "-D", "yes",
            "-t", str(LOOP_SECONDS),
            "-p", str(OSC_PORT),
            "-j", LOOPER_NAME,
        ])
        self.configured = False
        self.connected = False

    def send(self, path, *args):
        self.socket.sendto(osc_message(path, *args), ("127.0.0.1", OSC_PORT))

    def configure(self):
        if self.configured:
            return True
        if not self.ports_ready():
            return False
        for index in range(len(INSTRUMENTS) * SLOTS_PER_INSTRUMENT):
            self.send(f"/sl/{index}/set", "dry", 0.0)
            self.send(f"/sl/{index}/set", "wet", 1.0)
            self.send(f"/sl/{index}/set", "input_gain", 1.0)
            self.send(f"/sl/{index}/set", "feedback", 1.0)
            self.send(f"/sl/{index}/set", "fade_samples", 960.0)
            self.send(f"/sl/{index}/hit", "mute_on")
        self.configured = True
        return True

    def ports_ready(self):
        return f"{LOOPER_NAME}:loop0_in_1" in pipewire_ports("--input")

    def connect_ports(self):
        if self.connected:
            return True

        outputs = pipewire_ports("--output")
        inputs = pipewire_ports("--input")
        required_outputs = set()
        required_inputs = set()
        for instrument_index, (_instrument, _label, sources) in enumerate(INSTRUMENTS):
            required_sources = set(sources)
            if not required_sources.issubset(outputs):
                return False
            for slot in range(SLOTS_PER_INSTRUMENT):
                loop = instrument_index * SLOTS_PER_INSTRUMENT + slot
                required_inputs.add(f"{LOOPER_NAME}:loop{loop}_in_1")
                required_inputs.add(f"{LOOPER_NAME}:loop{loop}_in_2")

        for loop in range(len(INSTRUMENTS) * SLOTS_PER_INSTRUMENT):
            required_outputs.add(f"{LOOPER_NAME}:loop{loop}_out_1")
            required_outputs.add(f"{LOOPER_NAME}:loop{loop}_out_2")
        required_inputs.update(PLAYBACK_PORTS)

        if not required_inputs.issubset(inputs) or not required_outputs.issubset(outputs):
            return False

        for instrument_index, (_instrument, _label, sources) in enumerate(INSTRUMENTS):
            for slot in range(SLOTS_PER_INSTRUMENT):
                loop = instrument_index * SLOTS_PER_INSTRUMENT + slot
                if not link_ports(sources[0], f"{LOOPER_NAME}:loop{loop}_in_1"):
                    return False
                if not link_ports(sources[1], f"{LOOPER_NAME}:loop{loop}_in_2"):
                    return False
                if not link_ports(f"{LOOPER_NAME}:loop{loop}_out_1", PLAYBACK_PORTS[0]):
                    return False
                if not link_ports(f"{LOOPER_NAME}:loop{loop}_out_2", PLAYBACK_PORTS[1]):
                    return False
        self.connected = True
        return True

    def load_loop(self, loop, path):
        if path.exists():
            self.send(f"/sl/{loop}/load_loop", str(path), "osc.udp://127.0.0.1:9/", "/error")
            self.send(f"/sl/{loop}/hit", "mute_on")

    def start_recording(self, loop):
        self.send(f"/sl/{loop}/hit", "mute_on")
        self.send(f"/sl/{loop}/hit", "record")

    def stop_recording(self, loop, path):
        self.send(f"/sl/{loop}/hit", "record")
        self.send(f"/sl/{loop}/hit", "mute_on")
        QTimer.singleShot(SAVE_DELAY_MS, lambda: self.save_loop(loop, path))

    def save_loop(self, loop, path):
        self.send(f"/sl/{loop}/save_loop", str(path), "wav", "little", "osc.udp://127.0.0.1:9/", "/error")

    def set_playing(self, loop, playing):
        self.send(f"/sl/{loop}/hit", "mute_off" if playing else "mute_on")

    def close(self):
        try:
            self.send("/quit")
        except OSError:
            pass
        if self.process.poll() is None:
            try:
                self.process.wait(timeout=1.5)
            except subprocess.TimeoutExpired:
                self.process.terminate()
                try:
                    self.process.wait(timeout=1.0)
                except subprocess.TimeoutExpired:
                    self.process.kill()
        self.socket.close()


class LoopSlot(QFrame):
    def __init__(self, backend, instrument, label, loop, index, root):
        super().__init__()
        self.backend = backend
        self.instrument = instrument
        self.loop = loop
        self.index = index
        self.path = root / f"{instrument}-{index}.wav"
        self.recording = False
        self.playing = False
        self.filled = self.path.exists()
        self.loaded = False
        self.setObjectName("slot")
        self.setAttribute(Qt.WidgetAttribute.WA_Hover)
        self.setAttribute(Qt.WidgetAttribute.WA_StyledBackground)
        self.setCursor(Qt.CursorShape.PointingHandCursor)
        self.setMinimumSize(82, 82)

        self.title = QLabel(str(index))
        self.title.setObjectName("slotTitle")
        title_font = QFont(FONT_FAMILY)
        title_font.setPointSize(18)
        title_font.setBold(True)
        self.title.setFont(title_font)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(10, 6, 10, 6)
        layout.setSpacing(0)
        layout.addWidget(self.title, alignment=Qt.AlignmentFlag.AlignCenter)
        self.refresh()

    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton:
            self.toggle_playing()
            event.accept()
            return
        if event.button() == Qt.MouseButton.RightButton:
            self.toggle_recording()
            event.accept()
            return
        super().mousePressEvent(event)

    def enterEvent(self, event):
        self.update()
        super().enterEvent(event)

    def leaveEvent(self, event):
        self.update()
        super().leaveEvent(event)

    def paintEvent(self, event):
        if self.recording:
            background = QColor(245, 82, 82, 235)
        elif self.playing:
            background = self.palette().color(QPalette.ColorRole.Highlight)
            background.setAlpha(235)
        elif self.underMouse():
            background = QColor(62, 62, 62, 210)
        else:
            super().paintEvent(event)
            return

        painter = QPainter(self)
        painter.fillRect(self.rect(), background)
        event.accept()

    def toggle_recording(self):
        if self.recording:
            self.recording = False
            self.playing = False
            self.filled = True
            self.loaded = True
            self.backend.stop_recording(self.loop, self.path)
        else:
            self.path.unlink(missing_ok=True)
            self.recording = True
            self.playing = False
            self.filled = False
            self.loaded = False
            self.backend.start_recording(self.loop)
        self.refresh()

    def toggle_playing(self):
        if self.recording or not self.filled:
            return
        if self.playing:
            self.playing = False
            self.backend.set_playing(self.loop, False)
        else:
            self.playing = True
            if self.loaded:
                self.backend.set_playing(self.loop, True)
            else:
                self.backend.load_loop(self.loop, self.path)
                self.loaded = True
                QTimer.singleShot(LOAD_DELAY_MS, lambda: self.backend.set_playing(self.loop, True))
        self.refresh()

    def refresh(self):
        self.setProperty("recording", self.recording)
        self.setProperty("playing", self.playing)
        self.setProperty("filled", self.filled)
        for widget in (self, self.title):
            widget.setProperty("recording", self.recording)
            widget.setProperty("playing", self.playing)
            widget.setProperty("filled", self.filled)
            widget.style().unpolish(widget)
            widget.style().polish(widget)
            widget.update()

        if self.recording:
            status = "recording"
        elif self.playing:
            status = "playing"
        elif self.filled:
            status = wav_duration_text(self.path)
        else:
            status = "empty"
        self.setToolTip(status)

    def close(self):
        if self.recording:
            self.backend.stop_recording(self.loop, self.path)


class InstrumentRow(QFrame):
    def __init__(self, backend, instrument_index, instrument, label, root):
        super().__init__()
        self.setObjectName("row")
        self.setAttribute(Qt.WidgetAttribute.WA_StyledBackground)
        self.slots = []
        for index in range(1, SLOTS_PER_INSTRUMENT + 1):
            loop = instrument_index * SLOTS_PER_INSTRUMENT + index - 1
            self.slots.append(LoopSlot(backend, instrument, label, loop, index, root))

        title = QLabel(label[:4])
        title.setObjectName("instrument")
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        title_font = QFont(FONT_FAMILY)
        title_font.setPointSize(17)
        title_font.setBold(True)
        title.setFont(title_font)

        layout = QGridLayout(self)
        layout.setContentsMargins(18, 8, 10, 8)
        layout.setHorizontalSpacing(12)
        layout.setVerticalSpacing(6)
        layout.addWidget(title, 0, 0)
        for column, slot in enumerate(self.slots, start=1):
            layout.addWidget(slot, 0, column)

    def close(self):
        for slot in self.slots:
            slot.close()


class Looper(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle(APP_NAME)
        self.setObjectName("looper")
        root = state_dir()
        self.backend = SooperLooper(root)
        self.rows = [
            InstrumentRow(self.backend, instrument_index, instrument, label, root)
            for instrument_index, (instrument, label, _sources) in enumerate(INSTRUMENTS)
        ]

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(9)
        for row in self.rows:
            layout.addWidget(row)

        self.connect_timer = QTimer(self)
        self.connect_timer.timeout.connect(self.connect_backend)
        self.connect_timer.start(CONNECT_RETRY_MS)
        QTimer.singleShot(200, self.connect_backend)

    def connect_backend(self):
        if not self.backend.configure():
            return
        if self.backend.connect_ports():
            self.connect_timer.stop()

    def closeEvent(self, event):
        for row in self.rows:
            row.close()
        self.backend.close()
        super().closeEvent(event)


def main():
    app = QApplication(sys.argv)
    app.setApplicationName(APP_ID)
    app.setDesktopFileName(APP_ID)
    highlight = app.palette().color(QPalette.ColorRole.Highlight)
    recording = QColor(245, 82, 82, 235)
    playing = QColor(highlight)

    stylesheet = """
        QWidget#looper {
            background: transparent;
        }
        QFrame#row {
            background-color: #40404030;
            border: none;
            border-radius: 0px;
        }
        QFrame#slot {
            background-color: transparent;
            border: none;
            border-radius: 0px;
            min-width: 82px;
            min-height: 82px;
        }
        QFrame#slot[filled="true"] {
            background-color: transparent;
        }
        QFrame#slot:hover {
            background-color: #4a4a4a;
        }
        QFrame#slot[recording="true"] {
            background: __RECORDING__;
        }
        QFrame#slot[playing="true"] {
            background: __PLAYING__;
        }
        QLabel {
            background: transparent;
            border: none;
            color: palette(text);
        }
        QLabel#instrument {
            min-width: 112px;
        }
        QLabel#slotTitle[filled="true"] {
            color: palette(highlight);
        }
        QLabel#slotTitle[recording="true"] {
            color: rgba(8, 8, 8, 235);
        }
        QLabel#slotTitle[playing="true"] {
            color: #ffffff;
        }
    """
    app.setStyleSheet(
        stylesheet
        .replace("__RECORDING__", f"rgba({recording.red()}, {recording.green()}, {recording.blue()}, {recording.alpha()})")
        .replace("__PLAYING__", f"rgba({playing.red()}, {playing.green()}, {playing.blue()}, {playing.alpha()})")
    )

    looper = Looper()
    looper.setWindowFlag(Qt.WindowType.FramelessWindowHint)
    looper.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
    looper.resize(WINDOW_WIDTH, WINDOW_HEIGHT)
    looper.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
