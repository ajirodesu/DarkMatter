import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: bordersShadowsTab

    property var parentModal: null

    DarkFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingXL

            StyledRect {
                width: parent.width
                height: bordersShadowsSection.childrenRect.height + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: bordersShadowsSection

                    property bool bordersShadowsAdvanced: false
                    property real combinedShadowLevel: {
                        const values = [
                            SettingsData.controlCenterDropShadowOpacity,
                            SettingsData.topBarDropShadowOpacity
                        ]
                        var sum = 0
                        for (var i = 0; i < values.length; ++i) {
                            sum += values[i]
                        }
                        return values.length ? sum / values.length : 0
                    }
                    property real combinedBorderLevel: {
                        const values = [
                            SettingsData.controlCenterBorderOpacity,
                            SettingsData.settingsBorderOpacity,
                            SettingsData.controlCenterBorderThickness / 10,
                            SettingsData.settingsBorderThickness / 10
                        ]
                        var sum = 0
                        for (var i = 0; i < values.length; ++i) {
                            sum += values[i]
                        }
                        return values.length ? sum / values.length : 0
                    }

                    function setCombinedShadowLevel(level) {
                        const clamped = Math.max(0, Math.min(1, level))
                        SettingsData.setControlCenterDropShadowOpacity(clamped)
                        SettingsData.setTopBarDropShadowOpacity(clamped)
                    }

                    function setCombinedBorderLevel(level) {
                        const clamped = Math.max(0, Math.min(1, level))
                        const thicknessValue = Math.round(clamped * 10)
                        SettingsData.setControlCenterBorderOpacity(clamped)
                        SettingsData.setSettingsBorderOpacity(clamped)
                        SettingsData.setControlCenterBorderThickness(thicknessValue)
                        SettingsData.setSettingsBorderThickness(thicknessValue)
                    }

                    width: parent.width - Theme.spacingL * 2
                    x: Theme.spacingL
                    y: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        id: bordersShadowsHeaderRow
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "border_style"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Borders & Shadows"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        id: bordersShadowsContent
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Customize border styles and shadow effects for UI components"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                            width: parent.width
                            horizontalAlignment: Text.AlignLeft
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingL
                        }

                        Row {
                            spacing: Theme.spacingS
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingL

                            DarkToggle {
                                id: bordersShadowsAdvancedToggle
                                checked: bordersShadowsSection.bordersShadowsAdvanced
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: checked => {
                                    bordersShadowsSection.bordersShadowsAdvanced = checked
                                }
                            }

                            StyledText {
                                text: "Advanced controls"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingXS
                            visible: !bordersShadowsSection.bordersShadowsAdvanced

                            StyledText {
                                text: "Shadow Intensity"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 24
                                value: Math.round(
                                           bordersShadowsSection.combinedShadowLevel * 100)
                                minimum: 0
                                maximum: 100
                                unit: ""
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                                          bordersShadowsSection.setCombinedShadowLevel(
                                                              newValue / 100)
                                                      }
                            }

                            StyledText {
                                text: "Border Intensity"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.topMargin: Theme.spacingS
                            }

                            DarkSlider {
                                width: parent.width
                                height: 24
                                value: Math.round(
                                           bordersShadowsSection.combinedBorderLevel * 100)
                                minimum: 0
                                maximum: 100
                                unit: ""
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                                          bordersShadowsSection.setCombinedBorderLevel(
                                                              newValue / 100)
                                                      }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS
                            visible: bordersShadowsSection.bordersShadowsAdvanced

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Control Center Drop Shadow Opacity"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(
                                               SettingsData.controlCenterDropShadowOpacity * 100)
                                    minimum: 0
                                    maximum: 100
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setControlCenterDropShadowOpacity(
                                                                  newValue / 100)
                                                          }
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Top Bar Drop Shadow Opacity"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(
                                               SettingsData.topBarDropShadowOpacity * 100)
                                    minimum: 0
                                    maximum: 100
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setTopBarDropShadowOpacity(
                                                                  newValue / 100)
                                                          }
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Control Center Border Opacity"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(
                                               SettingsData.controlCenterBorderOpacity * 100)
                                    minimum: 0
                                    maximum: 100
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setControlCenterBorderOpacity(
                                                                  newValue / 100)
                                                          }
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Control Center Border Thickness"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: SettingsData.controlCenterBorderThickness
                                    minimum: 0
                                    maximum: 10
                                    unit: "px"
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setControlCenterBorderThickness(
                                                                  newValue)
                                                          }
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Settings Border Opacity"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(
                                               SettingsData.settingsBorderOpacity * 100)
                                    minimum: 0
                                    maximum: 100
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setSettingsBorderOpacity(
                                                                  newValue / 100)
                                                          }
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Settings Border Thickness"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: SettingsData.settingsBorderThickness
                                    minimum: 0
                                    maximum: 10
                                    unit: "px"
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setSettingsBorderThickness(
                                                                  newValue)
                                                          }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
