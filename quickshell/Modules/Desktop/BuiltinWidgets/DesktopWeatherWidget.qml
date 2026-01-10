import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
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

    property real widgetWidth: isInstance ? (cfg.width ?? 800) : (SettingsData.desktopWeatherWidth || 600)
    property real widgetHeight: isInstance ? (cfg.height ?? 500) : (SettingsData.desktopWeatherHeight || 300)
    property real defaultWidth: 800
    property real defaultHeight: 500
    property real minWidth: 400
    property real minHeight: 300

    readonly property real widgetOpacity: isInstance ? (cfg.opacity ?? 0.9) : SettingsData.desktopWeatherOpacity
    readonly property real baseFontSize: isInstance ? (cfg.fontSize ?? 20) : SettingsData.desktopWeatherFontSize
    readonly property real baseSpacing: isInstance ? (cfg.spacing ?? 8) : SettingsData.desktopWeatherSpacing
    readonly property real basePadding: isInstance ? (cfg.padding ?? 16) : SettingsData.desktopWeatherPadding
    readonly property real baseIconSize: isInstance ? (cfg.iconSize ?? 24) : SettingsData.desktopWeatherIconSize

    property real scaleFactor: Math.min(widgetWidth / 100, widgetHeight / 450)
    property real scaledFontSize: baseFontSize * scaleFactor
    property real scaledSpacing: baseSpacing * scaleFactor
    property real scaledPadding: basePadding * scaleFactor
    property real scaledIconSize: baseIconSize * scaleFactor

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, widgetOpacity)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, SettingsData.desktopWidgetBorderOpacity)
        border.width: SettingsData.desktopWidgetBorderThickness

        Column {
            anchors.centerIn: parent
            spacing: scaledSpacing * 2
            visible: !WeatherService.weather.available

            DarkIcon {
                name: "cloud_off"
                size: Theme.iconSize * 2 * scaleFactor
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: "No Weather Data Available"
                font.pixelSize: scaledFontSize * 1.5
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: scaledPadding
            spacing: scaledSpacing
            visible: WeatherService.weather.available

            Item {
                width: parent.width
                height: 50 * scaleFactor

                DarkIcon {
                    id: refreshButton
                    name: "refresh"
                    size: (Theme.iconSize - 4) * scaleFactor
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.4)
                    anchors.right: parent.right
                    anchors.top: parent.top

                    property bool isRefreshing: false
                    enabled: !isRefreshing

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                        onClicked: {
                            refreshButton.isRefreshing = true
                            WeatherService.forceRefresh()
                            refreshTimer.restart()
                        }
                        enabled: parent.enabled
                    }

                    Timer {
                        id: refreshTimer
                        interval: 2000
                        onTriggered: refreshButton.isRefreshing = false
                    }

                    NumberAnimation on rotation {
                        running: refreshButton.isRefreshing
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                    }
                }

                Row {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 2
                    anchors.topMargin: 2
                    spacing: 8

                    DarkIcon {
                        id: weatherIcon
                        name: WeatherService.getWeatherIcon(WeatherService.weather.wCode)
                        size: scaledIconSize * 1.5
                        color: Theme.primary

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowHorizontalOffset: 0
                            shadowVerticalOffset: 4
                            shadowBlur: 0.8
                            shadowColor: Qt.rgba(0, 0, 0, 0.2)
                            shadowOpacity: 0.2
                        }
                    }

                    Row {
                        spacing: 2
                        anchors.verticalCenter: weatherIcon.verticalCenter

                        StyledText {
                            text: (SettingsData.useFahrenheit ? WeatherService.weather.tempF : WeatherService.weather.temp) + "°"
                            font.pixelSize: scaledFontSize * SettingsData.desktopWeatherCurrentTempSize
                            color: Theme.surfaceText
                            font.weight: Font.Light
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: SettingsData.useFahrenheit ? "F" : "C"
                            font.pixelSize: scaledFontSize * 1.2
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                            anchors.verticalCenter: parent.verticalCenter
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (WeatherService.weather.available) {
                                        SettingsData.setTemperatureUnit(!SettingsData.useFahrenheit)
                                    }
                                }
                                enabled: WeatherService.weather.available
                            }
                        }
                    }
                }

                StyledText {
                    text: WeatherService.weather.city || ""
                    font.pixelSize: scaledFontSize * SettingsData.desktopWeatherCitySize
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                    visible: text.length > 0
                    anchors.right: refreshButton.left
                    anchors.top: parent.top
                    anchors.rightMargin: 4
                    anchors.topMargin: 2
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
            }

            GridLayout {
                width: parent.width
                height: 120 * scaleFactor
                columns: 3
                columnSpacing: scaledSpacing
                rowSpacing: scaledSpacing

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.cornerRadius * 0.5
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)

                    Column {
                        anchors.centerIn: parent
                        spacing: scaledSpacing / 2

                        Rectangle {
                            width: 24 * scaleFactor
                            height: 24 * scaleFactor
                            radius: Theme.cornerRadius * 0.3
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                            anchors.horizontalCenter: parent.horizontalCenter

                            DarkIcon {
                                anchors.centerIn: parent
                                name: "device_thermostat"
                                size: (Theme.iconSize - 4) * scaleFactor
                                color: Theme.primary
                            }
                        }

                        StyledText {
                            text: "Feels Like"
                            font.pixelSize: scaledFontSize * 0.8
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: (SettingsData.useFahrenheit ? (WeatherService.weather.feelsLikeF || WeatherService.weather.tempF) : (WeatherService.weather.feelsLike || WeatherService.weather.temp)) + "°"
                            font.pixelSize: scaledFontSize
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.cornerRadius * 0.5
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)

                    Column {
                        anchors.centerIn: parent
                        spacing: scaledSpacing / 2

                        Rectangle {
                            width: 24 * scaleFactor
                            height: 24 * scaleFactor
                            radius: Theme.cornerRadius * 0.3
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                            anchors.horizontalCenter: parent.horizontalCenter

                            DarkIcon {
                                anchors.centerIn: parent
                                name: "humidity_low"
                                size: (Theme.iconSize - 4) * scaleFactor
                                color: Theme.primary
                            }
                        }

                        StyledText {
                            text: "Humidity"
                            font.pixelSize: scaledFontSize * 0.8
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: WeatherService.weather.humidity ? WeatherService.weather.humidity + "%" : "--"
                            font.pixelSize: scaledFontSize
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.cornerRadius * 0.5
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)

                    Column {
                        anchors.centerIn: parent
                        spacing: scaledSpacing / 2

                        Rectangle {
                            width: 24 * scaleFactor
                            height: 24 * scaleFactor
                            radius: Theme.cornerRadius * 0.3
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                            anchors.horizontalCenter: parent.horizontalCenter

                            DarkIcon {
                                anchors.centerIn: parent
                                name: "air"
                                size: (Theme.iconSize - 4) * scaleFactor
                                color: Theme.primary
                            }
                        }

                        StyledText {
                            text: "Wind"
                            font.pixelSize: scaledFontSize * 0.8
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: WeatherService.weather.wind || "--"
                            font.pixelSize: scaledFontSize
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
            }

            Column {
                width: parent.width
                spacing: scaledSpacing

                StyledText {
                    text: "7-Day Forecast"
                    font.pixelSize: scaledFontSize * 1.2
                    color: Theme.surfaceText
                    font.weight: Font.Bold
                }

                Row {
                    width: parent.width
                    spacing: scaledSpacing

                    Repeater {
                        model: 7

                        Rectangle {
                            width: (parent.width - scaledSpacing * 6) / 7
                            implicitHeight: dayColumn.implicitHeight + scaledPadding
                            height: implicitHeight
                            radius: Theme.cornerRadius * 0.5
                            
                            property var dayDate: {
                                const date = new Date()
                                date.setDate(date.getDate() + index)
                                return date
                            }
                            property bool isToday: index === 0
                            property var forecastData: {
                                if (WeatherService.weather.forecast && WeatherService.weather.forecast.length > index) {
                                    return WeatherService.weather.forecast[index]
                                }
                                return null
                            }

                            color: isToday ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.1)
                            border.color: isToday ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3) : "transparent"
                            border.width: isToday ? 1 : 0

                            Column {
                                id: dayColumn
                                width: parent.width
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: scaledPadding / 2
                                spacing: scaledSpacing / 2

                                StyledText {
                                    text: Qt.locale().dayName(dayDate.getDay(), Locale.ShortFormat)
                                    font.pixelSize: scaledFontSize * 1.2
                                    color: isToday ? Theme.primary : Theme.surfaceText
                                    font.weight: isToday ? Font.Medium : Font.Normal
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                DarkIcon {
                                    name: forecastData ? WeatherService.getWeatherIcon(forecastData.wCode || 0) : "cloud"
                                    size: Theme.iconSize * 1.5 * scaleFactor
                                    color: isToday ? Theme.primary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.8)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                StyledText {
                                    text: forecastData ? (SettingsData.useFahrenheit ? (forecastData.tempMaxF || forecastData.tempMax) : (forecastData.tempMax || 0)) + "°/" + (SettingsData.useFahrenheit ? (forecastData.tempMinF || forecastData.tempMin) : (forecastData.tempMin || 0)) + "°" : "--/--"
                                    font.pixelSize: scaledFontSize * 1.0
                                    color: isToday ? Theme.primary : Theme.surfaceText
                                    font.weight: Font.Medium
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        WeatherService.addRef()
    }
    
    Component.onDestruction: {
        WeatherService.removeRef()
    }
}
