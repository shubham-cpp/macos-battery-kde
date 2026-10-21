/*
 * SPDX-FileCopyrightText: 2026 Rifki
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.battery

RowLayout {
    id: row

    required property var model

    readonly property bool isPowerSupply: !!model.IsPowerSupply
    readonly property bool present: model.PluggedIn !== false
    readonly property int percentValue: {
        const p = model.Percent;
        return typeof p === "number" ? p : -1;
    }
    readonly property int healthValue: {
        const c = Number(model.Capacity);
        return (isFinite(c) && c > 0) ? Math.round(c) : 0;
    }
    readonly property string prettyName: model.PrettyName || ""
    readonly property string type: model.Type || ""
    readonly property bool charging: model.ChargeState === BatteryControlModel.Charging

    spacing: Kirigami.Units.smallSpacing
    visible: !isPowerSupply && present

    Kirigami.Icon {
        Layout.preferredWidth: Kirigami.Units.iconSizes.small
        Layout.preferredHeight: Kirigami.Units.iconSizes.small
        source: root.deviceIcon(row.type)
    }

    PlasmaComponents3.Label {
        Layout.fillWidth: true
        text: row.prettyName
        elide: Text.ElideRight
        textFormat: Text.PlainText
    }

    PlasmaComponents3.Label {
        text: {
            if (row.percentValue < 0) {
                return row.healthValue > 0
                    ? i18n("(%1% health)", row.healthValue)
                    : i18nc("battery percentage unknown", "—");
            }
            if (row.healthValue > 0) {
                return i18n("%1% (%2% health)", Math.round(row.percentValue), row.healthValue);
            }
            return i18n("%1%", Math.round(row.percentValue));
        }
        opacity: 0.7
        textFormat: Text.PlainText
    }

    BatteryIcon {
        Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 0.7)
        Layout.preferredWidth: Math.round(Layout.preferredHeight * root.iconAspect)
        percent: Math.max(0, row.percentValue)
        present: row.percentValue >= 0
        charging: row.charging
        showPercentInside: false
        colorize: root.colorFill
        lowThreshold: root.lowThreshold
        foreground: Kirigami.Theme.textColor
        knockout: Kirigami.Theme.backgroundColor
    }
}
