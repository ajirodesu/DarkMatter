import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

    Item {
        id: root

        property real widgetHeight: 40
        readonly property real horizontalPadding: Math.max(Theme.spacingXS, Theme.spacingS * (widgetHeight / 30))

        width: Math.max(widgetHeight, weatherRow.implicitWidth + horizontalPadding * 2)
        height: widgetHeight

        Ref {
            service: WeatherService
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 5
            radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
            color: {
                if (SettingsData.topBarNoBackground) {
                    return "transparent"
                }
                const baseColor = Theme.widgetBaseBackgroundColor
                return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency)
            }
            border.width: 0
            border.color: "transparent"

            Row {
                id: weatherRow
                anchors.centerIn: parent
                spacing: 6

                DarkIcon {
                    name: WeatherService.getWeatherIcon(WeatherService.weather.wCode)
                    size: 16
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: {
                        const temp = SettingsData.useFahrenheit ? WeatherService.weather.tempF : WeatherService.weather.temp;
                        if (temp === undefined || temp === null) {
                            return "--°" + (SettingsData.useFahrenheit ? "F" : "C");
                        }
                        return temp + "°" + (SettingsData.useFahrenheit ? "F" : "C");
                    }
                    font.pixelSize: 12
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }







