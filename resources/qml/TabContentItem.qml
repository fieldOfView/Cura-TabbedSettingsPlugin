// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// TabbedSettingsPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.15
import QtQuick.Controls 2.4

import UM 1.5 as UM
import Cura 1.0 as Cura

Item
{
    property alias iconSource: icon.source
    implicitHeight: Math.min(categoryTabs.maxTabHeight, icon.height + UM.Theme.getSize("default_margin").height)

    UM.ColorImage
    {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: UM.Theme.getColor("setting_category_text")
        width: visible ? UM.Theme.getSize("section_icon").width: 0
        height: UM.Theme.getSize("section_icon").height
    }
}