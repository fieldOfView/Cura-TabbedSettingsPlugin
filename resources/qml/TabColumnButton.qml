// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// TabbedSettingsPlugin is released under the terms of the AGPLv3 or higher.

// Copyright (c) 2018 Ultimaker B.V.
// Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import UM 1.5 as UM

/*
 * Wrapper around TabButton to use our theming and sane defaults.
 */
TabButton
{
    property string key: ""
    property var iconSource

    anchors.left: parent.left
    width: parent.width

    background: Rectangle
    {
        border.color: UM.Theme.getColor("lining")
        border.width: UM.Theme.getSize("default_lining").height
        color: UM.Theme.getColor(parent.checked ? "main_background" : (parent.hovered ? "action_button_hovered" : "secondary"))
        visible: enabled

        //Make the lining go straight down on the bottom side of the left and right sides.
        Rectangle
        {
            anchors.right: parent.right
            height: parent.height
            //We take almost the entire height of the tab button, since this "manual" lining has no anti-aliasing.
            //We can hardly prevent anti-aliasing on the border of the tab since the tabs are positioned with some spacing that is not necessarily a multiple of the number of tabs.
            width: parent.width - (parent.radius + parent.border.width)
            color: parent.border.color

            //Don't add lining at the bottom side.
            Rectangle
            {
                anchors
                {
                    left: parent.left
                    leftMargin: -parent.parent.border.width
                    right: parent.right
                    rightMargin: parent.parent.parent.checked ? 0 : parent.parent.border.width //Allow margin if tab is not selected.
                    top: parent.top
                    topMargin: parent.parent.border.width
                    bottom: parent.bottom
                    bottomMargin: parent.parent.border.width
                }
                color: parent.parent.color
                width: parent.width - anchors.rightMargin

                Rectangle
                {
                    // Hide top border of first butten
                    color: parent.color
                    width: parent.width
                    height: UM.Theme.getSize("default_lining").height
                    y: -height
                    visible: checked && key=="_favorites"
                }
            }
        }
    }

    contentItem: TabContentItem
    {
        iconSource: parent.iconSource
    }

    UM.ToolTip
    {
        id: tooltip

        tooltipText: parent.text
        visible: parent.hovered
        contentAlignment: UM.Enums.ContentAlignment.AlignLeft
    }
}
