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

    required property var inhibitions

    readonly property var appInhibitions: {
        const list = inhibitions.requestedInhibitions || [];
        const out = [];
        for (let i = 0; i < list.length; ++i) {
            const inh = list[i];
            const reason = inh.reason || "";
            if (reason.indexOf("battery applet") !== -1) {
                continue;
            }
            out.push(inh);
        }
        return out;
    }

    visible: root.showSleepBlock
    spacing: Kirigami.Units.smallSpacing

    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
            source: (block.inhibitions.isManuallyInhibited || block.appInhibitions.some(i => i.active))
                ? "system-suspend-inhibited"
                : "system-suspend-uninhibited"
        }

        PlasmaComponents3.Switch {
            id: sleepSwitch
            Layout.fillWidth: true
            text: i18n("Manually block sleep and screen locking")
            checked: block.inhibitions.isManuallyInhibited
            onToggled: {
                if (sleepSwitch.checked !== block.inhibitions.isManuallyInhibited) {
                    root.toggleSleepBlock();
                }
            }

            Connections {
                target: block.inhibitions
                function onIsManuallyInhibitedChanged() {
                    sleepSwitch.checked = block.inhibitions.isManuallyInhibited;
                }
                function onIsManuallyInhibitedErrorChanged() {
                    sleepSwitch.checked = block.inhibitions.isManuallyInhibited;
                }
            }
        }
    }

    PlasmaComponents3.Label {
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing
        visible: block.inhibitions.isManuallyInhibited
        wrapMode: Text.WordWrap
        font: Kirigami.Theme.smallFont
        opacity: 0.75
        color: Kirigami.Theme.neutralTextColor
        text: i18n("This will result in higher energy consumption.")
        textFormat: Text.PlainText
    }

    PlasmaComponents3.Label {
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing
        visible: block.inhibitions.isLidPresent && !block.inhibitions.triggersLidAction
        wrapMode: Text.WordWrap
        font: Kirigami.Theme.smallFont
        opacity: 0.75
        text: i18n("The laptop is set not to sleep when the lid closes while an external monitor is connected.")
        textFormat: Text.PlainText
    }

    Repeater {
        model: block.appInhibitions

        RowLayout {
            id: inhRow
            required property var modelData

            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                source: inhRow.modelData.icon || "application-x-executable"
            }

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font: Kirigami.Theme.smallFont
                opacity: 0.85
                textFormat: Text.PlainText
                text: {
                    const name = inhRow.modelData.prettyName || inhRow.modelData.appName || i18n("An application");
                    const why = inhRow.modelData.reason || i18n("Unknown reason");
                    const behaviors = inhRow.modelData.behaviors || [];
                    const idle = behaviors.indexOf("idle") !== -1;
                    const sleep = behaviors.indexOf("sleep") !== -1;
                    const allowed = inhRow.modelData.allowed !== false;
                    const active = inhRow.modelData.active === true;

                    let action;
                    if (idle && sleep) {
                        action = i18n("sleep and screen locking");
                    } else if (idle) {
                        action = i18n("screen locking");
                    } else {
                        action = i18n("sleep");
                    }

                    if (!allowed) {
                        return i18n("%1 wants to block %2. (%3)", name, action, why);
                    }
                    if (active) {
                        return i18n("%1 is blocking %2. (%3)", name, action, why);
                    }
                    return i18n("%1 asked to block %2. (%3)", name, action, why);
                }
            }

            PlasmaComponents3.Button {
                visible: inhRow.modelData.allowed !== false && inhRow.modelData.active === true
                text: i18n("Unblock")
                icon.name: "edit-delete-remove"
                onClicked: block.inhibitions.setInhibitionAllowed(inhRow.modelData.appName, inhRow.modelData.reason, false)
            }

            PlasmaComponents3.Button {
                visible: inhRow.modelData.allowed === false
                text: i18n("Allow")
                icon.name: "dialog-ok"
                onClicked: block.inhibitions.setInhibitionAllowed(inhRow.modelData.appName, inhRow.modelData.reason, true)
            }
        }
    }
}
