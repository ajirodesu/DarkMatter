import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Modules.Settings
import qs.Services
import qs.Widgets

Item {
    id: colorsThemesTab

    property var parentModal: null

    DarkFlickable {
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

                Column {
                    id: contentColumn
                    width: parent.width - Theme.spacingM * 2
                    x: Theme.spacingM
                    y: Theme.spacingM
                    spacing: Theme.spacingM

                    // Color Palette Section
                    ColorPaletteTab {
                        id: colorPaletteTabItem
                        width: parent.width
                        parentModal: colorsThemesTab.parentModal
                        
                        Component.onCompleted: {
                            for (var i = 0; i < children.length; i++) {
                                var child = children[i]
                                if (child.contentHeight !== undefined) {
                                    child.interactive = false
                                    // Account for topMargin (Theme.spacingL) in DarkFlickable
                                    height = child.contentHeight + Theme.spacingL
                                    child.contentHeightChanged.connect(function() {
                                        colorPaletteTabItem.height = child.contentHeight + Theme.spacingL
                                    })
                                    break
                                }
                            }
                        }
                    }

                    // Text Colors Section
                    Item {
                        width: parent.width
                        height: -8
                    }
                    
                    TextColorTab {
                        id: textColorTabItem
                        width: parent.width
                        parentModal: colorsThemesTab.parentModal
                        
                        Component.onCompleted: {
                            for (var i = 0; i < children.length; i++) {
                                var child = children[i]
                                if (child.contentHeight !== undefined) {
                                    child.interactive = false
                                    // Account for topMargin (Theme.spacingL) in DarkFlickable
                                    height = child.contentHeight + Theme.spacingL
                                    child.contentHeightChanged.connect(function() {
                                        textColorTabItem.height = child.contentHeight + Theme.spacingL
                                    })
                                    break
                                }
                            }
                        }
                    }

                    // Color Adjustments Section
                    Item {
                        width: parent.width
                        height: -8
                    }
                    
                    ColorAdjustmentsTab {
                        id: colorAdjustmentsTabItem
                        width: parent.width
                        parentModal: colorsThemesTab.parentModal
                        
                        Component.onCompleted: {
                            for (var i = 0; i < children.length; i++) {
                                var child = children[i]
                                if (child.contentHeight !== undefined) {
                                    child.interactive = false
                                    // Account for topMargin (Theme.spacingM) in DarkFlickable
                                    height = child.contentHeight + Theme.spacingM
                                    child.contentHeightChanged.connect(function() {
                                        colorAdjustmentsTabItem.height = child.contentHeight + Theme.spacingM
                                    })
                                    break
                                }
                            }
                        }
                    }

                    // Visual Effects Section
                    VisualEffectsTab {
                        id: visualEffectsTabItem
                        width: parent.width
                        parentModal: colorsThemesTab.parentModal
                        
                        Component.onCompleted: {
                            for (var i = 0; i < children.length; i++) {
                                var child = children[i]
                                if (child.contentHeight !== undefined) {
                                    child.interactive = false
                                    height = child.contentHeight
                                    child.contentHeightChanged.connect(function() {
                                        visualEffectsTabItem.height = child.contentHeight
                                    })
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
