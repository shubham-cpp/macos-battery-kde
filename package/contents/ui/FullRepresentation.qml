/*
 * SPDX-FileCopyrightText: 2026 Rifki
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: full

    readonly property int pad: Kirigami.Units.largeSpacing
    readonly property int maxPopupHeight: Kirigami.Units.gridUnit * 28
    readonly property int contentHeight: content.implicitHeight + pad * 2

    // Capacity is a model role. data(index, BatteryControlModel.Capacity) does
    // not resolve that role id, so read it from Repeater delegates instead.
    property int packHealth: 0

    function refreshPackHealth() {
        let h = 0;
        for (let i = 0; i < packProbe.count; ++i) {
            const item = packProbe.itemAt(i);
            if (item && item.isPack && item.health > 0) {
                h = item.health;
                break;
            }
        }
        packHealth = h;
    }

    Repeater {
        id: packProbe
        model: root.batteries
        Item {
            required property var model
            width: 0
            height: 0
            visible: false
            readonly property bool isPack: !!model.IsPowerSupply
            readonly property int health: {
                const c = Number(model.Capacity);
                return (isFinite(c) && c > 0) ? Math.round(c) : 0;
            }
            onIsPackChanged: full.refreshPackHealth()
            onHealthChanged: full.refreshPackHealth()
            Component.onCompleted: full.refreshPackHealth()
            Component.onDestruction: Qt.callLater(full.refreshPackHealth)
        }
    }

    implicitWidth: Kirigami.Units.gridUnit * 17
    implicitHeight: Math.min(contentHeight, maxPopupHeight)

    Layout.minimumWidth: Kirigami.Units.gridUnit * 13
    Layout.preferredWidth: Kirigami.Units.gridUnit * 17
    Layout.maximumWidth: Kirigami.Units.gridUnit * 24
    Layout.minimumHeight: Math.min(contentHeight, Kirigami.Units.gridUnit * 12)
    Layout.preferredHeight: implicitHeight
    Layout.maximumHeight: maxPopupHeight

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: full.contentHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        ColumnLayout {
            id: content
            x: full.pad
            y: full.pad
            width: flick.width - full.pad * 2
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true

                Kirigami.Heading {
                    Layout.fillWidth: true
                    level: 4
                    text: i18n("Battery")
                    font.weight: Font.DemiBold
                    textFormat: Text.PlainText
                }

                PlasmaComponents3.Label {
                    text: root.powerSourceText
                    opacity: 0.6
                    textFormat: Text.PlainText
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.largeSpacing

                BatteryIcon {
                    Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 1.9)
                    Layout.preferredWidth: Math.round(Layout.preferredHeight * root.iconAspect)
                    percent: root.percent
                    present: root.hasBattery
                    charging: root.charging
                    showPercentInside: false
                    colorize: root.colorFill
                    lowThreshold: root.lowThreshold
                    foreground: Kirigami.Theme.textColor
                    knockout: Kirigami.Theme.backgroundColor
                }

                Text {
                    Layout.fillWidth: true
                    text: root.hasBattery ? i18n("%1%", Math.round(root.percent)) : "–"
                    color: Kirigami.Theme.textColor
                    font.family: Kirigami.Theme.defaultFont.family
                    font.pixelSize: Math.round(Kirigami.Units.gridUnit * 2.2)
                    font.weight: Font.Light
                    textFormat: Text.PlainText
                }
            }

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                text: full.packHealth > 0
                    ? i18n("%1 (%2% health)", root.statusText, full.packHealth)
                    : root.statusText
                opacity: 0.75
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
            }

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                visible: root.pluggedIn && root.chargeStopThreshold > 0 && root.chargeStopThreshold < 100
                wrapMode: Text.WordWrap
                font: Kirigami.Theme.smallFont
                opacity: 0.75
                text: i18n("Charging is limited to about %1%.", root.chargeStopThreshold)
                textFormat: Text.PlainText
            }

            Kirigami.Separator {
                visible: root.showDeviceList
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing
            }

            ColumnLayout {
                id: deviceList
                visible: root.showDeviceList
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Repeater {
                    model: root.batteries
                    DeviceRow {}
                }
            }

            Kirigami.Separator {
                visible: profileRow.visible
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing
            }

            PowerProfileRow {
                id: profileRow
                Layout.fillWidth: true
                profiles: root.profiles
            }

            Kirigami.Separator {
                visible: sleepBlock.visible
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing
            }

            SleepBlock {
                id: sleepBlock
                Layout.fillWidth: true
                inhibitions: root.inhibitions
            }
        }
    }
}
