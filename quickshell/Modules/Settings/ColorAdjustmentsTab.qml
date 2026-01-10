import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: colorAdjustmentsTab

    property var parentModal: null

    DarkFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingM
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingL

            StyledRect {
                width: parent.width
                height: hueAdjustSection.childrenRect.height + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(
                    Theme.surfaceContainerHighest ? Theme.surfaceContainerHighest.r : 0.1,
                    Theme.surfaceContainerHighest ? Theme.surfaceContainerHighest.g : 0.1,
                    Theme.surfaceContainerHighest ? Theme.surfaceContainerHighest.b : 0.1,
                    0.4)
                border.color: Qt.rgba(
                    Theme.outline ? Theme.outline.r : 0.5,
                    Theme.outline ? Theme.outline.g : 0.5,
                    Theme.outline ? Theme.outline.b : 0.5,
                    0.18)
                border.width: 1

                Column {
                    id: hueAdjustSection

                    width: parent.width - Theme.spacingL * 2
                    x: Theme.spacingL
                    y: Theme.spacingL
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Color Adjustments"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }

                    StyledText {
                        text: "Adjust hue, saturation, and lightness of extracted colors"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        StyledText {
                            text: "Hue Shift: " + Math.round(ColorPaletteService.hueShiftDegrees) + "°"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }
                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: Math.round(ColorPaletteService.hueShiftDegrees)
                            minimum: -180
                            maximum: 180
                            unit: "°"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                ColorPaletteService.hueShiftDegrees = newValue
                            }
                            onSliderDragFinished: finalValue => {
                                ColorPaletteService.hueShiftDegrees = finalValue
                                ColorPaletteService.seedSelectionFromCurrentTheme()
                                ColorPaletteService.applySelectedColors()
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        StyledText {
                            text: "Saturation: " + Math.round(ColorPaletteService.saturationScale * 100) + "%"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }
                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: Math.round(ColorPaletteService.saturationScale * 100)
                            minimum: 50
                            maximum: 150
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                ColorPaletteService.saturationScale = newValue / 100
                            }
                            onSliderDragFinished: finalValue => {
                                ColorPaletteService.saturationScale = finalValue / 100
                                ColorPaletteService.seedSelectionFromCurrentTheme()
                                ColorPaletteService.applySelectedColors()
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        StyledText {
                            text: "Lightness: " + Math.round(ColorPaletteService.lightnessScale * 100) + "%"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }
                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: Math.round(ColorPaletteService.lightnessScale * 100)
                            minimum: 50
                            maximum: 150
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                ColorPaletteService.lightnessScale = newValue / 100
                            }
                            onSliderDragFinished: finalValue => {
                                ColorPaletteService.lightnessScale = finalValue / 100
                                ColorPaletteService.seedSelectionFromCurrentTheme()
                                ColorPaletteService.applySelectedColors()
                            }
                        }
                    }
                }
            }
        }
    }
}
