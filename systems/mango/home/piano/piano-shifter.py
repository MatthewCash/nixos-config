#!/usr/bin/env python3
# pyright: reportMissingImports=false

import errno
import sys
import threading
import time

import rtmidi
from evdev import InputDevice, ecodes, list_devices


SHIFTER_DEVICE = "/dev/input/simsonn-ac-shifter"
SHIFTER_NAME = "SIMSONN HS PRO AC Shifter"
OUTPUT_MATCH = "smk25"
RECONNECT_SECONDS = 1.0
DISCONNECT_ERRNOS = (errno.ENODEV, errno.EIO, errno.ENOENT, errno.ENXIO)
MELODIC_CHANNELS = [channel for channel in range(16) if channel != 9]

SHIFTER_BUTTONS = [
    ecodes.BTN_TRIGGER,
    ecodes.BTN_THUMB,
    ecodes.BTN_THUMB2,
    ecodes.BTN_TOP,
    ecodes.BTN_TOP2,
    ecodes.BTN_PINKIE,
    ecodes.BTN_BASE,
    ecodes.BTN_BASE2,
]

PROGRAMS = [0, 8, 1, 2, 51, 98, 54, 38, 103]


def log(message):
    print(f"piano-shifter: {message}", file=sys.stderr, flush=True)


class SynthOutput:
    def __init__(self):
        self.lock = threading.RLock()
        self.midi_out = None
        self.output_port = None
        self.last_find_fail = 0.0

    def find_output_port(self):
        # NOTE: every rtmidi.MidiOut construction opens a kernel ALSA
        # sequencer client that is only released by delete(). The
        # enumerator must always be deleted, otherwise each call
        # permanently leaks one client until "Cannot allocate memory"
        # wedges all MIDI on the system. Construction can also raise
        # _rtmidi.SystemError (not RtMidiError) when the sequencer is
        # exhausted, so catch broadly and let the caller retry later.
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
            if port.startswith(f"{OUTPUT_MATCH}:{OUTPUT_MATCH} "):
                return index, port
        return None

    def connect(self):
        with self.lock:
            if self.midi_out is not None and self.output_port in self.midi_out.get_ports():
                return True

            self.close()
            # Rate-limit (re-)enumeration while the synth is unreachable:
            # without this each MIDI message triggers a new sequencer
            # client construction, which storms the kernel pool.
            now = time.monotonic()
            if now - self.last_find_fail < 1.0:
                return False
            candidate = self.find_output_port()
            if candidate is None:
                self.last_find_fail = now
                return False

            self.midi_out = rtmidi.MidiOut()
            self.midi_out.open_port(candidate[0])
            self.output_port = candidate[1]
            log(f"connected to {self.output_port}")
            return True

    def send_message(self, message):
        with self.lock:
            if not self.connect():
                log("waiting for smk25 MIDI output")
                return
            try:
                midi_out = self.midi_out
                if midi_out is not None:
                    midi_out.send_message(message)
            except rtmidi.RtMidiError:
                self.close()

    def send_program(self, program):
        for midi_channel in MELODIC_CHANNELS:
            self.send_message([0xB0 | midi_channel, 123, 0])
            self.send_message([0xE0 | midi_channel, 0, 64])
            self.send_message([0xB0 | midi_channel, 0, 0])
            self.send_message([0xB0 | midi_channel, 32, 0])
            self.send_message([0xC0 | midi_channel, program])

    def close(self):
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
        self.output_port = None


def find_shifter():
    try:
        dev = InputDevice(SHIFTER_DEVICE)
        if dev.name == SHIFTER_NAME:
            return dev
        dev.close()
    except (FileNotFoundError, PermissionError):
        pass
    except OSError as exc:
        if exc.errno not in DISCONNECT_ERRNOS:
            raise

    for path in list_devices():
        try:
            dev = InputDevice(path)
        except (FileNotFoundError, PermissionError):
            continue
        except OSError as exc:
            if exc.errno in DISCONNECT_ERRNOS:
                continue
            raise

        if dev.name == SHIFTER_NAME:
            return dev
        dev.close()
    return None


def slot_from_buttons(active_buttons):
    for index, code in enumerate(SHIFTER_BUTTONS, start=1):
        if code in active_buttons:
            return index
    return 0


def send_slot(synth, slot):
    program = PROGRAMS[slot]
    label = "neutral" if slot == 0 else f"slot {slot}"
    log(f"{label} -> program {program}")
    synth.send_program(program)


def follow_shifter(dev, synth):
    active_buttons = set(code for code in dev.active_keys() if code in SHIFTER_BUTTONS)
    current_slot = slot_from_buttons(active_buttons)
    send_slot(synth, current_slot)

    for event in dev.read_loop():
        if event.type != ecodes.EV_KEY or event.code not in SHIFTER_BUTTONS:
            continue

        if event.value:
            active_buttons.add(event.code)
        else:
            active_buttons.discard(event.code)

        slot = slot_from_buttons(active_buttons)
        if slot == current_slot:
            continue
        current_slot = slot
        send_slot(synth, slot)


def main():
    synth = SynthOutput()
    waiting_logged = False

    while True:
        dev = find_shifter()
        if dev is None:
            if not waiting_logged:
                log("waiting for SIMSONN HS PRO AC Shifter")
                waiting_logged = True
            time.sleep(RECONNECT_SECONDS)
            continue

        waiting_logged = False
        try:
            log(f"watching {dev.path}")
            follow_shifter(dev, synth)
        except PermissionError as exc:
            log(f"permission denied: {exc}")
            time.sleep(RECONNECT_SECONDS)
        except OSError as exc:
            if exc.errno not in DISCONNECT_ERRNOS:
                raise
            log("shifter disconnected")
            time.sleep(RECONNECT_SECONDS)
        finally:
            dev.close()


if __name__ == "__main__":
    raise SystemExit(main())
