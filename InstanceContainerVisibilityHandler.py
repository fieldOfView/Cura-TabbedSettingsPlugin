# Copyright (c) 2023 Aldo Hoeben / fieldOfView
# The SettingsViewPlugin is released under the terms of the AGPLv3 or higher.

from UM.Settings.Models.SettingVisibilityHandler import SettingVisibilityHandler
from cura.CuraApplication import CuraApplication

from UM.Logger import Logger
from UM.FlameProfiler import pyqtSlot

from PyQt6.QtCore import pyqtProperty, pyqtSignal


class InstanceContainerVisibilityHandler(SettingVisibilityHandler):
    def __init__(self, parent=None, *args, **kwargs):
        super().__init__(parent=parent, *args, **kwargs)
        self._container_index = -1

        self._machine_manager = CuraApplication.getInstance().getMachineManager()
        self._machine_manager.activeStackChanged.connect(self._update)
        self._machine_manager.activeStackValueChanged.connect(self._update)

    def setContainerIndex(self, container_index: int) -> None:
        if container_index == self._container_index:
            return

        self._container_index = container_index
        self._update()

    containerIndexChanged = pyqtSignal()

    @pyqtProperty(int, notify=containerIndexChanged, fset=setContainerIndex)
    def containerIndex(self) -> int:
        return self._container_index

    def _update(self) -> None:
        visible_settings = set()

        if self._container_index == -1:
            Logger.log("w", "Tried to update model, but there is no container index")
            return

        global_container_stack = self._machine_manager.activeMachine
        if not global_container_stack:
            Logger.log("w", "Tried to update model, but there is no global stack")
            return

        extruder_stack = self._machine_manager.activeStack
        if not extruder_stack:
            Logger.log("w", "Tried to update model, but there is no extruder stack")
            return

        for stack in [global_container_stack, extruder_stack]:
            visible_settings.update(stack.getContainer(self._container_index).getAllKeys())

        self.setVisible(visible_settings)
