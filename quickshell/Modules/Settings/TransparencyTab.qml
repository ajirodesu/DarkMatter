import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: transparencyTab

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
                height: transparencySection.childrenRect.height + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: transparencySection

                    property bool transparencyAdvanced: false
                    property real combinedTransparencyLevel: {
                        const values = [
                            SettingsData.topBarWidgetTransparency,
                            SettingsData.popupTransparency,
                            SettingsData.modalTransparency,
                            SettingsData.notificationTransparency,
                            SettingsData.controlCenterTransparency,
                            SettingsData.controlCenterWidgetBackgroundOpacity
                        ]
                        var sum = 0
                        for (var i = 0; i < values.length; ++i) {
                            sum += values[i]
                        }
                        return values.length ? sum / values.length : 0
                    }

                    function setCombinedTransparencyLevel(level) {
                        const clamped = Math.max(0, Math.min(1, level))
                        SettingsData.setTopBarWidgetTransparency(clamped)
                        SettingsData.setPopupTransparency(clamped)
                        SettingsData.setModalTransparency(clamped)
                        SettingsData.setNotificationTransparency(clamped)
                        SettingsData.setControlCenterTransparency(clamped)
                        SettingsData.setControlCenterWidgetBackgroundOpacity(clamped)
                    }

                    width: parent.width - Theme.spacingL * 2
                    x: Theme.spacingL
                    y: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        id: transparencyHeaderRow
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "opacity"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Transparency & Opacity"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        id: transparencyContent
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Control the transparency levels of various UI elements"
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
                                id: transparencyAdvancedToggle
                                checked: transparencySection.transparencyAdvanced
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: checked => {
                                    transparencySection.transparencyAdvanced = checked
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
                            visible: !transparencySection.transparencyAdvanced

                            StyledText {
                                text: "Overall Transparency & Opacity"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 24
                                value: Math.round(
                                           transparencySection.combinedTransparencyLevel * 100)
                                minimum: 0
                                maximum: 100
                                unit: ""
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                                          transparencySection.setCombinedTransparencyLevel(
                                                              newValue / 100)
                                                      }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS
                            visible: transparencySection.transparencyAdvanced

                            Item {
                                width: parent.width
                                height: Math.max(transparencyLabel.height, widgetColorGroup.height)

                                StyledText {
                                    id: transparencyLabel
                                    text: "Top Bar Widget Transparency"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                DarkButtonGroup {
                                    id: widgetColorGroup
                                    property int currentColorIndex: {
                                        switch (SettingsData.widgetBackgroundColor) {
                                            case "sth": return 0
                                            case "s": return 1
                                            case "sc": return 2
                                            case "sch": return 3
                                            default: return 0
                                        }
                                    }

                                    model: ["sth", "s", "sc", "sch"]
                                    currentIndex: currentColorIndex
                                    selectionMode: "single"
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter

                                    buttonHeight: 20
                                    minButtonWidth: 32
                                    buttonPadding: Theme.spacingS
                                    checkIconSize: Theme.iconSizeSmall - 2
                                    textSize: Theme.fontSizeSmall - 2
                                    spacing: 1

                                    onSelectionChanged: (index, selected) => {
                                        if (!selected) return
                                        const colorOptions = ["sth", "s", "sc", "sch"]
                                        SettingsData.setWidgetBackgroundColor(colorOptions[index])
                                    }
                                }
                            }

                            DarkSlider {
                                width: parent.width
                                height: 24
                                value: Math.round(
                                           SettingsData.topBarWidgetTransparency * 100)
                                minimum: 0
                                maximum: 100
                                unit: ""
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                                          SettingsData.setTopBarWidgetTransparency(
                                                              newValue / 100)
                                                      }
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Popup Transparency"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(
                                               SettingsData.popupTransparency * 100)
                                    minimum: 0
                                    maximum: 100
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setPopupTransparency(
                                                                  newValue / 100)
                                                          }
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Modal Transparency"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(
                                               SettingsData.modalTransparency * 100)
                                    minimum: 0
                                    maximum: 100
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setModalTransparency(
                                                                  newValue / 100)
                                                          }
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                DarkToggle {
                                    width: parent.width
                                    text: "Settings Modal Dimming"
                                    description: "Enable background dimming when settings modal is open"
                                    checked: SettingsData.settingsModalDimmingEnabled
                                    onToggled: (checked) => {
                                        SettingsData.settingsModalDimmingEnabled = checked
                                        SettingsData.saveSettings()
                                    }
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Notification Transparency"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(
                                               SettingsData.notificationTransparency * 100)
                                    minimum: 0
                                    maximum: 100
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setNotificationTransparency(
                                                                  newValue / 100)
                                                          }
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Control Center Transparency"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(
                                               SettingsData.controlCenterTransparency * 100)
                                    minimum: 0
                                    maximum: 100
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setControlCenterTransparency(
                                                                  newValue / 100)
                                                          }
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Control Center Widget Background Opacity"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(
                                               SettingsData.controlCenterWidgetBackgroundOpacity * 100)
                                    minimum: 0
                                    maximum: 100
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setControlCenterWidgetBackgroundOpacity(
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
}
