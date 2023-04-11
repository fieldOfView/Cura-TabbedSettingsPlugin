// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// SettingsViewPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.15
import QtQuick.Controls 2.4

import UM 1.5 as UM
import Cura 1.0 as Cura

Item
{
    id: settingsView
    anchors.fill: parent
    anchors.margins: UM.Theme.getSize("default_lining").width

    UM.I18nCatalog { id: catalog; name: "cura"; }

    TabColumn
    {
        id: categoryTabs
        width: 3 * UM.Theme.getSize("default_margin").width
        spacing: - UM.Theme.getSize("default_lining").height

        property int maxTabHeight: Math.floor((height - count * spacing) / (count+2))

        TabColumnButton
        {
            text: catalog.i18nc("@label:category menu label", "Favorites")
            property string key: "_favorites"

            contentItem: TabContentItem
            {
                iconSource: UM.Theme.getIcon("Star")
            }
        }

        TabColumnButton
        {
            text: catalog.i18nc("@label","Changed settings")
            property string key: "_user"

            contentItem: TabContentItem
            {
                iconSource: UM.Theme.getIcon("ArrowReset")
            }
        }

        Repeater
        {
            model: categoriesModel

            TabColumnButton
            {
                text: model.label
                property string key: model.key

                contentItem: TabContentItem
                {
                    iconSource: UM.Theme.getIcon(model.icon)
                }
            }
        }

        UM.SettingDefinitionsModel
        {
            id: categoriesModel
            containerId: Cura.MachineManager.activeMachine !== null ? Cura.MachineManager.activeMachine.definition.id: ""
            showAll: true
            showAncestors: true
            visibilityHandler: UM.SettingPreferenceVisibilityHandler {}
            exclude: ["machine_settings", "command_line_settings"]
            expanded: []
        }
    }

    Item
    {
        anchors.left: categoryTabs.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: UM.Theme.getSize("default_margin").width
        anchors.topMargin: 0

        // Mouse area that gathers the scroll events to not propagate it to the main view.
        MouseArea
        {
            anchors.fill: contents
            acceptedButtons: Qt.AllButtons
            onWheel: (wheel) => { wheel.accepted = true }
        }

        ListView
        {
            id: contents
            maximumFlickVelocity: 1000 * screenScaleFactor
            anchors
            {
                top: parent.top
                topMargin: UM.Theme.getSize("default_margin").height
                bottom: parent.bottom
                right: parent.right
                left: parent.left
            }
            clip: true
            cacheBuffer: 1000000   // Set a large cache to effectively just cache every list item.
            ScrollBar.vertical: UM.ScrollBar
            {
                id: scrollBar
                onPositionChanged: {
                    // This removes focus from items when scrolling.
                    // This fixes comboboxes staying open and scrolling container
                    /*
                    if (!activeFocus && !filter.activeFocus) {
                        forceActiveFocus();
                    }
                    */
                }
            }

            model: UM.SettingDefinitionsModel
            {
                id: definitionsModel

                property string selectedKey: categoryTabs.itemAt(categoryTabs.currentIndex).key
                property var settingPreferenceVisibilityHandler: UM.SettingPreferenceVisibilityHandler {}
                property var settingsViewVisibilityHandler: Cura.SettingsViewVisibilityHandler {}
                property var instanceContainerVisibilityHandler: Cura.InstanceContainerVisibilityHandler {}

                containerId: Cura.MachineManager.activeMachine !== null ? Cura.MachineManager.activeMachine.definition.id: ""
                visibilityHandler:
                {
                    if(selectedKey == "_favorites")
                    {
                        return settingPreferenceVisibilityHandler
                    }
                    else if(selectedKey == "_user")
                    {
                        instanceContainerVisibilityHandler.containerIndex = 0
                        return instanceContainerVisibilityHandler
                    }
                    else
                    {
                        settingsViewVisibilityHandler.rootKey = selectedKey
                        return settingsViewVisibilityHandler
                    }
                }
                exclude: ["machine_settings", "command_line_settings", "infill_mesh", "infill_mesh_order", "cutting_mesh", "support_mesh", "anti_overhang_mesh"] // TODO: infill_mesh settings are excluded hardcoded, but should be based on the fact that settable_globally, settable_per_meshgroup and settable_per_extruder are false.
                expanded:
                {
                    if(selectedKey != "")
                    {
                        return ["*"]
                    }
                    return CuraApplication.expandedCategories
                }
                onVisibilityChanged: Cura.SettingInheritanceManager.scheduleUpdate()
            }

            property int indexWithFocus: -1
            property string activeMachineId: Cura.MachineManager.activeMachine !== null ? Cura.MachineManager.activeMachine.id : ""
            delegate: Loader
            {
                id: delegate

                width: contents.width - (scrollBar.width + UM.Theme.getSize("narrow_margin").width)
                opacity: enabled ? 1 : 0
                enabled: provider.properties.enabled === "True"

                property var definition: model
                property var settingDefinitionsModel: definitionsModel
                property var propertyProvider: provider
                property var globalPropertyProvider: inheritStackProvider
                property bool externalResetHandler: false

                //Qt5.4.2 and earlier has a bug where this causes a crash: https://bugreports.qt.io/browse/QTBUG-35989
                //In addition, while it works for 5.5 and higher, the ordering of the actual combo box drop down changes,
                //causing nasty issues when selecting different options. So disable asynchronous loading of enum type completely.
                asynchronous: model.type !== "enum" && model.type !== "extruder" && model.type !== "optional_extruder"
                active: model.type !== undefined

                sourceComponent:
                {
                    switch(model.type)
                    {
                        case "int":
                            return settingTextField
                        case "[int]":
                            return settingTextField
                        case "float":
                            return settingTextField
                        case "enum":
                            return settingComboBox
                        case "extruder":
                            return settingExtruder
                        case "optional_extruder":
                            return settingOptionalExtruder
                        case "bool":
                            return settingCheckBox
                        case "str":
                            return settingTextField
                        case "category":
                            return settingCategory
                        default:
                            return settingUnknown
                    }
                }

                // Binding to ensure that the right containerstack ID is set for the provider.
                // This ensures that if a setting has a limit_to_extruder id (for instance; Support speed points to the
                // extruder that actually prints the support, as that is the setting we need to use to calculate the value)
                Binding
                {
                    target: provider
                    property: "containerStackId"
                    when: model.settable_per_extruder || (inheritStackProvider.properties.limit_to_extruder !== undefined && inheritStackProvider.properties.limit_to_extruder >= 0);
                    value:
                    {
                        // Associate this binding with Cura.MachineManager.activeMachine.id in the beginning so this
                        // binding will be triggered when activeMachineId is changed too.
                        // Otherwise, if this value only depends on the extruderIds, it won't get updated when the
                        // machine gets changed.

                        if (!model.settable_per_extruder)
                        {
                            //Not settable per extruder or there only is global, so we must pick global.
                            return contents.activeMachineId
                        }
                        if (inheritStackProvider.properties.limit_to_extruder !== undefined && inheritStackProvider.properties.limit_to_extruder >= 0)
                        {
                            //We have limit_to_extruder, so pick that stack.
                            return Cura.ExtruderManager.extruderIds[inheritStackProvider.properties.limit_to_extruder]
                        }
                        if (Cura.ExtruderManager.activeExtruderStackId)
                        {
                            //We're on an extruder tab. Pick the current extruder.
                            return Cura.ExtruderManager.activeExtruderStackId
                        }
                        //No extruder tab is selected. Pick the global stack. Shouldn't happen any more since we removed the global tab.
                        return contents.activeMachineId
                    }
                }

                // Specialty provider that only watches global_inherits (we can't filter on what property changed we get events
                // so we bypass that to make a dedicated provider).
                UM.SettingPropertyProvider
                {
                    id: inheritStackProvider
                    containerStackId: contents.activeMachineId
                    key: model.key
                    watchedProperties: [ "limit_to_extruder" ]
                }

                UM.SettingPropertyProvider
                {
                    id: provider

                    containerStackId: contents.activeMachineId
                    key: model.key
                    watchedProperties: [ "value", "enabled", "state", "validationState", "settable_per_extruder", "resolve" ]
                    storeIndex: 0
                    removeUnusedValue: model.resolve === undefined
                }

                Connections
                {
                    target: item
                    function onContextMenuRequested()
                    {
                        contextMenu.key = model.key
                        contextMenu.settingVisible = model.visible
                        contextMenu.provider = provider
                        contextMenu.popup()                    //iconName: model.icon_name
                    }
                    //function onShowTooltip(text) { base.showTooltip(delegate, Qt.point(-settingsView.x - UM.Theme.getSize("default_margin").width, 0), text) }
                    //function onHideTooltip() { base.hideTooltip() }
                    function onShowAllHiddenInheritedSettings()
                    {
                        var children_with_override = Cura.SettingInheritanceManager.getChildrenKeysWithOverride(category_id)
                        for(var i = 0; i < children_with_override.length; i++)
                        {
                            definitionsModel.setVisible(children_with_override[i], true)
                        }
                        Cura.SettingInheritanceManager.manualRemoveOverride(category_id)
                    }
                    function onFocusReceived()
                    {
                        contents.indexWithFocus = index
                        contents.positionViewAtIndex(index, ListView.Contain)
                    }
                    function onSetActiveFocusToNextSetting(forward)
                    {
                        if (forward == undefined || forward)
                        {
                            contents.currentIndex = contents.indexWithFocus + 1
                            while(contents.currentItem && contents.currentItem.height <= 0)
                            {
                                contents.currentIndex++
                            }
                            if (contents.currentItem)
                            {
                                contents.currentItem.item.focusItem.forceActiveFocus()
                            }
                        }
                        else
                        {
                            contents.currentIndex = contents.indexWithFocus - 1
                            while(contents.currentItem && contents.currentItem.height <= 0)
                            {
                                contents.currentIndex--
                            }
                            if (contents.currentItem)
                            {
                                contents.currentItem.item.focusItem.forceActiveFocus()
                            }
                        }
                    }
                }
            }
        }

        Cura.Menu
        {
            id: contextMenu

            property string key
            property var provider
            property bool settingVisible

            Cura.MenuItem
            {
                //: Settings context menu action
                text: catalog.i18nc("@action:menu", "Copy value to all extruders")
                visible: machineExtruderCount.properties.value > 1
                enabled: contextMenu.provider !== undefined && contextMenu.provider.properties.settable_per_extruder !== "False"
                onTriggered: Cura.MachineManager.copyValueToExtruders(contextMenu.key)
            }

            Cura.MenuItem
            {
                //: Settings context menu action
                text: catalog.i18nc("@action:menu", "Copy all changed values to all extruders")
                visible: machineExtruderCount.properties.value > 1
                enabled: contextMenu.provider !== undefined
                onTriggered: Cura.MachineManager.copyAllValuesToExtruders()
            }

            Cura.MenuSeparator
            {
                visible: machineExtruderCount.properties.value > 1
            }

            Instantiator
            {
                id: customMenuItems
                model: Cura.SidebarCustomMenuItemsModel { }
                Cura.MenuItem
                {
                    text: model.name
                    onTriggered:
                    {
                        customMenuItems.model.callMenuItemMethod(name, model.actions, {"key": contextMenu.key})
                    }
                }
               onObjectAdded: contextMenu.insertItem(index, object)
               onObjectRemoved: contextMenu.removeItem(object)
            }

            Cura.MenuSeparator
            {
                visible: customMenuItems.count > 0
            }

            Cura.MenuItem
            {
                //: Settings context menu action
                visible: !findingSettings
                text: catalog.i18nc("@action:menu", "Hide this setting")
                onTriggered:
                {
                    definitionsModel.hide(contextMenu.key)
                }
            }
            Cura.MenuItem
            {
                //: Settings context menu action
                text:
                {
                    if (contextMenu.settingVisible)
                    {
                        return catalog.i18nc("@action:menu", "Don't show this setting")
                    }
                    else
                    {
                        return catalog.i18nc("@action:menu", "Keep this setting visible")
                    }
                }
                visible: findingSettings
                onTriggered:
                {
                    if (contextMenu.settingVisible)
                    {
                        definitionsModel.hide(contextMenu.key)
                    }
                    else
                    {
                        definitionsModel.show(contextMenu.key)
                    }
                }
            }
            Cura.MenuItem
            {
                //: Settings context menu action
                text: catalog.i18nc("@action:menu", "Configure setting visibility...")

                onTriggered: Cura.Actions.configureSettingVisibility.trigger(contextMenu)
            }
        }

        UM.SettingPropertyProvider
        {
            id: machineExtruderCount

            containerStackId: Cura.MachineManager.activeMachine !== null ? Cura.MachineManager.activeMachine.id : ""
            key: "machine_extruder_count"
            watchedProperties: [ "value" ]
            storeIndex: 0
        }

        Component
        {
            id: settingTextField;
            Cura.SettingTextField { }
        }

        Component
        {
            id: settingComboBox;
            Cura.SettingComboBox { }
        }

        Component
        {
            id: settingExtruder;
            Cura.SettingExtruder { }
        }

        Component
        {
            id: settingOptionalExtruder;
            Cura.SettingOptionalExtruder { }
        }

        Component
        {
            id: settingCheckBox;
            Cura.SettingCheckBox { }
        }

        Component
        {
            id: settingCategory;
            SettingCategory { }
        }

        Component
        {
            id: settingUnknown;
            Cura.SettingUnknown { }
        }
    }
}
