# Copyright (c) 2023 Aldo Hoeben / fieldOfView
# The TabbedSettingsPlugin is released under the terms of the AGPLv3 or higher.

import os
import json

from UM.Version import Version
from UM.Application import Application
from UM.Logger import Logger

from . import TabbedSettingsPlugin
from . import TabbedSettingsIncompatibleVersion


def getMetaData():
    return {}


def register(app):
    if __matchVersion():
        return {"extension": TabbedSettingsPlugin.TabbedSettingsPlugin()}
    else:
        Logger.log("w", "Plugin not loaded because of a version mismatch")
        return {"extension": TabbedSettingsIncompatibleVersion.TabbedSettingsIncompatibleVersion()}


def __matchVersion():
    cura_version = Application.getInstance().getVersion()
    if cura_version == "master" or cura_version == "dev":
        Logger.log("d", "Running Cura from source; skipping version check")
        return True
    if cura_version.startswith("Arachne_engine"):
        Logger.log("d", "Running Cura Arachne preview; skipping version check")
        return True

    cura_version = Version(cura_version)
    cura_version = Version([cura_version.getMajor(), cura_version.getMinor()])

    # Get version information from plugin.json
    plugin_file_path = os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "plugin.json"
    )
    try:
        with open(plugin_file_path) as plugin_file:
            plugin_info = json.load(plugin_file)
            minimum_cura_version = Version(plugin_info["minimum_cura_version"])
            maximum_cura_version = Version(plugin_info["maximum_cura_version"])
    except Exception:
        Logger.log("w", "Could not get version information for the plugin")
        return False

    if cura_version >= minimum_cura_version and cura_version <= maximum_cura_version:
        return True
    else:
        Logger.log(
            "d",
            "This version of the plugin is not compatible with this version of Cura. Please check for an update.",
        )
        return False
