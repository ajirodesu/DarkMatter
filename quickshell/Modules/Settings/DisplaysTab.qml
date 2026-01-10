import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Modules.Settings
import qs.Services
import qs.Widgets

Item {
    id: displaysTab

    property var parentModal: null
    property bool nested: false  // Set to true when used inside another Flickable

    DarkFlickable {
        id: displaysFlickable
        anchors.fill: parent
        clip: true
        interactive: !displaysTab.nested  // Disable interaction when nested
        contentHeight: displaysColumn.height
        contentWidth: width

        Column {
            id: displaysColumn
            width: parent.width
            spacing: Theme.spacingXL

    property var variantComponents: [{
        "id": "topBar",
        "name": "Top Bar",
        "description": "System bar with widgets and system information",
        "icon": "toolbar"
    }, {
        "id": "dock",
        "name": "Application Dock",
        "description": "Bottom dock for pinned and running applications",
        "icon": "dock"
    }, {
        "id": "notifications",
        "name": "Notification Popups",
        "description": "Notification toast popups",
        "icon": "notifications"
    }, {
        "id": "wallpaper",
        "name": "Wallpaper",
        "description": "Desktop background images",
        "icon": "wallpaper"
    }, {
        "id": "osd",
        "name": "On-Screen Displays",
        "description": "Volume, brightness, and other system OSDs",
        "icon": "picture_in_picture"
    }, {
        "id": "toast",
        "name": "Toast Messages",
        "description": "System toast notifications",
        "icon": "campaign"
    }, {
        "id": "notepad",
        "name": "Notepad Slideout",
        "description": "Quick note-taking slideout panel",
        "icon": "sticky_note_2"
    }, {
        "id": "systemTray",
        "name": "System Tray",
        "description": "System tray icons",
        "icon": "notifications"
    }, {
        "id": "desktopWidgets",
        "name": "Desktop Widgets",
        "description": "Floating desktop widgets for system monitoring",
        "icon": "widgets"
    }, {
        "id": "launchpad",
        "name": "Launchpad",
        "description": "Full-screen app grid launcher",
        "icon": "apps"
            }, {
                "id": "alttab",
                "name": "Alt+Tab Switcher",
                "description": "Window switcher for Alt+Tab keyboard shortcut",
                "icon": "swap_horiz"
    }]

    function getScreenPreferences(componentId) {
                var prefs = SettingsData.screenPreferences && SettingsData.screenPreferences[componentId];
                if (!prefs || prefs.length === 0) {
                    return ["all"];
                }
                // For desktop widgets, return as-is (supports object format)
                if (componentId === "desktopWidgets") {
                    return prefs;
                }
                // For other components, ensure string format
                return prefs;
    }

    function setScreenPreferences(componentId, screenNames) {
        var prefs = SettingsData.screenPreferences ? Object.assign({}, SettingsData.screenPreferences) : {};
        prefs[componentId] = screenNames;
        SettingsData.setScreenPreferences(prefs);
    }

            StyledRect {
                width: parent.width
                height: screensInfoSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: screensInfoSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "monitor"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Connected Displays"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Configure which displays show shell components"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }

                        }

                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Available Screens (" + Quickshell.screens.length + ")"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        Repeater {
                            model: Quickshell.screens

                            delegate: Rectangle {
                                width: parent.width
                                height: screenRow.implicitHeight + Theme.spacingS * 2
                                radius: Theme.cornerRadius
                                color: Theme.surfaceContainerHigh
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
                                border.width: 1

                                Row {
                                    id: screenRow

                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    spacing: Theme.spacingM

                                    DarkIcon {
                                        name: "desktop_windows"
                                        size: Theme.iconSize - 4
                                        color: Theme.primary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        width: parent.width - Theme.iconSize - Theme.spacingM * 2
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: Theme.spacingXS / 2

                                        StyledText {
                                            text: modelData.name
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Medium
                                            color: Theme.surfaceText
                                        }

                                        Row {
                                            spacing: Theme.spacingS

                                            StyledText {
                                                text: modelData.width + "×" + modelData.height
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceVariantText
                                            }

                                            StyledText {
                                                text: "•"
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceVariantText
                                            }

                                            StyledText {
                                                text: modelData.model || "Unknown Model"
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceVariantText
                                            }

                                        }

                                    }

                                }

                            }

                        }

                    }

                }

            }

            Column {
                width: parent.width
                spacing: Theme.spacingL

                Repeater {
                    model: displaysColumn.variantComponents

                    delegate: StyledRect {
                        width: parent.width
                        height: componentSection.implicitHeight + Theme.spacingL * 2
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                        border.width: 1

                        Column {
                            id: componentSection

                            anchors.fill: parent
                            anchors.margins: Theme.spacingL
                            spacing: Theme.spacingM

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                DarkIcon {
                                    name: modelData.icon
                                    size: Theme.iconSize
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    width: parent.width - Theme.iconSize - Theme.spacingM
                                    spacing: Theme.spacingXS
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        text: modelData.name
                                        font.pixelSize: Theme.fontSizeLarge
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }

                                    StyledText {
                                        text: modelData.description
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                    }

                                }

                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Show on screens:"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                // Use SettingsDisplayPicker for desktop widgets
                                Loader {
                                    width: parent.width
                                    active: modelData.id === "desktopWidgets"
                                    sourceComponent: Component {
                                        SettingsDisplayPicker {
                                            width: parent.width
                                            displayPreferences: displaysColumn.getScreenPreferences("desktopWidgets")
                                            onPreferencesChanged: preferences => {
                                                displaysColumn.setScreenPreferences("desktopWidgets", preferences);
                                            }
                                        }
                                    }
                                }

                                // Use old toggle system for other components
                                Column {
                                    property string componentId: modelData.id
                                    property var selectedScreens: displaysColumn.getScreenPreferences(componentId)
                                    visible: modelData.id !== "desktopWidgets"

                                    width: parent.width
                                    spacing: Theme.spacingXS

                                    DarkToggle {
                                        width: parent.width
                                        text: "All displays"
                                        description: "Show on all connected displays"
                                        checked: {
                                            var prefs = parent.selectedScreens;
                                            if (!Array.isArray(prefs)) return true;
                                            return prefs.includes("all");
                                        }
                                        onToggled: (checked) => {
                                            if (checked) {
                                                displaysColumn.setScreenPreferences(parent.componentId, ["all"]);
                                            } else {
                                                var allScreenNames = [];
                                                for (var i = 0; i < Quickshell.screens.length; i++) {
                                                    allScreenNames.push(Quickshell.screens[i].name);
                                                }
                                                displaysColumn.setScreenPreferences(parent.componentId, allScreenNames);
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: Theme.outline
                                        opacity: 0.2
                                        visible: {
                                            var prefs = parent.selectedScreens;
                                            if (!Array.isArray(prefs)) return false;
                                            return !prefs.includes("all");
                                        }
                                    }

                                    Column {
                                        width: parent.width
                                        spacing: Theme.spacingXS
                                        visible: {
                                            var prefs = parent.selectedScreens;
                                            if (!Array.isArray(prefs)) return false;
                                            return !prefs.includes("all");
                                        }

                                        Repeater {
                                            model: Quickshell.screens

                                            delegate: DarkToggle {
                                                property string screenName: modelData.name
                                                property string componentId: parent.parent.componentId

                                                width: parent.width
                                                text: screenName
                                                description: modelData.width + "×" + modelData.height + " • " + (modelData.model || "Unknown Model")
                                                checked: {
                                                    var prefs = displaysColumn.getScreenPreferences(componentId);
                                                    if (!Array.isArray(prefs) || prefs.includes("all")) return false;
                                                    // Handle both string and object formats
                                                    return prefs.some(p => {
                                                        if (typeof p === "string") return p === screenName;
                                                        return p?.name === screenName;
                                                    });
                                                }
                                                onToggled: (checked) => {
                                                    var currentPrefs = displaysColumn.getScreenPreferences(componentId);
                                                    if (currentPrefs.includes("all"))
                                                        currentPrefs = [];

                                                    var newPrefs = currentPrefs.slice();
                                                    if (checked) {
                                                        if (!newPrefs.some(p => {
                                                            if (typeof p === "string") return p === screenName;
                                                            return p?.name === screenName;
                                                        }))
                                                            newPrefs.push(screenName);

                                                    } else {
                                                        newPrefs = newPrefs.filter(p => {
                                                            if (typeof p === "string") return p !== screenName;
                                                            return p?.name !== screenName;
                                                        });
                                                    }
                                                    displaysColumn.setScreenPreferences(componentId, newPrefs);
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

        }
    }
}
