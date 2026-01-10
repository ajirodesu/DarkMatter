import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Modules.Settings
import qs.Services
import qs.Widgets

Item {
    id: appearanceTab

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

                    // Transparency Section
                    TransparencyTab {
                        id: transparencyTabItem
                        width: parent.width
                        parentModal: appearanceTab.parentModal
                        
                        Component.onCompleted: {
                            for (var i = 0; i < children.length; i++) {
                                var child = children[i]
                                if (child.contentHeight !== undefined) {
                                    child.interactive = false
                                    height = child.contentHeight + Theme.spacingL
                                    child.contentHeightChanged.connect(function() {
                                        transparencyTabItem.height = child.contentHeight + Theme.spacingL
                                    })
                                    break
                                }
                            }
                        }
                    }

                    // Borders & Shadows Section
                    BordersShadowsTab {
                        id: bordersShadowsTabItem
                        width: parent.width
                        parentModal: appearanceTab.parentModal
                        
                        Component.onCompleted: {
                            for (var i = 0; i < children.length; i++) {
                                var child = children[i]
                                if (child.contentHeight !== undefined) {
                                    child.interactive = false
                                    height = child.contentHeight + Theme.spacingL
                                    child.contentHeightChanged.connect(function() {
                                        bordersShadowsTabItem.height = child.contentHeight + Theme.spacingL
                                    })
                                    break
                                }
                            }
                        }
                    }

                    // Icon Tinting Section
                    IconTintingTab {
                        id: iconTintingTabItem
                        width: parent.width
                        parentModal: appearanceTab.parentModal
                        
                        Component.onCompleted: {
                            for (var i = 0; i < children.length; i++) {
                                var child = children[i]
                                if (child.contentHeight !== undefined) {
                                    child.interactive = false
                                    height = child.contentHeight
                                    child.contentHeightChanged.connect(function() {
                                        iconTintingTabItem.height = child.contentHeight
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
