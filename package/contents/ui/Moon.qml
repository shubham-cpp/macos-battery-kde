/*
 * SPDX-FileCopyrightText: 2026 Rifki
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * Solid crescent. The bite is painted in the outline colour so it
 * disappears over the panel and cuts a moon against the battery fill.
 */
import QtQuick

Item {
    id: root

    property color color: "white"
    property color outline: "black"
    property real outlineWidth: 1

    Rectangle {
        visible: root.outlineWidth > 0
        width: disk.width + root.outlineWidth * 2
        height: width
        radius: width / 2
        x: disk.x - root.outlineWidth
        y: disk.y - root.outlineWidth
        color: root.outline
        antialiasing: true
    }

    Rectangle {
        id: disk
        width: root.width * 0.88
        height: width
        radius: width / 2
        x: (root.width - width) * 0.12
        y: (root.height - height) * 0.18
        color: root.color
        antialiasing: true
    }

    Rectangle {
        width: disk.width * 0.78
        height: width
        radius: width / 2
        x: disk.x + disk.width * 0.40
        y: disk.y - disk.height * 0.08
        color: root.outline
        antialiasing: true
    }
}
