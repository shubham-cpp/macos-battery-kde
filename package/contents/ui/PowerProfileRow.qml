/*
 * SPDX-FileCopyrightText: 2026 Rifki
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: block

    required property var profiles

    readonly property var available: profiles.profiles || []
    readonly property int activeIndex: {
        const i = available.indexOf(profiles.activeProfile);
        return i >= 0 ? i : 0;
    }

    readonly property string activeLabel: {
        switch (profiles.activeProfile) {
        case "power-saver": return i18n("Power Save");
        case "balanced": return i18n("Balanced");
        case "performance": return i18n("Performance");
        default: return profiles.activeProfile || i18n("Not available");
        }
    }

    readonly property bool hasDaemon: profiles.isPowerProfileDaemonInstalled && available.length > 0
    readonly property bool hasTlp: profiles.isTlpInstalled

    visible: root.showPowerProfile && (hasDaemon || hasTlp)
    spacing: Kirigami.Units.smallSpacing

    RowLayout {
        Layout.fillWidth: true

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            text: i18n("Power Profile")
            font.weight: Font.DemiBold
            textFormat: Text.PlainText
        }

        PlasmaComponents3.Label {
            text: block.hasTlp && !block.hasDaemon ? i18n("TLP") : block.activeLabel
            opacity: 0.6
            textFormat: Text.PlainText
        }
    }

    PlasmaComponents3.Label {
        Layout.fillWidth: true
        visible: block.hasTlp && !block.hasDaemon
        wrapMode: Text.WordWrap
        font: Kirigami.Theme.smallFont
        opacity: 0.75
        text: i18n("Power profiles are managed by TLP.")
        textFormat: Text.PlainText
    }

    RowLayout {
        Layout.fillWidth: true
        visible: block.hasDaemon
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
            source: "battery-profile-powersave-symbolic"
        }

        PlasmaComponents3.Slider {
            id: slider
            Layout.fillWidth: true
            from: 0
            to: Math.max(0, block.available.length - 1)
            stepSize: 1
            snapMode: PlasmaComponents3.Slider.SnapAlways
            value: block.activeIndex
            enabled: block.available.length > 1
            Accessible.name: i18n("Power Profile")
            Accessible.description: block.activeLabel

            onMoved: {
                const next = block.available[Math.round(slider.value)];
                if (next && next !== block.profiles.activeProfile) {
                    block.profiles.isSilent = root.expanded;
                    block.profiles.setProfile(next);
                }
            }

            Connections {
                target: block.profiles
                function onActiveProfileChanged() {
                    slider.value = block.activeIndex;
                }
            }
        }

        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
            source: "battery-profile-performance-symbolic"
        }
    }
}
