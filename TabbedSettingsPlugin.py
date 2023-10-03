# Copyright (c) 2023 Aldo Hoeben / fieldOfView
# The TabbedSettingsPlugin is released under the terms of the AGPLv3 or higher.

import os.path
from typing import Optional

from PyQt6.QtCore import QObject, pyqtSlot

from cura.CuraApplication import CuraApplication
from UM.Extension import Extension
from UM.Logger import Logger

from . import PerCategoryVisibilityHandler
from . import InstanceContainerVisibilityHandler
from . import ExtendedSettingPreferenceVisibilityHandler


class TabbedSettingsPlugin(QObject, Extension):
    def __init__(self):
        super().__init__()

        self._qml_patcher = None
        CuraApplication.getInstance().engineCreatedSignal.connect(self._onEngineCreated)

        self._visibility_handlers = {}

    def _onEngineCreated(self):
        main_window = CuraApplication.getInstance().getMainWindow()
        if not main_window:
            Logger.log(
                "e", "Could not replace Setting View because there is no main window"
            )
            return

        path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "resources",
            "qml",
            "SettingsViewPatcher.qml",
        )

        plugin_registry = CuraApplication.getInstance().getPluginRegistry()
        preferences = CuraApplication.getInstance().getPreferences()
        has_sidebar_gui = (
            plugin_registry.getMetaData("SidebarGUIPlugin") != {} and
            preferences._findPreference("sidebargui/expand_legend") is not None
        )

        self._qml_patcher = CuraApplication.getInstance().createQmlComponent(
            path, {
                "manager": self,
                "withSidebarGUI": has_sidebar_gui
            }
        )
        if not self._qml_patcher:
            Logger.log(
                "w", "Could not create qml components for TabbedSettingsPlugin"
            )
            return

        self._qml_patcher.patch(main_window.contentItem())

    @pyqtSlot(str, result=QObject)
    def getVisibilityHandler(self, handler_type: str) -> Optional["QObject"]:
        # NB: this is basically equivalent to registering a singleton; only a
        # single instance of each visibilityhandler is created

        if handler_type not in self._visibility_handlers:
            handler = None
            if handler_type == "PerCategory":
                handler = PerCategoryVisibilityHandler.PerCategoryVisibilityHandler()
            elif handler_type == "InstanceContainer":
                handler = InstanceContainerVisibilityHandler.InstanceContainerVisibilityHandler()
            elif handler_type == "ExtendedSettingPreference":
                handler = ExtendedSettingPreferenceVisibilityHandler.ExtendedSettingPreferenceVisibilityHandler()
            if handler:
                self._visibility_handlers[handler_type] = handler
            else:
                return

        return self._visibility_handlers[handler_type]
