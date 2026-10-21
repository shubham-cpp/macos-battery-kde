/*
 * SPDX-FileCopyrightText: 2026 Rifki
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import org.kde.coreaddons as KCoreAddons
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.battery
import org.kde.plasma.private.batterymonitor

PlasmoidItem {
    id: root

    BatteryControlModel {
        id: batteryControl
    }

    InhibitionControl {
        id: inhibitionControl
    }

    PowerProfilesControl {
        id: powerProfilesControl
    }

    readonly property var batteries: batteryControl
    readonly property var inhibitions: inhibitionControl
    readonly property var profiles: powerProfilesControl

    readonly property bool hasBattery: batteryControl.hasCumulative || batteryControl.hasInternalBatteries
    readonly property real percent: batteryControl.percent
    readonly property bool pluggedIn: batteryControl.pluggedIn
    readonly property bool charging: batteryControl.state === BatteryControlModel.Charging
    readonly property bool fullyCharged: batteryControl.state === BatteryControlModel.FullyCharged
    readonly property real remainingMsec: batteryControl.smoothedRemainingMsec
    readonly property int chargeStopThreshold: batteryControl.chargeStopThreshold

    property int extraDeviceCount: 0

    readonly property int percentPosition: Plasmoid.configuration.percentPosition
    readonly property real iconScale: Plasmoid.configuration.iconSize / 100
    readonly property real iconAspect: Plasmoid.configuration.iconAspect / 100
    readonly property real textScale: Plasmoid.configuration.textSize / 100
    readonly property bool colorFill: Plasmoid.configuration.colorFill
    readonly property int lowThreshold: Plasmoid.configuration.lowThreshold
    readonly property bool showDeviceList: Plasmoid.configuration.showDeviceList
    readonly property bool showPowerProfile: Plasmoid.configuration.showPowerProfile
    readonly property bool showSleepBlock: Plasmoid.configuration.showSleepBlock

    readonly property string inhibitReason: i18n("The battery applet has enabled suppressing sleep and screen locking")

    function formatDuration(msec) {
        if (msec <= 0) {
            return "";
        }
        return KCoreAddons.Format.formatDuration(msec, KCoreAddons.FormatTypes.HideSeconds);
    }

    function deviceIcon(type) {
        switch (type) {
        case "Mouse": return "input-mouse";
        case "Keyboard": return "input-keyboard";
        case "Phone": return "phone";
        case "GamingInput": return "input-gaming";
        case "Headset":
        case "Headphone":
        case "Headphones": return "audio-headphones";
        case "Ups": return "battery-ups";
        case "Battery": return "computer-laptop";
        case "Bluetooth": return "preferences-system-bluetooth";
        case "Touchpad": return "input-touchpad";
        default: return "battery";
        }
    }

    function refreshDevices() {
        let extra = 0;
        for (let i = 0; i < batteryControl.count; ++i) {
            const idx = batteryControl.index(i, 0);
            if (!batteryControl.data(idx, BatteryControlModel.IsPowerSupply)
                && batteryControl.data(idx, BatteryControlModel.PluggedIn) !== false) {
                extra += 1;
            }
        }
        extraDeviceCount = extra;
    }

    function toggleSleepBlock() {
        inhibitionControl.isSilent = expanded;
        if (inhibitionControl.isManuallyInhibited) {
            inhibitionControl.uninhibit();
        } else {
            inhibitionControl.inhibit(inhibitReason);
        }
    }

    function cyclePowerProfile(steps) {
        if (!powerProfilesControl.isPowerProfileDaemonInstalled) {
            return;
        }
        const list = powerProfilesControl.profiles;
        if (!list || list.length === 0 || steps === 0) {
            return;
        }
        const current = list.indexOf(powerProfilesControl.activeProfile);
        const next = Math.max(0, Math.min(list.length - 1, (current < 0 ? 0 : current) + steps));
        const profile = list[next];
        if (profile && profile !== powerProfilesControl.activeProfile) {
            powerProfilesControl.isSilent = expanded;
            powerProfilesControl.setProfile(profile);
        }
    }

    readonly property string statusText: {
        if (!hasBattery) {
            return i18n("No battery found");
        }
        if (fullyCharged) {
            return i18n("Fully charged");
        }
        const duration = formatDuration(remainingMsec);
        if (charging) {
            return duration ? i18n("Charging, %1 until full", duration) : i18n("Charging");
        }
        if (pluggedIn) {
            return i18n("Plugged in, not charging");
        }
        return duration ? i18n("%1 remaining", duration) : i18n("On battery");
    }

    readonly property string powerSourceText: pluggedIn ? i18n("Power Adapter") : i18n("Battery")

    Connections {
        target: batteryControl
        function onDataChanged() { root.refreshDevices(); }
        function onModelReset() { root.refreshDevices(); }
        function onRowsInserted() { root.refreshDevices(); }
        function onRowsRemoved() { root.refreshDevices(); }
    }

    Component.onCompleted: refreshDevices()

    Plasmoid.icon: "battery"
    Plasmoid.status: {
        if (inhibitionControl.isManuallyInhibited) {
            return PlasmaCore.Types.ActiveStatus;
        }
        if (hasBattery && (charging || !pluggedIn)) {
            return PlasmaCore.Types.ActiveStatus;
        }
        return PlasmaCore.Types.PassiveStatus;
    }

    toolTipMainText: hasBattery ? i18n("Battery: %1%", Math.round(percent)) : i18n("Battery")
    toolTipSubText: {
        const parts = [statusText];
        if (inhibitionControl.isManuallyInhibited) {
            parts.push(i18n("Sleep and screen locking are blocked. Middle-click to allow them again."));
        } else {
            parts.push(i18n("Middle-click to block sleep and screen locking."));
        }
        return parts.join("\n");
    }

    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 6

    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
}
