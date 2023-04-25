// Copyright (c) 2023 Aldo Hoeben / fieldOfView
// TabbedSettingsPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import UM 1.5 as UM

CategoryHeader
{
    id: base
    anchors.left: parent.left
    anchors.right: parent.right

    categoryIcon: UM.Theme.getIcon(definition.icon)
    expanded: true
    labelText: definition.label

    signal showTooltip(string text)
    signal hideTooltip()
    signal contextMenuRequested()
    signal showAllHiddenInheritedSettings(string category_id)
    signal focusReceived()
    signal setActiveFocusToNextSetting(bool forward)
}
