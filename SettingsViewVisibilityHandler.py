# Copyright (c) 2023 Aldo Hoeben / fieldOfView
# The SettingsViewPlugin is released under the terms of the AGPLv3 or higher.

from UM.Settings.Models.SettingVisibilityHandler import SettingVisibilityHandler
from cura.CuraApplication import CuraApplication

from UM.FlameProfiler import pyqtSlot

try:
    from cura.ApplicationMetadata import CuraSDKVersion
except ImportError: # Cura <= 3.6
    CuraSDKVersion = "6.0.0"
if CuraSDKVersion >= "8.0.0":
    from PyQt6.QtCore import pyqtProperty, pyqtSignal
else:
    from PyQt5.QtCore import pyqtProperty, pyqtSignal

class SettingsViewVisibilityHandler(SettingVisibilityHandler):
    def __init__(self, parent = None, *args, **kwargs):
        super().__init__(parent = parent, *args, **kwargs)
        self._root_key = ""

    def setRootKey(self, root_key: str) -> None:
        if root_key == self._root_key:
            return

        self._root_key = root_key
        visible_settings = set()
        # TODO: get settings that are an ancestor of the root key

        global_container_stack = CuraApplication.getInstance().getGlobalContainerStack()
        if not global_container_stack:
            Logger.log("e", "Tried to set root of SettingsViewVisibilityHandler but there is no global stack")
            return

        definitions = global_container_stack.getBottom().findDefinitions(key = root_key)
        if not definitions:
            Logger.log("w", "Tried to set root of SettingsViewVisibilityHandler to an unknown definition")
            return

        visible_settings = set([d.key for d in definitions[0].findDefinitions()])
        visible_settings.add(root_key)

        self.setVisible(visible_settings)

    rootKeyChanged = pyqtSignal()

    @pyqtProperty(str, notify=rootKeyChanged, fset=setRootKey)
    def rootKey() -> str:
        return self._root_key

    ##  Set a single SettingDefinition's visible state
    @pyqtSlot(str, bool)
    def setSettingVisibility(self, key: str, visible: bool) -> None:
        visible_settings = self.getVisible()
        if visible:
            visible_settings.add(key)
        else:
            try:
                visible_settings.remove(key)
            except KeyError:
                pass

        self.setVisible(visible_settings)

