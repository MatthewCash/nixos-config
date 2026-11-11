#!/usr/bin/env python3

import json
import sys

from PySide6.QtCore import SLOT, QSize, Slot, Qt, QUrl
from PySide6.QtDBus import (
    QDBusConnection,
    QDBusInterface,
    QDBusPendingCallWatcher,
    QDBusServiceWatcher,
)
from PySide6.QtGui import QFont, QPixmap
from PySide6.QtWidgets import (
    QApplication,
    QButtonGroup,
    QFrame,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QSizePolicy,
    QVBoxLayout,
    QWidget,
)


APP_ID = "korsa-dash"
APP_NAME = "Korsa Dash"
FONT_FAMILY = "Aurebesh"
DBUS_SERVICE = "com.matthewcash.Korsa"
DBUS_PATH = "/com/matthewcash/Korsa"
DBUS_INTERFACE = DBUS_SERVICE
DBUS_PROTOCOL_VERSION = 1


class PreviewButton(QPushButton):
    def __init__(self, text, image, image_size):
        super().__init__()
        self.setText("")

        picture = QLabel()
        picture.setAlignment(Qt.AlignmentFlag.AlignCenter)
        picture.setAttribute(Qt.WidgetAttribute.WA_TransparentForMouseEvents)
        pixmap = QPixmap(image)
        if not pixmap.isNull():
            picture.setPixmap(pixmap.scaled(
                image_size,
                Qt.AspectRatioMode.KeepAspectRatio,
                Qt.TransformationMode.SmoothTransformation,
            ))

        caption = QLabel(text)
        caption.setObjectName("choiceCaption")
        caption.setAlignment(
            Qt.AlignmentFlag.AlignHCenter | Qt.AlignmentFlag.AlignBottom
        )
        caption.setWordWrap(True)
        caption.setAttribute(Qt.WidgetAttribute.WA_TransparentForMouseEvents)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(5, 5, 5, 5)
        layout.setSpacing(2)
        layout.addWidget(picture, 1)
        layout.addWidget(caption, 0)


class ChoiceRow(QFrame):
    def __init__(
        self,
        slots,
        button_height,
        icon_size=None,
        font_family=None,
    ):
        super().__init__()
        self.setObjectName("choiceRow")
        self.items = []
        self.selected = None
        self.icon_size = icon_size
        self.font_family = font_family
        self.slots = slots
        self.button_height = button_height

        self.buttons_layout = QHBoxLayout()
        self.buttons_layout.setContentsMargins(0, 0, 0, 0)
        self.buttons_layout.setSpacing(9)
        self.group = QButtonGroup(self)
        self.group.setExclusive(True)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.addLayout(self.buttons_layout)

    def set_items(self, items):
        previous = self.selected
        while self.buttons_layout.count():
            item = self.buttons_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()
        for button in self.group.buttons():
            self.group.removeButton(button)

        self.items = items
        ids = {item["id"] for item in items}
        self.selected = previous if previous in ids else (items[0]["id"] if items else None)
        for item in items:
            image = QUrl(item.get("image", "")).toLocalFile()
            button = (
                PreviewButton(item["name"], image, self.icon_size)
                if self.icon_size
                else QPushButton(item["name"])
            )
            button.setObjectName("choice")
            button.setCheckable(True)
            button.setChecked(item["id"] == self.selected)
            button.setFocusPolicy(Qt.FocusPolicy.NoFocus)
            button.setMinimumWidth(0)
            button.setSizePolicy(
                QSizePolicy.Policy.Expanding,
                QSizePolicy.Policy.Preferred,
            )
            button.setToolTip(item["name"])
            if self.font_family:
                choice_font = QFont(self.font_family, 14)
                choice_font.setBold(True)
                button.setFont(choice_font)
            button.setMinimumHeight(self.button_height)
            button.clicked.connect(lambda _checked, item_id=item["id"]: self.select(item_id))
            self.group.addButton(button)
            self.buttons_layout.addWidget(button, 1)

        for _ in range(len(items), self.slots):
            placeholder = QPushButton("Set in Korsa")
            placeholder.setObjectName("choice")
            placeholder.setEnabled(False)
            placeholder.setFocusPolicy(Qt.FocusPolicy.NoFocus)
            placeholder.setMinimumWidth(0)
            placeholder.setSizePolicy(
                QSizePolicy.Policy.Expanding,
                QSizePolicy.Policy.Preferred,
            )
            placeholder.setMinimumHeight(self.button_height)
            self.buttons_layout.addWidget(placeholder, 1)

    def select(self, item_id):
        self.selected = item_id


class Dashboard(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle(APP_NAME)
        self.setObjectName("dashboard")
        self.options_valid = False
        self.race_running = False
        self.status_available = False
        self.stopping = False
        self.call_in_progress = False
        self.options_refresh_pending = False
        self.options_request_active = False
        self.status_request_active = False
        self.dbus_interface = None

        self.car_row = ChoiceRow(3, 128, QSize(158, 88))
        self.track_row = ChoiceRow(3, 128, QSize(104, 88))
        self.time_row = ChoiceRow(4, 42, font_family=FONT_FAMILY)

        self.launch = QPushButton("LOADING")
        self.launch.setObjectName("launch")
        self.launch.setMinimumHeight(82)
        self.launch.setEnabled(False)
        self.launch.setFocusPolicy(Qt.FocusPolicy.NoFocus)
        self.launch.setAutoDefault(False)
        self.launch.setDefault(False)
        launch_font = QFont(FONT_FAMILY, 22)
        launch_font.setBold(True)
        self.launch.setFont(launch_font)
        self.launch.clicked.connect(self.start_race)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(9)
        layout.addWidget(self.car_row, 3)
        layout.addWidget(self.track_row, 3)
        layout.addWidget(self.time_row, 1)
        layout.addWidget(self.launch)

        self.dbus = QDBusConnection.sessionBus()
        watch_flags = (
            QDBusServiceWatcher.WatchModeFlag.WatchForRegistration
            | QDBusServiceWatcher.WatchModeFlag.WatchForUnregistration
        )
        self.service_watcher = QDBusServiceWatcher(
            DBUS_SERVICE, self.dbus, watch_flags, self
        )
        self.service_watcher.serviceRegistered.connect(self.service_registered)
        self.service_watcher.serviceUnregistered.connect(self.service_unregistered)
        self.dbus.connect(
            DBUS_SERVICE,
            DBUS_PATH,
            DBUS_INTERFACE,
            "DashboardOptionsChanged",
            self,
            SLOT("dashboard_options_changed()"),
        )
        self.dbus.connect(
            DBUS_SERVICE,
            DBUS_PATH,
            DBUS_INTERFACE,
            "RaceRunningChanged",
            self,
            SLOT("race_running_changed(bool)"),
        )
        self.connect_service()

    def connect_service(self):
        interface = QDBusInterface(
            DBUS_SERVICE, DBUS_PATH, DBUS_INTERFACE, self.dbus, self
        )
        if not interface.isValid():
            interface.deleteLater()
            self.service_unavailable("Korsa is not running")
            return
        if self.dbus_interface:
            self.dbus_interface.deleteLater()
        self.dbus_interface = interface
        self.dbus_call("GetProtocolVersion", [], self.protocol_received)

    @Slot(str)
    def service_registered(self, _service):
        self.connect_service()

    @Slot(str)
    def service_unregistered(self, _service):
        self.dbus_interface = None
        self.service_unavailable("Korsa stopped")

    def service_unavailable(self, detail):
        self.status_available = False
        self.options_valid = False
        self.options_request_active = False
        self.status_request_active = False
        self.call_in_progress = False
        self.set_launch_message("UNAVAILABLE", detail)
        self.update_launch_button()

    def dbus_call(self, method, arguments, callback):
        if not self.dbus_interface or not self.dbus_interface.isValid():
            callback(None, "Korsa is not running")
            return
        pending = self.dbus_interface.asyncCallWithArgumentList(method, arguments)
        watcher = QDBusPendingCallWatcher(pending, self)
        watcher.finished.connect(
            lambda finished: self.dbus_call_finished(finished, callback)
        )

    def dbus_call_finished(self, watcher, callback):
        if watcher.isError():
            callback(None, watcher.error().message())
        else:
            callback(watcher.reply().arguments(), None)
        watcher.deleteLater()

    def protocol_received(self, arguments, error):
        if error:
            self.service_unavailable(error)
            return
        version = arguments[0] if arguments else None
        if version != DBUS_PROTOCOL_VERSION:
            self.service_unavailable(
                f"Unsupported Korsa D-Bus protocol version: {version}"
            )
            return
        self.request_options_refresh()
        self.refresh_status()

    @Slot()
    def dashboard_options_changed(self):
        self.request_options_refresh()

    @Slot(bool)
    def race_running_changed(self, running):
        self.status_available = True
        self.set_race_running(running)

    def update_launch_button(self):
        self.launch.setEnabled(
            self.status_available
            and not self.call_in_progress
            and (self.race_running or self.options_valid)
        )

    def set_launch_message(self, text, detail=""):
        self.launch.setText(text)
        self.launch.setToolTip(detail)

    def set_race_running(self, running):
        if self.race_running == running:
            if (
                self.launch.text() in ("LOADING", "UNAVAILABLE")
                and (running or self.options_valid)
            ):
                self.set_launch_message("STOP" if running else "START")
            self.update_launch_button()
            return
        self.race_running = running
        self.set_launch_message("STOP" if running else "START")
        self.launch.setProperty("running", running)
        self.launch.style().unpolish(self.launch)
        self.launch.style().polish(self.launch)
        self.launch.update()
        self.update_launch_button()

    def refresh_status(self):
        if not self.status_request_active and not self.call_in_progress:
            self.status_request_active = True
            self.dbus_call("GetRaceRunning", [], self.status_finished)

    def status_finished(self, arguments, error):
        self.status_request_active = False
        if error:
            self.status_available = False
            self.set_launch_message("UNAVAILABLE", error)
            self.update_launch_button()
            return
        if arguments and isinstance(arguments[0], bool):
            self.status_available = True
            self.set_race_running(arguments[0])
        else:
            self.status_available = False
            self.set_launch_message("UNAVAILABLE", "Race status unavailable")
            self.update_launch_button()

    def request_options_refresh(self):
        self.options_refresh_pending = True
        self.refresh_options()

    def refresh_options(self):
        if (
            self.options_refresh_pending
            and not self.options_request_active
            and not self.call_in_progress
        ):
            self.options_refresh_pending = False
            self.options_request_active = True
            self.dbus_call("GetDashboardOptions", [], self.options_finished)

    def options_finished(self, arguments, error):
        self.options_request_active = False
        if error:
            self.options_valid = False
            self.set_launch_message("ERROR", error)
            self.update_launch_button()
            self.refresh_options()
            return
        try:
            options = json.loads(arguments[0])
            self.car_row.set_items([
                {"id": item["id"], "name": item["name"], "image": item["preview"]}
                for item in options["cars"]
            ])
            self.track_row.set_items([
                {
                    "id": item["id"],
                    "name": item["name"],
                    "image": item["outline"] or item["preview"],
                }
                for item in options["tracks"]
            ])
            self.time_row.set_items([
                {"id": str(item["minutes"]), "name": item["name"]}
                for item in options["times"]
            ])
        except (KeyError, TypeError, ValueError, json.JSONDecodeError):
            self.options_valid = False
            self.set_launch_message("ERROR", "Korsa returned invalid dashboard data")
            self.update_launch_button()
            self.refresh_options()
            return

        complete = all((self.car_row.selected, self.track_row.selected, self.time_row.selected))
        self.options_valid = bool(complete)
        if not self.call_in_progress and self.status_available:
            self.set_launch_message("STOP" if self.race_running else "START")
        self.update_launch_button()
        self.refresh_options()

    def start_race(self):
        if self.call_in_progress:
            return
        self.call_in_progress = True
        if self.race_running:
            self.stopping = True
            self.launch.setEnabled(False)
            self.set_launch_message("STOPPING")
            self.dbus_call("StopRace", [], self.launch_finished)
            return
        if not self.options_valid:
            self.call_in_progress = False
            return
        self.stopping = False
        self.launch.setEnabled(False)
        self.set_launch_message("STARTING")
        self.dbus_call(
            "LaunchDashboardSession",
            [
                self.car_row.selected,
                self.track_row.selected,
                int(self.time_row.selected or "0"),
            ],
            self.launch_finished,
        )

    def launch_finished(self, _arguments, error):
        self.call_in_progress = False
        if not error:
            self.set_race_running(not self.stopping)
        else:
            self.set_launch_message("ERROR", error)
        self.update_launch_button()
        self.request_options_refresh()
        self.refresh_status()


def main():
    app = QApplication(sys.argv)
    app.setApplicationName(APP_ID)
    app.setDesktopFileName(APP_ID)
    app.setStyleSheet("""
        QWidget#dashboard { background: transparent; }
        QFrame#choiceRow {
            background: transparent;
            border: none;
        }
        QLabel { background: transparent; border: none; }
        QPushButton#choice {
            background: rgba(64, 64, 64, 48);
            border: none;
            border-bottom: 6px solid transparent;
            padding: 7px 7px 3px 7px;
        }
        QPushButton#choice:hover {
            background: rgba(74, 74, 74, 160);
        }
        QPushButton#choice:checked {
            background: rgba(64, 64, 64, 48);
            color: palette(text);
            border-bottom: 6px solid palette(highlight);
        }
        QPushButton#choice:checked:hover {
            background: rgba(74, 74, 74, 160);
        }
        QPushButton#choice:disabled {
            color: rgba(145, 145, 145, 150);
        }
        QPushButton#launch {
            background: rgba(64, 64, 64, 48);
            color: palette(text);
            border: none;
        }
        QPushButton#launch:hover { background: rgba(74, 74, 74, 160); }
        QPushButton#launch:focus {
            border: none;
            outline: none;
        }
        QPushButton#launch[running="true"] {
            background: palette(highlight);
            color: palette(highlighted-text);
        }
        QPushButton#launch[running="true"]:hover {
            background: palette(highlight);
        }
        QPushButton#launch:disabled {
            background: rgba(64, 64, 64, 32);
            color: rgba(145, 145, 145, 150);
        }
    """)

    dashboard = Dashboard()
    dashboard.setWindowFlag(Qt.WindowType.FramelessWindowHint)
    dashboard.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
    dashboard.resize(620, 670)
    dashboard.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
