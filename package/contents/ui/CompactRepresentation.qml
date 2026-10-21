/*
 * SPDX-FileCopyrightText: 2026 Rifki
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

MouseArea {
    id: compact

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    // Automatic size for the panel thickness, then scaled by the user's setting.
    // The battery never grows past the panel thickness.
    readonly property real autoHeight: vertical
        ? Math.min(width * 0.8, Kirigami.Units.gridUnit * 2.6) / root.iconAspect
        : Math.min(height * 0.5, Kirigami.Units.gridUnit * 1.25)
    readonly property int iconHeight: {
        const scaled = Math.max(8, autoHeight * root.iconScale);
        const limit = vertical ? width / root.iconAspect : height;
        return Math.round(Math.min(scaled, limit));
    }
    readonly property int iconWidth: {
        const w = Math.round(iconHeight * root.iconAspect);
        return vertical ? Math.min(w, Math.floor(width)) : w;
    }

    Layout.minimumWidth: vertical ? 0 : grid.implicitWidth
    Layout.preferredWidth: vertical ? -1 : grid.implicitWidth
    Layout.minimumHeight: vertical ? grid.implicitHeight : 0
    Layout.preferredHeight: vertical ? grid.implicitHeight : -1
    clip: false

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    property bool wasExpanded: false
    onPressed: wasExpanded = root.expanded
    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton) {
            root.toggleSleepBlock();
        } else {
            root.expanded = !wasExpanded;
        }
    }
    onWheel: wheel => {
        const delta = (wheel.inverted ? -1 : 1) * (wheel.angleDelta.y ? wheel.angleDelta.y : -wheel.angleDelta.x);
        const steps = Math.round(delta / 120);
        root.cyclePowerProfile(steps);
    }

    component PercentText: Text {
        Layout.alignment: Qt.AlignCenter
        text: root.hasBattery ? i18n("%1%", Math.round(root.percent)) : "–"
        color: Kirigami.Theme.textColor
        font.family: Kirigami.Theme.defaultFont.family
        font.pixelSize: Math.max(6, Math.round(compact.iconHeight * 0.75 * root.textScale))
        font.weight: Font.Medium
        textFormat: Text.PlainText
    }

    GridLayout {
        id: grid
        anchors.centerIn: parent
        clip: false
        flow: compact.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        columns: compact.vertical ? 1 : 3
        rows: compact.vertical ? 3 : 1
        rowSpacing: Math.round(Kirigami.Units.smallSpacing / 2)
        columnSpacing: Kirigami.Units.smallSpacing

        PercentText {
            visible: root.percentPosition === 1
        }

        Item {
            id: iconBox
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: compact.iconWidth
            Layout.preferredHeight: compact.iconHeight
            Layout.minimumWidth: compact.iconWidth
            Layout.maximumWidth: compact.iconWidth
            Layout.minimumHeight: compact.iconHeight
            Layout.maximumHeight: compact.iconHeight
            implicitWidth: compact.iconWidth
            implicitHeight: compact.iconHeight
            clip: false

            BatteryIcon {
                anchors.fill: parent
                percent: root.percent
                present: root.hasBattery
                charging: root.charging
                showPercentInside: root.percentPosition === 2
                colorize: root.colorFill
                lowThreshold: root.lowThreshold
                foreground: Kirigami.Theme.textColor
                knockout: Kirigami.Theme.backgroundColor
                fontFamily: Kirigami.Theme.defaultFont.family
                opacity: compact.containsMouse ? 1 : 0.92
            }

            Moon {
                width: Math.max(8, Math.round(iconBox.height * 0.5))
                height: width
                x: iconBox.width - width * 0.58
                y: iconBox.height - height * 0.55
                z: 1
                color: Kirigami.Theme.textColor
                outline: Kirigami.Theme.backgroundColor
                outlineWidth: Math.max(1, Math.round(width * 0.1))
                opacity: root.inhibitions.isManuallyInhibited ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }
            }
        }

        PercentText {
            visible: root.percentPosition === 3
        }
    }
}
