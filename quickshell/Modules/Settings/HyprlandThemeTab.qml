import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs.Common
import qs.Modals
import qs.Modals.FileBrowser
import qs.Services
import qs.Widgets

Item {
    id: hyprlandThemeTab

    property var parentModal: null

    DarkFlickable {
        id: flickable
        anchors.fill: parent
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingM

            StyledRect {
                width: parent.width
                height: contentColumn.childrenRect.height + Theme.spacingL * 2 + 4
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1
                visible: typeof CompositorService !== 'undefined' && CompositorService.isHyprland

                Column {
                    id: contentColumn
                    width: parent.width - Theme.spacingM * 2
                    x: Theme.spacingM
                    y: Theme.spacingM
                    spacing: Theme.spacingM

                    // Border Colors Section
                    Column {
                        id: borderColorsSection
                        width: parent.width
                        spacing: Theme.spacingM

                    Row {
                        id: borderColorsHeaderRow
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "window-restore"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Hyprland Border Colors"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        id: borderColorsContent
                        width: parent.width
                        spacing: Theme.spacingM

                        RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM

                        Column {
                            spacing: Theme.spacingXS
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            StyledText {
                                text: "Enable Dynamic Border Colors"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Apply dynamic colors to window borders"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DarkToggle {
                            checked: SettingsData.hyprlandThemingEnabled
                            onToggled: checked => {
                                SettingsData.setHyprlandThemingEnabled(checked)
                            }
                        }
                    }

                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM
                        visible: SettingsData.hyprlandThemingEnabled

                        Item { Layout.fillWidth: true }

                        Column {
                            spacing: Theme.spacingXS
                            Layout.alignment: Qt.AlignVCenter

                            StyledText {
                                text: "Border Size"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Thickness of window borders"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        RowLayout {
                            spacing: Theme.spacingS
                            Layout.alignment: Qt.AlignVCenter

                            DarkActionButton {
                                buttonSize: 32
                                iconName: "remove"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.hyprlandBorderSize > 1
                                backgroundColor: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.5)
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newSize = Math.max(1, SettingsData.hyprlandBorderSize - 1)
                                    SettingsData.setHyprlandBorderSize(newSize)
                                }
                            }

                            StyledRect {
                                width: 50
                                height: 32
                                radius: Theme.cornerRadius
                                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                border.width: 1

                                StyledText {
                                    anchors.centerIn: parent
                                    text: SettingsData.hyprlandBorderSize + "px"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }
                            }

                            DarkActionButton {
                                buttonSize: 32
                                iconName: "add"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.hyprlandBorderSize < 10
                                backgroundColor: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.5)
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newSize = Math.min(10, SettingsData.hyprlandBorderSize + 1)
                                    SettingsData.setHyprlandBorderSize(newSize)
                                }
                            }
                        }
                    }
                }
            }

                    // Border Color Adjustment Section
                    Column {
                        id: hyprlandBorderColorsSection
                        width: parent.width
                        spacing: Theme.spacingM
                        visible: SettingsData.hyprlandThemingEnabled

                        Row {
                            id: hyprlandBorderColorsHeaderRow
                            width: parent.width
                            spacing: Theme.spacingM

                            DarkIcon {
                                name: "palette"
                                size: Theme.iconSize
                                color: Theme.primary
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                spacing: Theme.spacingXS
                                width: parent.width - Theme.iconSize - Theme.spacingM

                                StyledText {
                                    text: "Border Color Adjustment"
                                    font.pixelSize: Theme.fontSizeLarge
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }

                                StyledText {
                                    text: "Adjust the hue and transparency of window border colors"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                }
                            }
                        }

                        Column {
                            id: hyprlandBorderColorsContent
                            width: parent.width
                            spacing: Theme.spacingM

                        // Preview color box
                        RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM

                        Column {
                            spacing: Theme.spacingXS
                            Layout.alignment: Qt.AlignVCenter

                            StyledText {
                                text: "Preview"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }

                            Rectangle {
                                id: previewColorBox
                                width: 80
                                height: 80
                                radius: Theme.cornerRadius
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                border.width: 2
                                
                                property color baseColor: typeof Theme !== 'undefined' ? Theme.primary : Qt.rgba(0.26, 0.65, 0.96, 1.0)
                                property real hueShift: hueSlider.value
                                property real alpha: alphaSlider.value / 100.0
                                
                                function calculatePreviewColor() {
                                    var r = baseColor.r
                                    var g = baseColor.g
                                    var b = baseColor.b
                                    var max = Math.max(r, Math.max(g, b))
                                    var min = Math.min(r, Math.min(g, b))
                                    var h, s, l = (max + min) / 2
                                    var d = max - min
                                    
                                    if (d !== 0) {
                                        s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
                                        if (max === r) {
                                            h = ((g - b) / d + (g < b ? 6 : 0)) / 6
                                        } else if (max === g) {
                                            h = ((b - r) / d + 2) / 6
                                        } else {
                                            h = ((r - g) / d + 4) / 6
                                        }
                                    } else {
                                        h = s = 0
                                    }
                                    
                                    // Apply hue shift
                                    h = (h + hueShift / 360.0) % 1.0
                                    if (h < 0) h += 1.0
                                    
                                    // Convert HSL back to RGB
                                    var hue2rgb = function(p, q, t) {
                                        if (t < 0) t += 1
                                        if (t > 1) t -= 1
                                        if (t < 1/6) return p + (q - p) * 6 * t
                                        if (t < 1/2) return q
                                        if (t < 2/3) return p + (q - p) * (2/3 - t) * 6
                                        return p
                                    }
                                    
                                    var q = l < 0.5 ? l * (1 + s) : l + s - l * s
                                    var p = 2 * l - q
                                    r = hue2rgb(p, q, h + 1/3)
                                    g = hue2rgb(p, q, h)
                                    b = hue2rgb(p, q, h - 1/3)
                                    
                                    // Blend with black background to simulate alpha
                                    var bgR = 0.0
                                    var bgG = 0.0
                                    var bgB = 0.0
                                    r = r * alpha + bgR * (1 - alpha)
                                    g = g * alpha + bgG * (1 - alpha)
                                    b = b * alpha + bgB * (1 - alpha)
                                    
                                    return Qt.rgba(r, g, b, 1.0)
                                }
                                
                                color: calculatePreviewColor()
                                
                                Connections {
                                    target: hueSlider
                                    function onSliderValueChanged() {
                                        previewColorBox.color = previewColorBox.calculatePreviewColor()
                                    }
                                }
                                
                                Connections {
                                    target: alphaSlider
                                    function onSliderValueChanged() {
                                        previewColorBox.color = previewColorBox.calculatePreviewColor()
                                    }
                                }
                                
                                Connections {
                                    target: Theme
                                    function onPrimaryChanged() {
                                        previewColorBox.baseColor = Theme.primary
                                        previewColorBox.color = previewColorBox.calculatePreviewColor()
                                    }
                                }
                                
                                Component.onCompleted: {
                                    previewColorBox.baseColor = typeof Theme !== 'undefined' ? Theme.primary : Qt.rgba(0.26, 0.65, 0.96, 1.0)
                                    previewColorBox.color = previewColorBox.calculatePreviewColor()
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Column {
                            spacing: Theme.spacingM
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            Column {
                                width: parent.width
                                spacing: Theme.spacingXS

                                StyledText {
                                    text: "Hue: " + Math.round(hueSlider.value) + "°"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                }

                                DarkSlider {
                                    id: hueSlider
                                    width: parent.width
                                    height: 32
                                    value: Math.round(SettingsData.hyprlandBorderHue)
                                    minimum: -180
                                    maximum: 180
                                    unit: "°"
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                        // Only update preview, don't apply changes
                                    }
                                    onSliderDragFinished: finalValue => {
                                        SettingsData.setHyprlandBorderHue(finalValue)
                                    }
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingXS

                                StyledText {
                                    text: "Alpha: " + Math.round(alphaSlider.value) + "%"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                }

                                DarkSlider {
                                    id: alphaSlider
                                    width: parent.width
                                    height: 32
                                    value: Math.round(SettingsData.hyprlandBorderAlpha * 100)
                                    minimum: 0
                                    maximum: 100
                                    unit: "%"
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                        // Only update preview, don't apply changes
                                    }
                                    onSliderDragFinished: finalValue => {
                                        SettingsData.setHyprlandBorderAlpha(finalValue / 100)
                                    }
                                }
                            }
                        }
                    }
                }
            }

                    // Blur Settings Section
                    Column {
                        id: blurSection
                        width: parent.width
                        spacing: Theme.spacingM

                    Row {
                        id: blurHeaderRow
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "blur_on"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Blur Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        id: blurContent
                        width: parent.width
                        spacing: Theme.spacingS

                        Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Hyprland Blur Size"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.hyprlandBlurSize
                            minimum: 0
                            maximum: 20
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setHyprlandBlurSize(
                                                          newValue)
                                                  }
                        }

                        StyledText {
                            text: "Hyprland Blur Passes"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.hyprlandBlurPasses
                            minimum: 1
                            maximum: 10
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setHyprlandBlurPasses(
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
