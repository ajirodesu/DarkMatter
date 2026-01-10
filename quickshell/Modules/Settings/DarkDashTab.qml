import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Modules.Settings
import qs.Services
import qs.Widgets

Item {
    id: darkDashTab

    property var parentModal: null

    DarkFlickable {
        anchors.fill: parent
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingXL

            StyledRect {
                width: parent.width
                height: darkDashSection.childrenRect.height + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: darkDashSection

                    width: parent.width - Theme.spacingL * 2
                    x: Theme.spacingL
                    y: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        id: darkDashHeaderRow
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "dashboard"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Dark Dash"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        id: darkDashContent
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Customize transparency and shadow effects for the Dark Dash popout"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Dark Dash Transparency"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 24
                                value: Math.round(
                                           SettingsData.darkDashTransparency * 100)
                                minimum: 0
                                maximum: 100
                                unit: ""
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                                          SettingsData.setDarkDashTransparency(
                                                              newValue / 100)
                                                      }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Dark Dash Drop Shadow Opacity"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 24
                                value: Math.round(
                                           SettingsData.darkDashDropShadowOpacity * 100)
                                minimum: 0
                                maximum: 100
                                unit: ""
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                                          SettingsData.setDarkDashDropShadowOpacity(
                                                              newValue / 100)
                                                      }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Dark Dash Border Opacity"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 24
                                value: Math.round(
                                           SettingsData.darkDashBorderOpacity * 100)
                                minimum: 0
                                maximum: 100
                                unit: ""
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                                          SettingsData.setDarkDashBorderOpacity(
                                                              newValue / 100)
                                                      }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Dark Dash Border Thickness"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 24
                                value: SettingsData.darkDashBorderThickness
                                minimum: 0
                                maximum: 10
                                unit: "px"
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                                          SettingsData.setDarkDashBorderThickness(
                                                              newValue)
                                                      }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Dark Dash Tab Bar Opacity"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 24
                                value: Math.round(
                                           SettingsData.darkDashTabBarOpacity * 100)
                                minimum: 0
                                maximum: 100
                                unit: ""
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                                          SettingsData.setDarkDashTabBarOpacity(
                                                              newValue / 100)
                                                      }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Dark Dash Content Background Opacity"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 24
                                value: Math.round(
                                           SettingsData.darkDashContentBackgroundOpacity * 100)
                                minimum: 0
                                maximum: 100
                                unit: ""
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                                          SettingsData.setDarkDashContentBackgroundOpacity(
                                                              newValue / 100)
                                                      }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Dark Dash Animated Tint Opacity"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 24
                                value: Math.round(
                                           SettingsData.darkDashAnimatedTintOpacity * 100)
                                minimum: 0
                                maximum: 100
                                unit: ""
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                                          SettingsData.setDarkDashAnimatedTintOpacity(
                                                              newValue / 100)
                                                      }
                            }
                        }
                    }
                }
            }
        }
    }
}
