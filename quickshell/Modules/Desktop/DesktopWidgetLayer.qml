import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Modules.Desktop

Variants {
    id: root
    model: Quickshell.screens

    Component.onCompleted: Qt.callLater(autoEnablePluginsForInstances)

    function autoEnablePluginsForInstances() {
        const instances = SettingsData.desktopWidgetInstances || [];
        const pluginTypes = new Set();

        for (const inst of instances) {
            if (!inst.enabled)
                continue;
            if (inst.widgetType === "desktopClock" || inst.widgetType === "systemMonitorDetailed" ||
                inst.widgetType === "desktopCpuTemp" || inst.widgetType === "desktopGpuTemp" || 
                inst.widgetType === "desktopTerminal" || inst.widgetType === "desktopDarkDash" ||
                inst.widgetType === "desktopWeather" || inst.widgetType === "desktopIcons")
                continue;
            pluginTypes.add(inst.widgetType);
        }

        for (const pluginId of pluginTypes) {
            if (typeof PluginService !== 'undefined' && PluginService.isPluginLoaded(pluginId))
                continue;
            if (typeof PluginService !== 'undefined' && !PluginService.availablePlugins[pluginId])
                continue;
            if (typeof PluginService !== 'undefined')
                PluginService.enablePlugin(pluginId);
        }
    }

    Connections {
        target: typeof PluginService !== 'undefined' ? PluginService : null
        enabled: typeof PluginService !== 'undefined'
        function onPluginListUpdated() {
            Qt.callLater(root.autoEnablePluginsForInstances);
        }
    }

    QtObject {
        id: screenDelegate

        required property var modelData

        readonly property var screen: modelData
        readonly property string screenKey: SettingsData.getScreenDisplayName(screen)

        function shouldShowOnScreen(prefs) {
            if (!Array.isArray(prefs) || prefs.length === 0 || prefs.includes("all"))
                return true;
            return prefs.some(p => {
                if (typeof p === "string")
                    return p === screenKey || p === modelData.name;
                return p?.name === modelData.name || p === screenKey;
            });
        }

        property Component clockComponent: Component {
            DesktopClockWidget {}
        }

        property Component systemMonitorDetailedComponent: Component {
            Loader {
                source: Qt.resolvedUrl("BuiltinWidgets/SystemMonitor-3.qml")
            }
        }

        property Component cpuTempComponent: Component {
            DesktopCpuTempWidget {}
        }

        property Component gpuTempComponent: Component {
            DesktopGpuTempWidget {}
        }

        property Component terminalComponent: Component {
            DesktopTerminalWidget {}
        }

        property Component darkDashComponent: Component {
            DesktopDarkDashWidget {}
        }

        property Component weatherComponent: Component {
            DesktopWeatherWidget {}
        }

        property Component iconsComponent: Component {
            DesktopIconsWidget {}
        }

        property Instantiator widgetInstantiator: Instantiator {
            model: ScriptModel {
                objectProp: "id"
                values: SettingsData.desktopWidgetInstances
            }

            DesktopPluginWrapper {
                required property var modelData
                required property int index

                readonly property string instanceIdRef: modelData.id
                readonly property var liveInstanceData: {
                    const instances = SettingsData.desktopWidgetInstances || [];
                    return instances.find(inst => inst.id === instanceIdRef) ?? modelData;
                }

                readonly property bool shouldBeVisible: {
                    if (!liveInstanceData.enabled)
                        return false;
                    // Use widget-specific displayPreferences if set, otherwise fall back to global desktopWidgets setting
                    var prefs = liveInstanceData.config?.displayPreferences;
                    if (!prefs || prefs.length === 0) {
                        prefs = SettingsData.screenPreferences && SettingsData.screenPreferences["desktopWidgets"];
                    }
                    if (!prefs || prefs.length === 0) {
                        prefs = ["all"];
                    }
                    return screenDelegate.shouldShowOnScreen(prefs);
                }

                pluginId: liveInstanceData.widgetType
                instanceId: instanceIdRef
                instanceData: liveInstanceData
                builtinComponent: {
                    switch (liveInstanceData.widgetType) {
                    case "desktopClock":
                        return screenDelegate.clockComponent;
                    case "systemMonitorDetailed":
                        return screenDelegate.systemMonitorDetailedComponent;
                    case "desktopCpuTemp":
                        return screenDelegate.cpuTempComponent;
                    case "desktopGpuTemp":
                        return screenDelegate.gpuTempComponent;
                    case "desktopTerminal":
                        return screenDelegate.terminalComponent;
                    case "desktopDarkDash":
                        return screenDelegate.darkDashComponent;
                    case "desktopWeather":
                        return screenDelegate.weatherComponent;
                    case "desktopIcons":
                        return screenDelegate.iconsComponent;
                    default:
                        return null;
                    }
                }
                pluginService: null  // No plugin support initially
                screen: screenDelegate.screen
                widgetEnabled: shouldBeVisible
            }
        }
    }
}
