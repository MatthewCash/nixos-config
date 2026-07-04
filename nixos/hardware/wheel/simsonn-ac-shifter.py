#!/usr/bin/env python3
# pyright: reportMissingImports=false

import argparse
import errno
import sys
import time

from evdev import AbsInfo, InputDevice, UInput, ecodes, list_devices


VID = 0xDDFD
PID = 0x6013
RETRY_INTERVAL = 1.0
DISCONNECT_ERRNOS = (errno.ENODEV, errno.EIO, errno.ENOENT, errno.ENXIO)
AXIS_MIN = 0
AXIS_MAX = 255
AXIS_CENTER = 128

BUTTONS = [
    ecodes.BTN_TRIGGER,
    ecodes.BTN_THUMB,
    ecodes.BTN_THUMB2,
    ecodes.BTN_TOP,
    ecodes.BTN_TOP2,
    ecodes.BTN_PINKIE,
    ecodes.BTN_BASE,
    ecodes.BTN_BASE2,
    ecodes.BTN_BASE3,
    ecodes.BTN_BASE4,
]


def log(message):
    print(f"simsonn-ac-shifter: {message}", file=sys.stderr, flush=True)


def find_device(path):
    if path is not None:
        try:
            dev = InputDevice(path)
        except FileNotFoundError:
            return None
        except OSError as exc:
            if exc.errno in DISCONNECT_ERRNOS:
                return None
            raise

        if dev.info.vendor == VID and dev.info.product == PID:
            return dev
        dev.close()
        return None

    for candidate in list_devices():
        try:
            dev = InputDevice(candidate)
        except (FileNotFoundError, PermissionError):
            continue

        if dev.info.vendor == VID and dev.info.product == PID:
            return dev
        dev.close()

    return None


def release_buttons(ui, pressed_buttons):
    for code in pressed_buttons:
        ui.write(ecodes.EV_KEY, code, 0)
    ui.write(ecodes.EV_ABS, ecodes.ABS_X, AXIS_CENTER)
    ui.syn()


def forward_events(dev, ui, grab):
    pressed_buttons = set()
    grabbed = False

    try:
        if grab:
            dev.grab()
            grabbed = True

        pressed_buttons = set(code for code in dev.active_keys() if code in BUTTONS)
        for code in pressed_buttons:
            ui.write(ecodes.EV_KEY, code, 1)
        ui.write(ecodes.EV_ABS, ecodes.ABS_X, AXIS_CENTER)
        ui.syn()

        for event in dev.read_loop():
            if event.type != ecodes.EV_KEY or event.code not in BUTTONS:
                continue

            if event.value:
                pressed_buttons.add(event.code)
            else:
                pressed_buttons.discard(event.code)

            ui.write(ecodes.EV_KEY, event.code, event.value)
            ui.write(ecodes.EV_ABS, ecodes.ABS_X, AXIS_CENTER)
            ui.syn()
    except OSError as exc:
        if exc.errno not in DISCONNECT_ERRNOS:
            raise
        log("device disconnected")
    finally:
        if grabbed:
            try:
                dev.ungrab()
            except OSError:
                pass
        release_buttons(ui, pressed_buttons)


def main():
    parser = argparse.ArgumentParser(
        description="Expose the SIMSONN HS PRO as a Wine-friendly virtual joystick."
    )
    parser.add_argument("--device", help="evdev input device path; defaults to auto-detect")
    parser.add_argument("--grab", action="store_true", help="grab the physical shifter while forwarding")
    parser.add_argument("--strict", action="store_true", help="return non-zero on setup failure")
    args = parser.parse_args()

    capabilities = {
        ecodes.EV_KEY: BUTTONS,
        ecodes.EV_ABS: [
            (ecodes.ABS_X, AbsInfo(value=AXIS_CENTER, min=AXIS_MIN, max=AXIS_MAX, fuzz=0, flat=0, resolution=0)),
        ],
    }

    try:
        with UInput(
            capabilities,
            name="SIMSONN HS PRO AC Shifter",
            vendor=VID,
            product=0x6014,
            version=0x0110,
        ) as ui:
            log(f"virtual shifter ready at {ui.device.path}")
            waiting_logged = False

            while True:
                dev = find_device(args.device)
                if dev is None:
                    if not waiting_logged:
                        log("waiting for SIMSONN HS PRO")
                        waiting_logged = True
                    time.sleep(RETRY_INTERVAL)
                    continue

                waiting_logged = False
                try:
                    log(f"forwarding {dev.path} to {ui.device.path}")
                    time.sleep(0.2)
                    forward_events(dev, ui, args.grab)
                except PermissionError as exc:
                    log(f"permission denied: {exc}")
                    if args.strict:
                        return 1
                    time.sleep(RETRY_INTERVAL)
                finally:
                    dev.close()
    except PermissionError as exc:
        log(f"permission denied: {exc}")
        return 1 if args.strict else 0


if __name__ == "__main__":
    raise SystemExit(main())
