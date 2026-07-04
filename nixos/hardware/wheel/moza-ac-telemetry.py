#!/usr/bin/env python3

import argparse
import errno
import glob
import os
import signal
import struct
import sys
import termios
import time


START = 0x7E
MAGIC = 13
WRITE_GROUP = 63
WHEEL_IDS = (23, 21)
LED_COUNT = 10
SERIAL_GLOB = "/dev/serial/by-id/usb-Gudsen_MOZA_R9_Base_*"
RECONNECT_INTERVAL = 1.0
LOOP_SLEEP = 0.005
AC_READ_INTERVAL = 0.02
AC_RESCAN_INTERVAL = 1.0
AC_MAP_SIZE = 4096
DISCONNECT_ERRNOS = (errno.ENODEV, errno.EIO, errno.ENOENT, errno.ENXIO, errno.EBADF, errno.EPIPE)

AC_STATIC_CAR_OFFSET = 68
AC_STATIC_TRACK_OFFSET = 134
AC_STATIC_MAX_RPM_OFFSET = 412
AC_PHYSICS_PACKET_ID_OFFSET = 0
AC_PHYSICS_GAS_OFFSET = 4
AC_PHYSICS_BRAKE_OFFSET = 8
AC_PHYSICS_FUEL_OFFSET = 12
AC_PHYSICS_GEAR_OFFSET = 16
AC_PHYSICS_RPM_OFFSET = 20
AC_PHYSICS_STEER_OFFSET = 24
AC_PHYSICS_SPEED_OFFSET = 28

THRESHOLDS = (0.013, 0.25, 0.40, 0.52, 0.62, 0.71, 0.78, 0.84, 0.89, 0.93)
COLORS = (
    (0, 255, 0),
    (0, 255, 0),
    (0, 255, 0),
    (255, 160, 0),
    (255, 160, 0),
    (255, 0, 0),
    (255, 0, 0),
    (0, 0, 255),
    (0, 0, 255),
    (0, 0, 255),
)


def log(message):
    print("moza-ac-telemetry: {}".format(message), file=sys.stderr, flush=True)


def int32(data, offset):
    return struct.unpack_from("<i", data, offset)[0]


def float32(data, offset):
    return struct.unpack_from("<f", data, offset)[0]


def utf16_string(data, offset, chars):
    return data[offset:offset + chars * 2].decode("utf-16le", "ignore").split("\x00", 1)[0]


def plausible_name(value):
    return bool(value) and all(31 < ord(char) < 127 for char in value)


def valid_rpm(value):
    return 0 <= value < 30000


def valid_max_rpm(value):
    return 1000 < value < 30000


class AcSharedMemory:
    def __init__(self):
        self.pid = None
        self.mem_fd = None
        self.static_addr = None
        self.physics_addr = None
        self.next_scan = 0.0
        self.last_car = None
        self.last_error = None

    def close(self):
        if self.mem_fd is not None:
            try:
                os.close(self.mem_fd)
            except OSError:
                pass
        self.pid = None
        self.mem_fd = None
        self.static_addr = None
        self.physics_addr = None
        self.last_car = None

    def read_region(self, address, size):
        if self.mem_fd is None:
            raise OSError(errno.EBADF, "AC memory is not open")
        return os.pread(self.mem_fd, size, address)

    def process_ids(self):
        for name in os.listdir("/proc"):
            if not name.isdigit():
                continue
            pid = int(name)
            try:
                with open("/proc/{}/comm".format(pid)) as f:
                    comm = f.read().strip()
                with open("/proc/{}/cmdline".format(pid), "rb") as f:
                    cmdline = f.read().replace(b"\x00", b" ").decode("utf-8", "ignore")
            except OSError:
                continue
            if comm.startswith("AC:") or "acs.exe" in cmdline.lower():
                yield pid

    def memfd_regions(self, pid):
        regions = []
        try:
            with open("/proc/{}/maps".format(pid)) as f:
                for line in f:
                    parts = line.rstrip().split(None, 5)
                    if len(parts) < 5:
                        continue
                    start_text, end_text = parts[0].split("-")
                    start = int(start_text, 16)
                    end = int(end_text, 16)
                    perms = parts[1]
                    path = parts[5] if len(parts) > 5 else ""
                    if "r" in perms and end - start == AC_MAP_SIZE and "memfd:wine-mapping" in path:
                        regions.append(start)
        except OSError:
            pass
        return regions

    def static_candidates(self, pages):
        candidates = []
        for address, data in pages:
            max_rpm = int32(data, AC_STATIC_MAX_RPM_OFFSET)
            car = utf16_string(data, AC_STATIC_CAR_OFFSET, 33)
            track = utf16_string(data, AC_STATIC_TRACK_OFFSET, 33)
            if valid_max_rpm(max_rpm) and plausible_name(car):
                candidates.append((address, car, track, max_rpm))
        return candidates

    def physics_candidates(self, pages):
        candidates = []
        time.sleep(0.03)
        for address, data in pages:
            try:
                later = self.read_region(address, AC_MAP_SIZE)
            except OSError:
                continue

            packet = int32(data, AC_PHYSICS_PACKET_ID_OFFSET)
            later_packet = int32(later, AC_PHYSICS_PACKET_ID_OFFSET)
            rpm = int32(data, AC_PHYSICS_RPM_OFFSET)
            later_rpm = int32(later, AC_PHYSICS_RPM_OFFSET)
            gear = int32(data, AC_PHYSICS_GEAR_OFFSET)
            gas = float32(data, AC_PHYSICS_GAS_OFFSET)
            brake = float32(data, AC_PHYSICS_BRAKE_OFFSET)
            fuel = float32(data, AC_PHYSICS_FUEL_OFFSET)
            steer = float32(data, AC_PHYSICS_STEER_OFFSET)
            speed = float32(data, AC_PHYSICS_SPEED_OFFSET)

            if packet == later_packet:
                continue
            if not valid_rpm(rpm) or not valid_rpm(later_rpm):
                continue
            if not -1 <= gear <= 10:
                continue
            if not 0.0 <= gas <= 1.1 or not 0.0 <= brake <= 1.1:
                continue
            if not 0.0 <= fuel <= 500.0:
                continue
            if not -1080.0 <= steer <= 1080.0:
                continue
            if not -20.0 <= speed <= 500.0:
                continue
            candidates.append(address)
        return candidates

    def attach(self, now):
        if now < self.next_scan:
            return False
        self.next_scan = now + AC_RESCAN_INTERVAL

        for pid in self.process_ids():
            try:
                mem_fd = os.open("/proc/{}/mem".format(pid), os.O_RDONLY)
            except OSError as exc:
                message = "cannot open /proc/{}/mem: {}".format(pid, exc)
                if message != self.last_error:
                    log(message)
                    self.last_error = message
                continue

            self.close()
            self.pid = pid
            self.mem_fd = mem_fd

            pages = []
            for address in self.memfd_regions(pid):
                try:
                    pages.append((address, self.read_region(address, AC_MAP_SIZE)))
                except OSError:
                    pass

            statics = self.static_candidates(pages)
            physics = self.physics_candidates(pages)
            if not statics or not physics:
                self.close()
                continue

            static = min(statics, key=lambda item: min(abs(item[0] - address) for address in physics))
            self.static_addr, car, track, max_rpm = static
            self.physics_addr = min(physics, key=lambda address: abs(address - self.static_addr))
            self.last_car = car
            self.last_error = None
            log("reading Assetto Corsa shared memory pid={} car={} track={} max_rpm={}".format(pid, car, track, max_rpm))
            return True
        return False

    def read(self, now):
        if self.mem_fd is None and not self.attach(now):
            return None
        try:
            static = self.read_region(self.static_addr, AC_STATIC_MAX_RPM_OFFSET + 4)
            physics = self.read_region(self.physics_addr, AC_PHYSICS_SPEED_OFFSET + 4)
            rpm = int32(physics, AC_PHYSICS_RPM_OFFSET)
            max_rpm = int32(static, AC_STATIC_MAX_RPM_OFFSET)
            car = utf16_string(static, AC_STATIC_CAR_OFFSET, 33)

            if not valid_rpm(rpm) or not valid_max_rpm(max_rpm) or not plausible_name(car):
                raise OSError(errno.EIO, "invalid AC shared memory telemetry")
            if car != self.last_car:
                track = utf16_string(static, AC_STATIC_TRACK_OFFSET, 33)
                self.last_car = car
                log("Assetto Corsa car changed car={} track={} max_rpm={}".format(car, track, max_rpm))

            return float(rpm), float(max_rpm), int(rpm >= max_rpm * 0.985)
        except OSError as exc:
            message = "lost Assetto Corsa shared memory: {}".format(exc)
            if message != self.last_error:
                log(message)
                self.last_error = message
            self.close()
            return None


def find_serial():
    paths = sorted(glob.glob(SERIAL_GLOB))
    return paths[0] if paths else None


def close_serial(fd):
    if fd is None:
        return
    try:
        os.close(fd)
    except OSError:
        pass


def open_serial(path):
    fd = os.open(path, os.O_RDWR | os.O_NOCTTY)
    try:
        attrs = termios.tcgetattr(fd)
        attrs[0] = 0
        attrs[1] = 0
        attrs[2] = termios.CS8 | termios.CREAD | termios.CLOCAL
        attrs[3] = 0
        attrs[4] = termios.B115200
        attrs[5] = termios.B115200
        attrs[6][termios.VMIN] = 0
        attrs[6][termios.VTIME] = 5
        termios.tcsetattr(fd, termios.TCSANOW, attrs)
        termios.tcflush(fd, termios.TCIOFLUSH)
        return fd
    except OSError:
        close_serial(fd)
        raise


def message(wheel_id, command, payload):
    data = bytearray([START, len(command) + len(payload), WRITE_GROUP, wheel_id])
    data.extend(command)
    data.extend(payload)
    data.append((MAGIC + sum(data)) & 0xFF)
    return bytes(data)


def send(fd, command, payload):
    for wheel_id in WHEEL_IDS:
        data = message(wheel_id, command, payload)
        offset = 0
        while offset < len(data):
            written = os.write(fd, data[offset:])
            if written <= 0:
                raise OSError(errno.EIO, "short write to serial device")
            offset += written


def send_mask(fd, mask):
    mask = max(0, min(mask, (1 << LED_COUNT) - 1))
    send(fd, [26, 0], [mask & 0xFF, (mask >> 8) & 0xFF])


def set_colors(fd, colors):
    payload = []
    for index, color in enumerate(colors):
        payload.extend([index, *color])
    send(fd, [25, 0], payload[:20])
    send(fd, [25, 0], payload[20:])


def setup_wheel(fd):
    send(fd, [28, 0], [1])
    send(fd, [27, 0, 255], [100])
    set_colors(fd, COLORS)


def rpm_mask(rpm, max_rpm, limiter):
    if limiter:
        return (1 << LED_COUNT) - 1
    if rpm <= 0 or max_rpm <= 0:
        return 0

    mask = 0
    for index, threshold in enumerate(THRESHOLDS):
        if rpm >= max_rpm * threshold:
            mask |= 1 << index
    return mask


def idle_mask(step):
    max_pos = LED_COUNT - 1
    triangle = max_pos - abs(max_pos - (step % (max_pos * 2)))
    return 1 << triangle


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--test-sweep", action="store_true")
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()

    running = True

    def stop(_signum, _frame):
        nonlocal running
        running = False

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)

    if args.test_sweep:
        serial_path = find_serial()
        if serial_path is None:
            log("No MOZA R9 serial device found")
            return 1
        try:
            fd = open_serial(serial_path)
        except PermissionError:
            log("Permission denied opening {}. Rebuild/replug so udev uaccess applies.".format(serial_path))
            return 1
        try:
            setup_wheel(fd)
            for index in range(LED_COUNT):
                send_mask(fd, 1 << index)
                time.sleep(0.1)
            send_mask(fd, 0)
            return 0
        finally:
            close_serial(fd)

    ac_memory = AcSharedMemory()
    fd = None
    last_open_attempt = 0.0
    waiting_logged = False
    last_mask = None
    last_send = 0.0
    last_packet = 0.0
    last_idle = 0.0
    last_ac_read = 0.0
    mode = None
    rpm = 0.0
    target = 0
    limiter = 0
    step = 0

    try:
        while running:
            now = time.monotonic()

            if fd is None and now - last_open_attempt >= RECONNECT_INTERVAL:
                last_open_attempt = now
                serial_path = find_serial()
                if serial_path is None:
                    if not waiting_logged:
                        log("waiting for MOZA R9 serial device")
                        waiting_logged = True
                else:
                    try:
                        fd = open_serial(serial_path)
                        setup_wheel(fd)
                        log("writing {}".format(serial_path))
                        waiting_logged = False
                        last_mask = None
                        last_send = 0.0
                        mode = None
                    except PermissionError:
                        fd = None
                        log("Permission denied opening {}. Rebuild/replug so udev uaccess applies.".format(serial_path))
                    except OSError as exc:
                        close_serial(fd)
                        fd = None
                        if exc.errno not in DISCONNECT_ERRNOS:
                            raise
                        log("MOZA R9 serial device disconnected during setup")

            if now - last_ac_read >= AC_READ_INTERVAL or ac_memory.mem_fd is None:
                last_ac_read = now
                packet = ac_memory.read(now)
                if packet is not None:
                    rpm, max_rpm, limiter = packet
                    target = rpm_mask(rpm, max_rpm, limiter)
                    last_packet = now
                    if args.verbose:
                        print("rpm={} max_rpm={} limiter={} mask={}".format(int(rpm), int(max_rpm), limiter, target), flush=True)

            try:
                if now - last_packet > 1.0 or rpm == 0:
                    if mode != "idle":
                        if fd is not None:
                            set_colors(fd, [(255, 0, 0)] * LED_COUNT)
                        mode = "idle"
                        last_mask = None
                    if now - last_idle >= 0.04:
                        step += 1
                        last_idle = now
                    mask = idle_mask(step)
                elif limiter:
                    if mode != "flash":
                        if fd is not None:
                            set_colors(fd, [(0, 0, 255)] * LED_COUNT)
                        mode = "flash"
                        last_mask = None
                    mask = (1 << LED_COUNT) - 1 if int(now * 6) % 2 == 0 else 0
                else:
                    if mode != "normal":
                        if fd is not None:
                            set_colors(fd, COLORS)
                        mode = "normal"
                        last_mask = None
                    mask = target

                if fd is not None and (mask != last_mask or now - last_send >= 0.5):
                    send_mask(fd, mask)
                    last_mask = mask
                    last_send = now
            except OSError as exc:
                if exc.errno not in DISCONNECT_ERRNOS:
                    raise
                log("MOZA R9 serial device disconnected")
                close_serial(fd)
                fd = None
                last_mask = None
                mode = None

            time.sleep(LOOP_SLEEP)

        if fd is not None:
            try:
                send_mask(fd, 0)
            except OSError:
                pass
        return 0
    finally:
        ac_memory.close()
        close_serial(fd)


if __name__ == "__main__":
    sys.exit(main())
