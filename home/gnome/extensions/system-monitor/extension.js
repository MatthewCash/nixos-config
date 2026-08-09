import Clutter from 'gi://Clutter';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import St from 'gi://St';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const REFRESH_INTERVAL_SECONDS = 1;
const CPU_BAR_HEIGHT = 14;

function readFile(path) {
    return new Promise((resolve, reject) => {
        Gio.File.new_for_path(path).load_contents_async(null, (file, result) => {
            try {
                const [ok, contents] = file.load_contents_finish(result);
                if (!ok)
                    throw new Error(`Could not read ${path}`);

                resolve(new TextDecoder().decode(contents).trim());
            } catch (error) {
                reject(error);
            }
        });
    });
}

async function readOptionalNumber(path) {
    try {
        const value = Number(await readFile(path));
        return Number.isFinite(value) ? value : null;
    } catch (_) {
        return null;
    }
}

function findBattery() {
    const powerSupplies = Gio.File.new_for_path('/sys/class/power_supply');

    try {
        const entries = powerSupplies.enumerate_children(
            'standard::name', Gio.FileQueryInfoFlags.NONE, null);
        let entry;

        while ((entry = entries.next_file(null)) !== null) {
            const path = `${powerSupplies.get_path()}/${entry.get_name()}`;
            try {
                const [, contents] = Gio.File.new_for_path(`${path}/type`).load_contents(null);
                if (new TextDecoder().decode(contents).trim() === 'Battery') {
                    entries.close(null);
                    return path;
                }
            } catch (_) {
                // Ignore power supplies that disappear while being inspected.
            }
        }

        entries.close(null);
    } catch (_) {
        // Systems without a battery may not expose this directory.
    }

    return null;
}

export default class SystemMonitorExtension extends Extension {
    enable() {
        this._batteryPath = findBattery();
        this._previousCpu = new Map();
        this._batteryMenuItems = [];
        this._cpuMenuItems = [];

        [this._batteryIndicator, this._batteryLabel] = this._createIndicator('-- W', true);
        this._cpuIndicator = new PanelMenu.Button(0.0, 'CPU Usage', false);
        this._cpuBarsBox = new St.BoxLayout({
            y_align: Clutter.ActorAlign.CENTER,
            translation_y: -2,
            style_class: 'system-monitor-cpu-bars',
        });
        this._cpuBars = [];
        this._cpuIndicator.add_child(this._cpuBarsBox);
        [this._memoryIndicator, this._memoryLabel] = this._createIndicator('--%');
        Main.panel.addToStatusArea(`${this.uuid}-battery`, this._batteryIndicator, 0, 'right');
        Main.panel.addToStatusArea(`${this.uuid}-cpu`, this._cpuIndicator, 1, 'right');
        Main.panel.addToStatusArea(`${this.uuid}-memory`, this._memoryIndicator, 2, 'right');

        this._refresh();
        this._timer = GLib.timeout_add_seconds(
            GLib.PRIORITY_DEFAULT,
            REFRESH_INTERVAL_SECONDS,
            () => {
                this._refresh();
                return GLib.SOURCE_CONTINUE;
            });
    }

    disable() {
        if (this._timer) {
            GLib.source_remove(this._timer);
            this._timer = null;
        }

        this._batteryIndicator?.destroy();
        this._cpuIndicator?.destroy();
        this._memoryIndicator?.destroy();
        this._batteryIndicator = null;
        this._cpuIndicator = null;
        this._memoryIndicator = null;
        this._batteryLabel = null;
        this._cpuBarsBox = null;
        this._cpuBars = null;
        this._memoryLabel = null;
        this._previousCpu = null;
        this._batteryMenuItems = null;
        this._cpuMenuItems = null;
    }

    _createIndicator(text, hasMenu = false) {
        const indicator = new PanelMenu.Button(0.0, this.metadata.name, !hasMenu);
        const label = new St.Label({
            text,
            y_align: Clutter.ActorAlign.CENTER,
            style_class: 'system-monitor-label',
        });
        indicator.add_child(label);
        return [indicator, label];
    }

    _createMenuRow(menu) {
        const item = new PopupMenu.PopupBaseMenuItem({
            reactive: false,
            can_focus: false,
        });
        const key = new St.Label({style_class: 'system-monitor-menu-key'});
        const value = new St.Label({
            x_align: Clutter.ActorAlign.END,
            x_expand: true,
            style_class: 'system-monitor-menu-value',
        });
        item.add_child(key);
        item.add_child(value);
        menu.addMenuItem(item);
        return {key, value};
    }

    async _refresh() {
        try {
            const [cpuText, memoryText, batteryInfo] = await Promise.all([
                readFile('/proc/stat'),
                readFile('/proc/meminfo'),
                this._readBatteryInfo(),
            ]);

            const cpuUsage = this._calculateCpuUsage(cpuText);
            const memoryUsage = this._calculateMemoryUsage(memoryText);
            const battery = batteryInfo?.watts === null || batteryInfo === null
                ? '-- W'
                : `${batteryInfo.status === 'Charging' ? '+' : ''}${batteryInfo.watts.toFixed(1)} W`;

            if (this._batteryLabel) {
                this._batteryLabel.text = battery;
                this._memoryLabel.text = `${memoryUsage}%`;
                this._updateBatteryMenu(batteryInfo);
                this._updateCpuBars(cpuUsage.cores);
                this._updateCpuMenu(cpuUsage.normalized, cpuUsage.cores);
            }
        } catch (error) {
            console.error(`${this.metadata.name}: ${error.message}`);
        }
    }

    async _readBatteryInfo() {
        if (!this._batteryPath)
            return null;

        const path = this._batteryPath;
        const [
            status,
            powerNow,
            currentNow,
            voltageNow,
            voltageDesign,
            energyNow,
            energyFull,
            energyDesign,
            chargeNow,
            chargeFull,
            chargeDesign,
        ] = await Promise.all([
            readFile(`${path}/status`).catch(() => 'Unknown'),
            readOptionalNumber(`${path}/power_now`),
            readOptionalNumber(`${path}/current_now`),
            readOptionalNumber(`${path}/voltage_now`),
            readOptionalNumber(`${path}/voltage_min_design`),
            readOptionalNumber(`${path}/energy_now`),
            readOptionalNumber(`${path}/energy_full`),
            readOptionalNumber(`${path}/energy_full_design`),
            readOptionalNumber(`${path}/charge_now`),
            readOptionalNumber(`${path}/charge_full`),
            readOptionalNumber(`${path}/charge_full_design`),
        ]);
        const chargeToMWh = (energy, charge, voltage) => energy !== null
            ? energy / 1_000
            : charge !== null && voltage !== null
                ? charge * voltage / 1_000_000_000
                : null;
        const nominalVoltage = voltageDesign ?? voltageNow;

        return {
            status,
            watts: powerNow !== null
                ? powerNow / 1_000_000
                : currentNow !== null && voltageNow !== null
                    ? currentNow * voltageNow / 1_000_000_000_000
                    : null,
            currentMWh: chargeToMWh(energyNow, chargeNow, voltageNow),
            fullMWh: chargeToMWh(energyFull, chargeFull, nominalVoltage),
            designMWh: chargeToMWh(energyDesign, chargeDesign, nominalVoltage),
        };
    }

    _updateBatteryMenu(info) {
        if (this._batteryMenuItems.length === 0) {
            this._batteryMenuItems = Array.from(
                {length: 5}, () => this._createMenuRow(this._batteryIndicator.menu));
        }

        const formatEnergy = value => value === null || value === undefined
            ? '--'
            : `${Math.round(value).toLocaleString()} mWh`;
        const health = info?.fullMWh !== null && info?.designMWh
            ? `${Math.round(100 * info.fullMWh / info.designMWh)}%`
            : '--';
        const rows = [
            ['State', info?.status ?? 'Unavailable'],
            ['Current', formatEnergy(info?.currentMWh)],
            ['Full', formatEnergy(info?.fullMWh)],
            ['Design', formatEnergy(info?.designMWh)],
            ['Health', health],
        ];

        this._batteryMenuItems.forEach((item, index) => {
            [item.key.text, item.value.text] = rows[index];
        });
    }

    _calculateCpuUsage(cpuText) {
        const snapshots = cpuText.split('\n')
            .filter(line => /^cpu(?:\d+)?\s/.test(line))
            .map(line => {
                const [name, ...values] = line.trim().split(/\s+/);
                const times = values.map(Number);
                return {
                    name,
                    idle: times[3] + (times[4] ?? 0),
                    total: times.reduce((sum, value) => sum + value, 0),
                };
            });

        const usage = snapshots.map(current => {
            const previous = this._previousCpu.get(current.name);
            this._previousCpu.set(current.name, current);
            if (!previous)
                return 0;

            const totalDelta = current.total - previous.total;
            const idleDelta = current.idle - previous.idle;
            return totalDelta > 0
                ? 100 * (totalDelta - idleDelta) / totalDelta
                : 0;
        });
        const cores = usage.slice(1).map(Math.round);

        return {
            total: usage.length > 0 ? Math.round(usage[0] * cores.length) : 0,
            normalized: usage.length > 0 ? Math.round(usage[0]) : 0,
            cores,
        };
    }

    _updateCpuMenu(total, cores) {
        if (this._cpuMenuItems.length !== cores.length + 1) {
            this._cpuIndicator.menu.removeAll();
            this._cpuMenuItems = Array.from(
                {length: cores.length + 1}, () => this._createMenuRow(this._cpuIndicator.menu));
        }

        this._cpuMenuItems[0].key.text = 'Total';
        this._cpuMenuItems[0].value.text = `${total}% / 100%`;
        cores.forEach((usage, index) => {
            this._cpuMenuItems[index + 1].key.text = `CPU ${index}`;
            this._cpuMenuItems[index + 1].value.text = `${usage}%`;
        });
    }

    _updateCpuBars(cores) {
        if (this._cpuBars.length !== cores.length) {
            this._cpuBarsBox.destroy_all_children();
            this._cpuBars = cores.map(() => {
                const slot = new St.Widget({
                    layout_manager: new Clutter.FixedLayout(),
                    width: 3,
                    height: CPU_BAR_HEIGHT,
                });
                const fill = new St.Widget({
                    style_class: 'system-monitor-cpu-bar-fill',
                });
                slot.add_child(fill);
                this._cpuBarsBox.add_child(slot);
                return fill;
            });
        }

        this._cpuBars.forEach((bar, index) => {
            const height = Math.round(CPU_BAR_HEIGHT * cores[index] / 100);
            bar.set_size(3, height);
            bar.set_position(0, CPU_BAR_HEIGHT - height);
        });
    }

    _calculateMemoryUsage(memoryText) {
        const values = Object.fromEntries(memoryText.split('\n').map(line => {
            const [key, value] = line.split(':');
            return [key, Number.parseInt(value, 10)];
        }));

        return Math.round(100 * (values.MemTotal - values.MemAvailable) / values.MemTotal);
    }
}
