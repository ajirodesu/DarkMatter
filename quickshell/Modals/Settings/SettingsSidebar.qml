import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Modals.Settings
import qs.Widgets

Item {
    id: sidebarContainer

    property int currentIndex: 0
    property var parentModal: null
    property real cornerRadius: (parentModal && parentModal.cornerRadius !== undefined) ? parentModal.cornerRadius : Theme.cornerRadius
    property var expandedCategories: ({})
    
    function toggleCategory(categoryId) {
        var newExpanded = Object.assign({}, expandedCategories);
        newExpanded[categoryId] = !isCategoryExpanded(categoryId);
        expandedCategories = newExpanded;
    }
    
    function isCategoryExpanded(categoryId) {
        if (expandedCategories[categoryId] !== undefined) {
            return expandedCategories[categoryId];
        }
        // Auto-expand if a child is active
        var category = sidebarItems.find(item => item.id === categoryId);
        if (category && category.children) {
            return category.children.some(child => child.tabIndex === currentIndex);
        }
        return false;
    }
    
    readonly property var sidebarItems: [{
        "text": "Personalization",
        "icon": "person"
    }, {
        "text": "Fonts",
        "icon": "font_download"
    }, {
        "id": "themeColors",
        "text": "Theme & Colors",
        "icon": "palette",
        "children": [{
            "text": "Colors & Themes",
            "icon": "colorize",
            "tabIndex": 100
        }, {
            "text": "Appearance",
            "icon": "opacity",
            "tabIndex": 101
        }, {
            "text": "Components",
            "icon": "dashboard",
            "tabIndex": 102
        }, {
            "text": "System & Settings",
            "icon": "settings",
            "tabIndex": 103
        }, {
            "text": "Displays",
            "icon": "monitor",
            "tabIndex": 104
        }]
    }, {
        "text": "Hyprland Theme",
        "icon": "window"
    }, {
        "text": "Wallpaper",
        "icon": "wallpaper"
    }, {
        "text": "Dock",
        "icon": "dock_to_bottom"
    }, {
        "text": "Top Bar",
        "icon": "toolbar"
    }, {
        "text": "Widgets",
        "icon": "widgets"
    }, {
        "text": "Desktop Widgets",
        "icon": "widgets"
    }, {
        "text": "Positioning",
        "icon": "open_with"
    }, {
        "text": "Launcher",
        "icon": "apps"
    }, {
        "text": "Default Apps",
        "icon": "apps"
    }, {
        "text": "Display Config",
        "icon": "settings"
    }, {
        "text": "Sound",
        "icon": "volume_up"
    }, {
        "text": "Network",
        "icon": "wifi"
    }, {
        "text": "Bluetooth",
        "icon": "bluetooth"
    }, {
        "text": "Keyboard & Language",
        "icon": "keyboard"
    }, {
        "text": "Time & Date",
        "icon": "schedule"
    }, {
        "text": "Power",
        "icon": "power_settings_new"
    }, {
        "text": "About",
        "icon": "info"
    }, {
        "text": "Weather",
        "icon": "cloud"
    }, {
        "text": "Keybinds",
        "icon": "keyboard"
    }]

    // Width is set by parent (SettingsModal), so we don't calculate it here
    // This allows the parent to control the width and make it reactive to window resizing
    height: parent.height

    Rectangle {
        id: sidebarBackground
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 16
        width: sidebarContainer.width - 16
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.6)
        radius: cornerRadius
        clip: false
        layer.enabled: true
        layer.smooth: true

        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1

        DarkFlickable {
            id: sidebarFlickable
            anchors.fill: parent
            contentHeight: sidebarColumn.height
            contentWidth: Math.max(width, sidebarColumn.implicitWidth)
            clip: false

        Column {
            id: sidebarColumn
            width: Math.max(parent.width, implicitWidth)
            spacing: 0

            ProfileSection {
                id: profileSection
                parentModal: sidebarContainer.parentModal
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
            }

            Item {
                width: parent.width
                height: {
                    const baseHeight = 16
                    const uiScale = typeof SettingsData !== "undefined" && SettingsData.settingsUiScale !== undefined 
                        ? SettingsData.settingsUiScale 
                        : 1.0
                    const controlScale = typeof SettingsData !== "undefined" && SettingsData.settingsUiAdvancedScaling && SettingsData.settingsUiControlScale !== undefined
                        ? SettingsData.settingsUiControlScale
                        : 1.0
                    return baseHeight * uiScale * controlScale
                }
            }

            Repeater {
                id: sidebarRepeater

                model: sidebarContainer.sidebarItems

                Column {
                    id: navItemContainer
                    required property int index
                    required property var modelData
                    
                    width: parent.width
                    spacing: 0
                    
                    property bool hasChildren: !!(modelData.children && modelData.children.length > 0)
                    property bool isExpanded: hasChildren ? sidebarContainer.isCategoryExpanded(modelData.id || "") : false
                    property bool isCategoryActive: hasChildren ? modelData.children.some(child => child.tabIndex === sidebarContainer.currentIndex) : false
                    property bool isActive: !hasChildren && sidebarContainer.currentIndex === index


                    Item {
                        id: navItem
                        width: parent.width
                        height: {
                            const baseHeight = 40
                            const uiScale = typeof SettingsData !== "undefined" && SettingsData.settingsUiScale !== undefined 
                                ? SettingsData.settingsUiScale 
                                : 1.0
                            const controlScale = typeof SettingsData !== "undefined" && SettingsData.settingsUiAdvancedScaling && SettingsData.settingsUiControlScale !== undefined
                                ? SettingsData.settingsUiControlScale
                                : 1.0
                            return baseHeight * uiScale * controlScale
                        }
                        
                        property bool isActive: navItemContainer.isActive || navItemContainer.isCategoryActive

                        Rectangle {
                            id: activeIndicator
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 3
                            color: Theme.primary
                            visible: navItem.isActive
                            radius: 0
                        }

                        Rectangle {
                            id: backgroundLayer
                            anchors.fill: parent
                            radius: 0
                            color: {
                                if (navItem.isActive) {
                                    return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                                }
                                if (navMouseArea.containsMouse) {
                                    return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.06)
                                }
                                return "transparent"
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Theme.standardEasing
                                }
                            }
                        }

                        Row {
                            id: rowContent
                            anchors.left: parent.left
                            anchors.leftMargin: {
                                const baseMargin = 20
                                const uiScale = typeof SettingsData !== "undefined" && SettingsData.settingsUiScale !== undefined 
                                    ? SettingsData.settingsUiScale 
                                    : 1.0
                                const controlScale = typeof SettingsData !== "undefined" && SettingsData.settingsUiAdvancedScaling && SettingsData.settingsUiControlScale !== undefined
                                    ? SettingsData.settingsUiControlScale
                                    : 1.0
                                return baseMargin * uiScale * controlScale
                            }
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingM
                            width: implicitWidth

                            DarkIcon {
                                name: navItemContainer.modelData.icon || ""
                                size: Theme.iconSize
                                color: {
                                    if (navItem.isActive) {
                                        return Theme.primary
                                    }
                                    if (navMouseArea.containsMouse) {
                                        return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.85)
                                    }
                                    return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item {
                                width: textMetrics.width
                                height: parent.height
                                anchors.verticalCenter: parent.verticalCenter

                                TextMetrics {
                                    id: textMetrics
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: navItem.isActive ? Font.Medium : Font.Normal
                                    text: navItemContainer.modelData.text || ""
                                }

                                StyledText {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: navItemContainer.modelData.text || ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: {
                                        if (navItem.isActive) {
                                            return Theme.primary
                                        }
                                        if (navMouseArea.containsMouse) {
                                            return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.95)
                                        }
                                        return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.85)
                                    }
                                    font.weight: navItem.isActive ? Font.Medium : Font.Normal
                                    width: textMetrics.width
                                }
                            }
                            
                            DarkIcon {
                                name: navItemContainer.isExpanded ? "expand_less" : "expand_more"
                                size: Theme.iconSize - 4
                                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                                anchors.verticalCenter: parent.verticalCenter
                                visible: navItemContainer.hasChildren
                            }
                        }

                        MouseArea {
                            id: navMouseArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: () => {
                                if (navItemContainer.hasChildren) {
                                    sidebarContainer.toggleCategory(navItemContainer.modelData.id || "")
                                } else {
                                    sidebarContainer.currentIndex = navItemContainer.index;
                                }
                            }
                        }
                    }
                    
                    // Children sub-items
                    Column {
                        id: childrenColumn
                        width: parent.width
                        spacing: 0
                        visible: navItemContainer.hasChildren && navItemContainer.isExpanded
                        
                        Repeater {
                            model: navItemContainer.modelData.children || []
                            
                            Item {
                                id: childNavItem
                                required property int index
                                required property var modelData
                                
                                width: parent.width
                                height: {
                                    const baseHeight = 36
                                    const uiScale = typeof SettingsData !== "undefined" && SettingsData.settingsUiScale !== undefined 
                                        ? SettingsData.settingsUiScale 
                                        : 1.0
                                    const controlScale = typeof SettingsData !== "undefined" && SettingsData.settingsUiAdvancedScaling && SettingsData.settingsUiControlScale !== undefined
                                        ? SettingsData.settingsUiControlScale
                                        : 1.0
                                    return baseHeight * uiScale * controlScale
                                }
                                
                                property bool isActive: sidebarContainer.currentIndex === modelData.tabIndex
                                
                                Rectangle {
                                    id: childActiveIndicator
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: 3
                                    color: Theme.primary
                                    visible: childNavItem.isActive
                                    radius: 0
                                }
                                
                                Rectangle {
                                    id: childBackgroundLayer
                                    anchors.fill: parent
                                    radius: 0
                                    color: {
                                        if (childNavItem.isActive) {
                                            return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                                        }
                                        if (childMouseArea.containsMouse) {
                                            return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.06)
                                        }
                                        return "transparent"
                                    }
                                    
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Theme.shortDuration
                                            easing.type: Theme.standardEasing
                                        }
                                    }
                                }
                                
                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: {
                                        const baseMargin = 20
                                        const uiScale = typeof SettingsData !== "undefined" && SettingsData.settingsUiScale !== undefined 
                                            ? SettingsData.settingsUiScale 
                                            : 1.0
                                        const controlScale = typeof SettingsData !== "undefined" && SettingsData.settingsUiAdvancedScaling && SettingsData.settingsUiControlScale !== undefined
                                            ? SettingsData.settingsUiControlScale
                                            : 1.0
                                        return (baseMargin + 24) * uiScale * controlScale
                                    }
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.spacingS
                                    
                                    DarkIcon {
                                        name: childNavItem.modelData.icon || ""
                                        size: Theme.iconSize - 4
                                        color: {
                                            if (childNavItem.isActive) {
                                                return Theme.primary
                                            }
                                            if (childMouseArea.containsMouse) {
                                                return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.85)
                                            }
                                            return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                                        }
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    StyledText {
                                        text: childNavItem.modelData.text || ""
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: {
                                            if (childNavItem.isActive) {
                                                return Theme.primary
                                            }
                                            if (childMouseArea.containsMouse) {
                                                return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.95)
                                            }
                                            return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.85)
                                        }
                                        font.weight: childNavItem.isActive ? Font.Medium : Font.Normal
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: childMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: () => {
                                        sidebarContainer.currentIndex = childNavItem.modelData.tabIndex;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: {
                    const baseHeight = 12
                    const uiScale = typeof SettingsData !== "undefined" && SettingsData.settingsUiScale !== undefined 
                        ? SettingsData.settingsUiScale 
                        : 1.0
                    const controlScale = typeof SettingsData !== "undefined" && SettingsData.settingsUiAdvancedScaling && SettingsData.settingsUiControlScale !== undefined
                        ? SettingsData.settingsUiControlScale
                        : 1.0
                    return baseHeight * uiScale * controlScale
                }
            }
        }
        }
    }
}
