# Copyright (c) 2023 Aldo Hoeben / fieldOfView
# The TabbedSettingsPlugin is released under the terms of the AGPLv3 or higher.

import os.path
from cura.CuraApplication import CuraApplication
from UM.Extension import Extension
from UM.Logger import Logger


class TabbedSettingsPlugin(Extension):
    def __init__(self):
        super().__init__()

        self._qml_patcher = None
        self._main_window = None
        CuraApplication.getInstance().engineCreatedSignal.connect(self._onEngineCreated)

    def _onEngineCreated(self):
        self._main_window = CuraApplication.getInstance().getMainWindow()
        if not self._main_window:
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

        self._qml_patcher = CuraApplication.getInstance().createQmlComponent(
            path, {"settingsViewPlugin": self}
        )
        if not self._qml_patcher:
            Logger.log(
                "w", "Could not create qml components for TabbedSettingsPlugin"
            )
            return

        self._qml_patcher.patch(self._main_window.contentItem())