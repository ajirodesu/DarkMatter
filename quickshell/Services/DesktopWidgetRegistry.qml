pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Common
import qs.Services

Singleton {
    id: root

    property var registeredWidgets: ({})
    property var registeredWidgetsList: []

    signal registryChanged

    Component.onCompleted: {
        registerBuiltins();
        Qt.callLater(syncPluginWidgets);
    }

    Connections {
        target: typeof PluginService !== 'undefined' ? PluginService : null
        enabled: typeof PluginService !== 'undefined'
        function onPluginLoaded(pluginId) {
            const plugin = PluginService.availablePlugins[pluginId];
            if (plugin?.type === "desktop")
                syncPluginWidgets();
        }
        function onPluginUnloaded(pluginId) {
            syncPluginWidgets();
        }
        function onPluginListUpdated() {
            syncPluginWidgets();
        }
    }

    function registerBuiltins() {
        registerWidget({
            id: "desktopClock",
            name: "Desktop Clock",
            icon: "schedule",
            description: "Analog, digital, or stacked clock display",
            type: "builtin",
            component: "qs.Modules.Desktop.DesktopClockWidget",
            settingsComponent: "qs.Modules.Settings.DesktopWidgetSettings.ClockSettings",
            defaultConfig: getDefaultClockConfig(),
            defaultSize: {
                width: 280,
                height: 180
            }
        });

        registerWidget({
            id: "systemMonitorDetailed",
            name: "System Monitor Detailed",
            icon: "monitoring",
            description: "Detailed system monitor with graphs for CPU, GPU, RAM, and Network",
            type: "builtin",
            component: "qs.Modules.Desktop.BuiltinWidgets.SystemMonitor-3",
            settingsComponent: null,
            defaultConfig: {
                transparency: 0.8,
                displayPreferences: ["all"]
            },
            defaultSize: {
                width: 512,
                height: 512
            }
        });

        registerWidget({
            id: "desktopCpuTemp",
            name: "CPU Temperature",
            icon: "device_thermostat",
            description: "Shows CPU temperature with color-coded warnings",
            type: "builtin",
            component: "qs.Modules.Desktop.DesktopCpuTempWidget",
            settingsComponent: null,
            defaultConfig: {
                displayPreferences: ["all"]
            },
            defaultSize: {
                width: 200,
                height: 100
            }
        });

        registerWidget({
            id: "desktopGpuTemp",
            name: "GPU Temperature",
            icon: "auto_awesome_mosaic",
            description: "Shows GPU temperature with color-coded warnings",
            type: "builtin",
            component: "qs.Modules.Desktop.DesktopGpuTempWidget",
            settingsComponent: null,
            defaultConfig: {
                displayPreferences: ["all"]
            },
            defaultSize: {
                width: 200,
                height: 100
            }
        });

        registerWidget({
            id: "desktopTerminal",
            name: "Desktop Terminal",
            icon: "terminal",
            description: "Interactive terminal widget for running commands",
            type: "builtin",
            component: "qs.Modules.Desktop.DesktopTerminalWidget",
            settingsComponent: null,
            defaultConfig: {
                displayPreferences: ["all"]
            },
            defaultSize: {
                width: 400,
                height: 300
            }
        });

        registerWidget({
            id: "desktopDarkDash",
            name: "Desktop Dark Dash",
            icon: "dashboard",
            description: "Dark Dash widget for desktop with customizable tabs and content",
            type: "builtin",
            component: "qs.Modules.Desktop.DesktopDarkDashWidget",
            settingsComponent: null,
            defaultConfig: {
                displayPreferences: ["all"]
            },
            defaultSize: {
                width: 700,
                height: 500
            }
        });

        registerWidget({
            id: "desktopWeather",
            name: "Desktop Weather",
            icon: "wb_sunny",
            description: "Weather widget showing current conditions and forecast",
            type: "builtin",
            component: "qs.Modules.Desktop.DesktopWeatherWidget",
            settingsComponent: null,
            defaultConfig: {
                displayPreferences: ["all"]
            },
            defaultSize: {
                width: 800,
                height: 500
            }
        });

        registerWidget({
            id: "desktopIcons",
            name: "Desktop Icons",
            icon: "apps",
            description: "Display files and folders from your desktop directory",
            type: "builtin",
            component: "qs.Modules.Desktop.BuiltinWidgets.DesktopIconsWidget",
            settingsComponent: null,
            defaultConfig: {
                displayPreferences: ["all"],
                iconSize: 64,
                iconSpacing: 20,
                showHidden: false
            },
            defaultSize: {
                width: 800,
                height: 600
            }
        });
    }

    function getDefaultClockConfig() {
        return {
            style: "analog",
            transparency: 0.8,
            colorMode: "primary",
            customColor: "#ffffff",
            showDate: true,
            showAnalogNumbers: false,
            showAnalogSeconds: true,
            displayPreferences: ["all"]
        };
    }

    function getDefaultSystemMonitorConfig() {
        return {
            showHeader: true,
            transparency: 0.8,
            colorMode: "primary",
            customColor: "#ffffff",
            showCpu: true,
            showCpuGraph: true,
            showCpuTemp: true,
            showGpuTemp: false,
            gpuPciId: "",
            showMemory: true,
            showMemoryGraph: true,
            showNetwork: true,
            showNetworkGraph: true,
            showDisk: true,
            showTopProcesses: false,
            topProcessCount: 3,
            topProcessSortBy: "cpu",
            layoutMode: "auto",
            graphInterval: 60,
            displayPreferences: ["all"]
        };
    }

    function registerWidget(widgetDef) {
        if (!widgetDef?.id)
            return;

        const newMap = Object.assign({}, registeredWidgets);
        newMap[widgetDef.id] = widgetDef;
        registeredWidgets = newMap;
        _updateWidgetsList();
        registryChanged();
    }

    function unregisterWidget(widgetId) {
        if (!registeredWidgets[widgetId])
            return;

        const newMap = Object.assign({}, registeredWidgets);
        delete newMap[widgetId];
        registeredWidgets = newMap;
        _updateWidgetsList();
        registryChanged();
    }

    function getWidget(widgetType) {
        return registeredWidgets[widgetType] ?? null;
    }

    function getDefaultConfig(widgetType) {
        const widget = getWidget(widgetType);
        if (!widget)
            return {};

        if (widget.type === "builtin") {
            switch (widgetType) {
            case "desktopClock":
                return getDefaultClockConfig();
            case "systemMonitorDetailed":
                return {
                    transparency: 0.8,
                    displayPreferences: ["all"]
                };
            default:
                return widget.defaultConfig ?? {};
            }
        }

        return widget.defaultConfig ?? {};
    }

    function getDefaultSize(widgetType) {
        const widget = getWidget(widgetType);
        return widget?.defaultSize ?? {
            width: 200,
            height: 200
        };
    }

    function syncPluginWidgets() {
        if (typeof PluginService === 'undefined')
            return;

        const desktopPlugins = PluginService.pluginDesktopComponents;
        const availablePlugins = PluginService.availablePlugins;
        const currentPluginIds = [];

        for (const pluginId in desktopPlugins) {
            currentPluginIds.push(pluginId);
            const plugin = availablePlugins[pluginId];
            if (!plugin)
                continue;

            if (registeredWidgets[pluginId]?.type === "plugin")
                continue;

            registerWidget({
                id: pluginId,
                name: plugin.name || pluginId,
                icon: plugin.icon || "extension",
                description: plugin.description || "",
                type: "plugin",
                component: null,
                settingsComponent: plugin.settingsPath || null,
                defaultConfig: {
                    displayPreferences: ["all"]
                },
                defaultSize: {
                    width: 200,
                    height: 200
                },
                pluginInfo: plugin
            });
        }

        const toRemove = [];
        for (const widgetId in registeredWidgets) {
            const widget = registeredWidgets[widgetId];
            if (widget.type !== "plugin")
                continue;
            if (!currentPluginIds.includes(widgetId))
                toRemove.push(widgetId);
        }

        for (const widgetId of toRemove) {
            unregisterWidget(widgetId);
        }
    }

    function _updateWidgetsList() {
        const result = [];
        for (const key in registeredWidgets) {
            result.push(registeredWidgets[key]);
        }
        result.sort((a, b) => {
            if (a.type === "builtin" && b.type !== "builtin")
                return -1;
            if (a.type !== "builtin" && b.type === "builtin")
                return 1;
            return (a.name || "").localeCompare(b.name || "");
        });
        registeredWidgetsList = result;
    }

    function getBuiltinWidgets() {
        return registeredWidgetsList.filter(w => w.type === "builtin");
    }

    function getPluginWidgets() {
        return registeredWidgetsList.filter(w => w.type === "plugin");
    }

    function getAllWidgets() {
        return registeredWidgetsList;
    }
}
