import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.DarkDash

Item {
    id: root

    anchors.fill: parent

    property string instanceId: ""
    property var instanceData: null
    readonly property var cfg: instanceData?.config ?? null
    readonly property bool isInstance: instanceId !== "" && cfg !== null

    property real widgetWidth: 700
    property real widgetHeight: 500
    property real defaultWidth: 700
    property real defaultHeight: 500
    property real minWidth: 400
    property real minHeight: 300

    property int currentTabIndex: 0

    readonly property real transparency: isInstance ? (cfg.transparency ?? 0.92) : SettingsData.desktopDarkDashTransparency
    readonly property real contentBackgroundOpacity: isInstance ? (cfg.contentBackgroundOpacity ?? 1.0) : SettingsData.desktopDarkDashContentBackgroundOpacity
    readonly property real borderOpacity: isInstance ? (cfg.borderOpacity ?? 0.0) : SettingsData.desktopDarkDashBorderOpacity
    readonly property real borderThickness: isInstance ? (cfg.borderThickness ?? 0) : SettingsData.desktopDarkDashBorderThickness
    readonly property real dropShadowOpacity: isInstance ? (cfg.dropShadowOpacity ?? 0.15) : SettingsData.desktopDarkDashDropShadowOpacity
    readonly property real tabBarOpacity: isInstance ? (cfg.tabBarOpacity ?? 1.0) : SettingsData.desktopDarkDashTabBarOpacity
    readonly property real animatedTintOpacity: isInstance ? (cfg.animatedTintOpacity ?? 0.04) : SettingsData.desktopDarkDashAnimatedTintOpacity

    Rectangle {
        id: mainContainer
        anchors.fill: parent
        radius: Theme.cornerRadius
        opacity: root.transparency
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, root.contentBackgroundOpacity)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, root.borderOpacity)
        border.width: root.borderThickness
        antialiasing: true

        layer.enabled: root.dropShadowOpacity > 0
        layer.smooth: true
        layer.effect: DropShadow {
            id: dropShadow
            horizontalOffset: 0
            verticalOffset: 0
            radius: SettingsData.desktopWidgetDropShadowRadius
            samples: Math.max(128, Math.ceil(SettingsData.desktopWidgetDropShadowRadius * 2.5))
            color: Qt.rgba(0, 0, 0, root.dropShadowOpacity)
            transparentBorder: true
            cached: false
            spread: 0
        }
        
        Connections {
            target: SettingsData
            function onDesktopWidgetDropShadowRadiusChanged() {
                dropShadow.radius = SettingsData.desktopWidgetDropShadowRadius
                dropShadow.samples = Math.max(128, Math.ceil(SettingsData.desktopWidgetDropShadowRadius * 2.5))
            }
        }

        Rectangle {
            id: animatedTintRect
            anchors.fill: parent
            color: Qt.rgba(Theme.surfaceTint.r, Theme.surfaceTint.g, Theme.surfaceTint.b, 1.0)
            radius: parent.radius
            opacity: root.animatedTintOpacity
            visible: root.animatedTintOpacity > 0

            SequentialAnimation on opacity {
                running: root.animatedTintOpacity > 0
                loops: Animation.Infinite

                NumberAnimation {
                    to: Math.min(1.0, root.animatedTintOpacity * 2)
                    duration: Theme.extraLongDuration
                    easing.type: Theme.standardEasing
                }

                NumberAnimation {
                    to: Math.max(0.0, root.animatedTintOpacity * 0.5)
                    duration: Theme.extraLongDuration
                    easing.type: Theme.standardEasing
                }
            }
        }

        Column {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            DarkTabBar {
                id: tabBar

                width: parent.width
                height: 48
                currentIndex: root.currentTabIndex
                spacing: Theme.spacingS
                equalWidthTabs: true
                opacity: root.tabBarOpacity

                model: {
                    let tabs = [
                        { icon: "dashboard", text: "Overview" },
                        { icon: "music_note", text: "Media" }
                    ]
                    
                    if (SettingsData.weatherEnabled) {
                        tabs.push({ icon: "wb_sunny", text: "Weather" })
                    }
                    
                    tabs.push({ icon: "settings", text: "Settings", isAction: true })
                    return tabs
                }

                onTabClicked: function(index) {
                    root.currentTabIndex = index
                }

                onActionTriggered: function(index) {
                    let settingsIndex = SettingsData.weatherEnabled ? 3 : 2
                    if (index === settingsIndex) {
                        settingsModal.show()
                    }
                }
            }

            Item {
                width: parent.width
                height: Theme.spacingXS
            }

            StackLayout {
                id: pages
                width: parent.width
                height: Math.max(0, root.height - tabBar.height - Theme.spacingXS - Theme.spacingS - Theme.spacingM * 2)
                currentIndex: root.currentTabIndex

                OverviewTab {
                    id: overviewTab
                    // StackLayout manages size automatically - no anchors needed

                    onSwitchToWeatherTab: {
                        if (SettingsData.weatherEnabled) {
                            tabBar.currentIndex = 2
                            tabBar.tabClicked(2)
                        }
                    }

                    onSwitchToMediaTab: {
                        tabBar.currentIndex = 1
                        tabBar.tabClicked(1)
                    }
                }

                MediaPlayerTab {
                    id: mediaTab
                    // StackLayout manages size automatically - no anchors needed
                }

                WeatherTab {
                    id: weatherTab
                    // StackLayout manages size automatically - no anchors needed
                    visible: SettingsData.weatherEnabled && root.currentTabIndex === 2
                }
            }
        }
    }
}
