import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Modules.Settings
import qs.Services
import qs.Widgets

Item {
    id: systemSettingsTab

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

                    // System Themes Section
                    SystemThemeTab {
                        id: systemThemeTabItem
                        width: parent.width
                        parentModal: systemSettingsTab.parentModal
                        
                        Component.onCompleted: {
                            for (var i = 0; i < children.length; i++) {
                                var child = children[i]
                                if (child.contentHeight !== undefined) {
                                    child.interactive = false
                                    height = child.contentHeight + Theme.spacingL
                                    child.contentHeightChanged.connect(function() {
                                        systemThemeTabItem.height = child.contentHeight + Theme.spacingL
                                    })
                                    break
                                }
                            }
                        }
                    }

                    // Settings Themes & Icons Section
                    SettingsThemesIconsTab {
                        id: settingsThemesIconsTabItem
                        width: parent.width
                        parentModal: systemSettingsTab.parentModal
                        
                        Component.onCompleted: {
                            for (var i = 0; i < children.length; i++) {
                                var child = children[i]
                                if (child.contentHeight !== undefined) {
                                    child.interactive = false
                                    height = child.contentHeight
                                    child.contentHeightChanged.connect(function() {
                                        settingsThemesIconsTabItem.height = child.contentHeight
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
