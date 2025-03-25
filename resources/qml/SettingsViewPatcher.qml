// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// TabbedSettingsPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.15
import QtQuick.Controls 2.4

import UM 1.5 as UM
import Cura 1.1 as Cura

Item
{
    id: settingsViewPatcher
    function patch(base_item)
    {
        var SortableSDKVersion = parseInt(CuraSDKVersion.replace(/\.(\d)\./g, ".0$1."))
        var isLE52 = (SortableSDKVersion <= "8.02.0")

        parent = base_item
        if (isLE52) {
            var contentItem = parent.children[3].children[3]
            var tooltipItem = parent.children[3].children[4]
        } else {
            var contentItem = parent.children[4].children[3]
            var tooltipItem = parent.children[4].children[4]
        }
        var stageMenu = contentItem.children[7]

        var printSetupSelector = stageMenu.printSetupSelector
        var printSetupContent = printSetupSelector.contentItem
        var printSetupChildren = printSetupContent.children[1]

        var customPrintSetup = printSetupChildren.children[1]
        var profileSelectorRow = customPrintSetup.children[0]
        var extruderTabs = customPrintSetup.children[1]

        customPrintSetup.children = [tabbedSettingsView]
        if(!withSidebarGUI)
        {
            tabbedSettingsView.children[0].children = [profileSelectorRow, extruderTabs, spacer]
            extruderTabs.anchors.leftMargin = 3 * UM.Theme.getSize("default_margin").height
            spacer.visible = true
        }
        tabbedSettingsView.backgroundItem = parent.children[0]
        tabbedSettingsView.tooltipItem = tooltipItem
    }

    TabbedSettingsView
    {
        id: tabbedSettingsView
    }

    Item
    {
        id: spacer
        visible: false
        height: UM.Theme.getSize("default_lining").height
        width: 1
    }
}
