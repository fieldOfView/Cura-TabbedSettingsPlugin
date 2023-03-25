# Copyright (c) 2023 Aldo Hoeben / fieldOfView
# The SettingsViewPlugin is released under the terms of the AGPLv3 or higher.

import os.path
from cura.CuraApplication import CuraApplication
from UM.Extension import Extension
from UM.Resources import Resources
from UM.Logger import Logger

try:
    from cura.ApplicationMetadata import CuraSDKVersion
except ImportError: # Cura <= 3.6
    CuraSDKVersion = "6.0.0"
USE_QT5 = False
if CuraSDKVersion >= "8.0.0":
    from PyQt6.QtCore import QUrl
    from PyQt6.QtQml import qmlRegisterSingletonType
else:
    from PyQt5.QtCore import QUrl
    from PyQt5.QtQml import qmlRegisterSingletonType

    USE_QT5 = True

class SettingsViewPlugin(Extension):
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

        qml_folder = "qml" if not USE_QT5 else "qml_qt5"
        path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "resources",
            qml_folder,
            "SettingsViewPatcher.qml",
        )

        self._qml_patcher = CuraApplication.getInstance().createQmlComponent(
            path, {"settingsViewPlugin": self}
        )
        if not self._qml_patcher:
            Logger.log(
                "w", "Could not create qml components for SettingsViewPlugin"
            )
            return

        self._qml_patcher.patch(self._main_window.contentItem())