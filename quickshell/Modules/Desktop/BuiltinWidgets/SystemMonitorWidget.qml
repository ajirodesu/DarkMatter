import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property string instanceId: ""
    property var instanceData: null
    readonly property var cfg: instanceData?.config ?? null
    readonly property bool isInstance: instanceId !== "" && cfg !== null

    property real widgetWidth: 200
    property real widgetHeight: 120
    property real defaultWidth: 200
    property real defaultHeight: 120
    property real minWidth: 150
    property real minHeight: 100

    property real widgetOpacity: isInstance ? (cfg?.transparency ?? 0.9) : 0.9

    Component.onCompleted: {
        DgopService.addRef(["cpu", "memory", "gpu"]);
    }
    
    Component.onDestruction: {
        DgopService.removeRef(["cpu", "memory", "gpu"]);
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, root.widgetOpacity)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, SettingsData.desktopWidgetBorderOpacity)
        border.width: SettingsData.desktopWidgetBorderThickness
        antialiasing: true

        layer.enabled: SettingsData.desktopWidgetDropShadowOpacity > 0
        layer.smooth: true
        layer.effect: DropShadow {
            id: dropShadow
            horizontalOffset: 2
            verticalOffset: 1
            radius: SettingsData.desktopWidgetDropShadowRadius
            samples: Math.max(128, Math.ceil(SettingsData.desktopWidgetDropShadowRadius * 2.5))
            color: Qt.rgba(0, 0, 0, SettingsData.desktopWidgetDropShadowOpacity)
            transparentBorder: true
            cached: false
            spread: 0
        }
        
        Connections {
            target: SettingsData
            function onDesktopWidgetDropShadowRadiusChanged() {
                dropShadow.radius = SettingsData.desktopWidgetDropShadowRadius
                dropShadow.samples = Math.max(128, Math.ceil(SettingsData.desktopWidgetDropShadowRadius * 2.5))
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingS

            Row {
                spacing: Theme.spacingS

                DarkIcon {
                    name: "memory"
                    size: Theme.iconSize - 6
                    color: {
                        if (DgopService.cpuTemperature > 85) {
                            return Theme.tempDanger;
                        }
                        if (DgopService.cpuTemperature > 69) {
                            return Theme.tempWarning;
                        }
                        return Theme.surfaceText;
                    }
                    anchors.verticalCenter: parent.verticalCenter

                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 1
                        radius: 3
                        samples: 16
                        color: Qt.rgba(0, 0, 0, 0.2)
                        transparentBorder: true
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    StyledText {
                        text: "CPU"
                        font.pixelSize: Theme.fontSizeSmall - 2
                        color: Theme.surfaceTextMedium
                        font.weight: Font.Medium
                    }

                    Row {
                        spacing: Theme.spacingXS

                        StyledText {
                            text: {
                                if (DgopService.cpuTemperature === undefined || DgopService.cpuTemperature === null || DgopService.cpuTemperature < 0) {
                                    return "--°";
                                }
                                return Math.round(DgopService.cpuTemperature) + "°";
                            }
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Bold
                            color: {
                                if (DgopService.cpuTemperature > 85) {
                                    return Theme.tempDanger;
                                }
                                if (DgopService.cpuTemperature > 69) {
                                    return Theme.tempWarning;
                                }
                                return Theme.surfaceText;
                            }

                            layer.enabled: true
                            layer.effect: DropShadow {
                                horizontalOffset: 0
                                verticalOffset: 1
                                radius: 3
                                samples: 16
                                color: Qt.rgba(0, 0, 0, 0.2)
                                transparentBorder: true
                            }
                        }

                        StyledText {
                            text: {
                                if (DgopService.cpuUsage === undefined || DgopService.cpuUsage === null) {
                                    return "--%";
                                }
                                return Math.round(DgopService.cpuUsage) + "%";
                            }
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: {
                                if (DgopService.cpuUsage > 80) {
                                    return Theme.tempDanger;
                                }
                                if (DgopService.cpuUsage > 60) {
                                    return Theme.tempWarning;
                                }
                                return Theme.surfaceText;
                            }

                            layer.enabled: true
                            layer.effect: DropShadow {
                                horizontalOffset: 0
                                verticalOffset: 1
                                radius: 3
                                samples: 16
                                color: Qt.rgba(0, 0, 0, 0.2)
                                transparentBorder: true
                            }
                        }

                        StyledText {
                            text: {
                                try {
                                    if (typeof CpuFrequencyService !== 'undefined' && CpuFrequencyService.currentFrequency > 0) {
                                        return CpuFrequencyService.currentFrequency.toFixed(1) + "GHz";
                                    }
                                } catch (e) {
                                }
                                return "--GHz";
                            }
                            font.pixelSize: Theme.fontSizeSmall - 2
                            font.weight: Font.Medium
                            color: {
                                try {
                                    if (typeof PerformanceService !== 'undefined') {
                                        switch(PerformanceService.currentMode) {
                                            case "performance": return "#F44336";
                                            case "balanced": return "#FF9800";
                                            case "power-saver": return "#4CAF50";
                                            default: return Theme.surfaceTextMedium;
                                        }
                                    }
                                } catch (e) {
                                }
                                return Theme.surfaceTextMedium;
                            }

                            layer.enabled: true
                            layer.effect: DropShadow {
                                horizontalOffset: 0
                                verticalOffset: 1
                                radius: 3
                                samples: 16
                                color: Qt.rgba(0, 0, 0, 0.2)
                                transparentBorder: true
                            }
                        }
                    }
                }

                StyledText {
                    text: {
                        try {
                            if (typeof PerformanceService !== 'undefined') {
                                return PerformanceService.getCurrentModeInfo().name;
                            }
                        } catch (e) {
                        }
                        return "Unknown";
                    }
                    font.pixelSize: Theme.fontSizeSmall - 3
                    font.weight: Font.Normal
                    color: {
                        try {
                            if (typeof PerformanceService !== 'undefined') {
                                switch(PerformanceService.currentMode) {
                                    case "performance": return "#F44336";
                                    case "balanced": return "#FF9800";
                                    case "power-saver": return "#4CAF50";
                                    default: return Theme.surfaceTextMedium;
                                }
                            }
                        } catch (e) {
                        }
                        return Theme.surfaceTextMedium;
                    }

                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 1
                        radius: 3
                        samples: 16
                        color: Qt.rgba(0, 0, 0, 0.2)
                        transparentBorder: true
                    }
                }
            }

            Row {
                spacing: Theme.spacingS

                DarkIcon {
                    name: "auto_awesome_mosaic"
                    size: Theme.iconSize - 6
                    color: {
                        const gpuTemp = DgopService.availableGpus && DgopService.availableGpus.length > 0 ? 
                                      (DgopService.availableGpus[0].temperature || 0) : 0;
                        if (gpuTemp > 80) {
                            return Theme.tempDanger;
                        }
                        if (gpuTemp > 65) {
                            return Theme.tempWarning;
                        }
                        return Theme.surfaceText;
                    }
                    anchors.verticalCenter: parent.verticalCenter

                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 1
                        radius: 3
                        samples: 16
                        color: Qt.rgba(0, 0, 0, 0.2)
                        transparentBorder: true
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    StyledText {
                        text: "GPU"
                        font.pixelSize: Theme.fontSizeSmall - 2
                        color: Theme.surfaceTextMedium
                        font.weight: Font.Medium
                    }

                    StyledText {
                        text: {
                            const gpuTemp = DgopService.availableGpus && DgopService.availableGpus.length > 0 ? 
                                          (DgopService.availableGpus[0].temperature || 0) : 0;
                            if (gpuTemp === undefined || gpuTemp === null || gpuTemp === 0) {
                                return "--°";
                            }
                            return Math.round(gpuTemp) + "°";
                        }
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Bold
                        color: {
                            const gpuTemp = DgopService.availableGpus && DgopService.availableGpus.length > 0 ? 
                                          (DgopService.availableGpus[0].temperature || 0) : 0;
                            if (gpuTemp > 80) {
                                return Theme.tempDanger;
                            }
                            if (gpuTemp > 65) {
                                return Theme.tempWarning;
                            }
                            return Theme.surfaceText;
                        }

                        layer.enabled: true
                        layer.effect: DropShadow {
                            horizontalOffset: 0
                            verticalOffset: 1
                            radius: 3
                            samples: 16
                            color: Qt.rgba(0, 0, 0, 0.2)
                            transparentBorder: true
                        }
                    }
                }
            }

            Row {
                spacing: Theme.spacingS

                DarkIcon {
                    name: "developer_board"
                    size: Theme.iconSize - 6
                    color: {
                        if (DgopService.memoryUsage > 90) {
                            return Theme.tempDanger;
                        }
                        if (DgopService.memoryUsage > 75) {
                            return Theme.tempWarning;
                        }
                        return Theme.surfaceText;
                    }
                    anchors.verticalCenter: parent.verticalCenter

                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 1
                        radius: 3
                        samples: 16
                        color: Qt.rgba(0, 0, 0, 0.2)
                        transparentBorder: true
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    StyledText {
                        text: "RAM"
                        font.pixelSize: Theme.fontSizeSmall - 2
                        color: Theme.surfaceTextMedium
                        font.weight: Font.Medium
                    }

                    StyledText {
                        text: {
                            if (DgopService.memoryUsage === undefined || DgopService.memoryUsage === null) {
                                return "--%";
                            }
                            return Math.round(DgopService.memoryUsage) + "%";
                        }
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Bold
                        color: {
                            if (DgopService.memoryUsage > 90) {
                                return Theme.tempDanger;
                            }
                            if (DgopService.memoryUsage > 75) {
                                return Theme.tempWarning;
                            }
                            return Theme.surfaceText;
                        }

                        layer.enabled: true
                        layer.effect: DropShadow {
                            horizontalOffset: 0
                            verticalOffset: 1
                            radius: 3
                            samples: 16
                            color: Qt.rgba(0, 0, 0, 0.2)
                            transparentBorder: true
                        }
                    }
                }
            }
        }
    }
}
