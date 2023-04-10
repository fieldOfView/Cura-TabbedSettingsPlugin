// Copyright (c) 2022 Ultimaker B.V.
// Uranium is released under the terms of the LGPLv3 or higher.

// Button used to collapse and de-collapse group, or a category, of settings
// the button contains
//   - the title of the category,
//   - an optional icon and
//   - a chevron button to display the colapsetivity of the settings
// Mainly used for the collapsable categories in the settings pannel

import QtQuick 2.2
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import UM 1.5 as UM

Rectangle
{
    id: base

    height: UM.Theme.getSize("section_header").height
    color: UM.Theme.getColor("setting_category")

    property var expanded: false
    property alias categoryIcon: icon.source
    property alias labelText: categoryLabel.text
    property alias labelFont: categoryLabel.font

    Item
    {
        id: content
        anchors.fill: parent
        anchors.leftMargin: UM.Theme.getSize("narrow_margin").width

        UM.ColorImage
        {
            id: icon
            source: ""
            visible: icon.source != ""
            anchors.verticalCenter: parent.verticalCenter
            color: UM.Theme.getColor("setting_category_text")
            width: visible ? UM.Theme.getSize("section_icon").width: 0
            height: UM.Theme.getSize("section_icon").height
            anchors.leftMargin: base.indented ? UM.Theme.getSize("default_margin").width: 0
        }

        UM.Label
        {
            id: categoryLabel
            Layout.fillWidth: true
            anchors.right: parent.right
            anchors.left: icon.right
            anchors.leftMargin: base.indented ? UM.Theme.getSize("default_margin").width + UM.Theme.getSize("narrow_margin").width: UM.Theme.getSize("narrow_margin").width
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
            font: UM.Theme.getFont("medium_bold")
            color: UM.Theme.getColor("setting_category_text")
        }
    }
}