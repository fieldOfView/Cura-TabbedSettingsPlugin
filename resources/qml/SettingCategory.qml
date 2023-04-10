// Copyright (c) 2022 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import UM 1.5 as UM
import Cura 1.5 as Cura

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
