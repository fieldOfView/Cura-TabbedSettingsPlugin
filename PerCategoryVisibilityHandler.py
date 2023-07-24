# Copyright (c) 2023 Aldo Hoeben / fieldOfView
# The TabbedSettingsPlugin is released under the terms of the AGPLv3 or higher.

from UM.Settings.Models.SettingVisibilityHandler import SettingVisibilityHandler
from cura.CuraApplication import CuraApplication

from UM.Logger import Logger

from PyQt6.QtCore import pyqtProperty, pyqtSignal


class PerCategoryVisibilityHandler(SettingVisibilityHandler):
    def __init__(self, parent=None, *args, **kwargs):
        super().__init__(parent=parent, *args, **kwargs)
        self._root_key = ""

    def setRootKey(self, root_key: str) -> None:
        if root_key == self._root_key:
            return

        self._root_key = root_key
        visible_settings = set()
        # TODO: get settings that are an ancestor of the root key

        global_container_stack = CuraApplication.getInstance().getGlobalContainerStack()
        if not global_container_stack:
            Logger.log("e", "Tried to set root of PerCategoryVisibilityHandler but there is no global stack")
            return

        definitions = global_container_stack.getBottom().findDefinitions(key=root_key)
        if not definitions:
            Logger.log("w", "Tried to set root of PerCategoryVisibilityHandler to an unknown definition")
            return

        visible_settings = set([d.key for d in definitions[0].findDefinitions()])
        visible_settings.add(root_key)

        self.setVisible(visible_settings)

    rootKeyChanged = pyqtSignal()

    @pyqtProperty(str, notify=rootKeyChanged, fset=setRootKey)
    def rootKey(self) -> str:
        return self._root_key
