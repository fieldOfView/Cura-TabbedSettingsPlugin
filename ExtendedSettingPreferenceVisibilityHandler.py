# Copyright (c) 2023 Aldo Hoeben / fieldOfView
# The TabbedSettingsPlugin is released under the terms of the AGPLv3 or higher.

from UM.Settings.Models.SettingPreferenceVisibilityHandler import SettingPreferenceVisibilityHandler

from UM.FlameProfiler import pyqtSlot


class ExtendedSettingPreferenceVisibilityHandler(SettingPreferenceVisibilityHandler):
    def __init__(self, parent = None, *args, **kwargs):
        super().__init__(parent = parent, *args, **kwargs)

    @pyqtSlot(str, result = bool)
    def getSettingVisible(self, key: str) -> bool:
        """Get a single SettingDefinition's visible state"""

        return key in self.getVisible()

    @pyqtSlot(str, bool)
    def setSettingVisible(self, key: str, visible: bool) -> None:
        """Set a single SettingDefinition's visible state"""
        visible_settings = self.getVisible()
        if key in visible_settings and visible:
            # Ignore already visible settings that need to be made visible.
            return

        if key not in visible_settings and not visible:
            # Ignore already hidden settings that need to be hidden.
            return

        if visible:
            visible_settings.add(key)
        else:
            visible_settings.remove(key)
        self.setVisible(visible_settings)
