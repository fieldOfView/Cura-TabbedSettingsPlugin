// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// SettingsViewPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.15
import QtQuick.Controls 2.4

import UM 1.5 as UM
import Cura 1.0 as Cura

Item
{
    id: settingsViewPatcher
    function patch(base_item)
    {
        parent = base_item
        var contentItem = parent.children[3].children[3]
        var stageMenu = contentItem.children[7]

        var printSetupSelector = stageMenu.printSetupSelector
        var printSetupContent = printSetupSelector.contentItem
        var printSetupChildren = printSetupContent.children[1]
        var customPrintSetup = printSetupChildren.children[1]
        customPrintSetup.children = [settingsView]
    }

    SettingsView
    {
        id: settingsView
    }
}
