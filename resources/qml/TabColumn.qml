// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// TabbedSettingsPlugin is released under the terms of the AGPLv3 or higher.

// Copyright (c) 2018 Ultimaker B.V.
// Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import UM 1.2 as UM

/*
 * Wrapper around TabBar that uses our theming and more sane defaults.
 */
TabBar
{
    id: control

    height: parent.height
    width: visible ? 4 * UM.Theme.getSize("default_margin").width : 0

    spacing: UM.Theme.getSize("narrow_margin").height //Space between the tabs.

    background: Rectangle
    {
        height: parent.height
        anchors.right: parent.right
        width: UM.Theme.getSize("default_lining").width
        color: UM.Theme.getColor("lining")
        visible: parent.enabled
    }

    contentItem: ListView {
        model: control.contentModel
        currentIndex: control.currentIndex

        spacing: control.spacing
        orientation: ListView.Vertical
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded
        snapMode: ListView.SnapToItem
    }
}