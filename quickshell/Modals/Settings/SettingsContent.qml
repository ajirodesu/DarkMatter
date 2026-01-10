import QtQuick
import qs.Common
import qs.Modules.Settings

Item {
    id: root

    property int currentIndex: 0
    property var parentModal: null
    
    Component.onCompleted: {
        
        Qt.callLater(function() {
            refreshAllSettings()
        })
    }

    Timer {
        id: settingsInitTimer
        interval: 100
        repeat: true
        running: false
        
        onTriggered: {
            if (typeof ColorPaletteService !== 'undefined' && 
                typeof SettingsData !== 'undefined' && 
                typeof Theme !== 'undefined') {
                running = false
                refreshAllSettings()
            } else {
            }
        }
    }

    function refreshAllSettings() {
        
        if (typeof ColorPaletteService !== 'undefined') {
            ColorPaletteService.updateAvailableThemes()
        }
        
        if (typeof SettingsData !== 'undefined') {
            SettingsData.loadSettings()
        }
        
        if (typeof Theme !== 'undefined') {
            Theme.generateSystemThemesFromCurrentTheme()
        }
        
    }

    function forceInitialize() {
        settingsInitTimer.running = true
    }

    Item {
        anchors.fill: parent
        

        Item {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 24
            anchors.bottomMargin: 24
            width: Math.min(parent.width - 48, 1400)
            anchors.horizontalCenter: parent.horizontalCenter
            clip: false

            Loader {
                id: personalizationLoader

                anchors.fill: parent
            active: root.currentIndex === 0
            visible: active
            asynchronous: false

            sourceComponent: Component {
                PersonalizationTab {
                    parentModal: root.parentModal
                }

            }

        }

        Loader {
            id: fontsLoader

            anchors.fill: parent
            active: root.currentIndex === 1
            visible: active
            asynchronous: true

            sourceComponent: Component {
                FontsTab {
                    parentModal: root.parentModal
                }
            }

        }

        // Theme & Colors sub-tabs (indices 100-103)
        Loader {
            id: colorsThemesLoader
            anchors.fill: parent
            active: root.currentIndex === 100
            visible: active
            asynchronous: true
            sourceComponent: Component {
                ColorsThemesTab {
                    parentModal: root.parentModal
                }
            }
        }
        
        Loader {
            id: appearanceLoader
            anchors.fill: parent
            active: root.currentIndex === 101
            visible: active
            asynchronous: true
            sourceComponent: Component {
                AppearanceTab {
                    parentModal: root.parentModal
                }
            }
        }
        
        Loader {
            id: componentsLoader
            anchors.fill: parent
            active: root.currentIndex === 102
            visible: active
            asynchronous: true
            sourceComponent: Component {
                ComponentsTab {
                    parentModal: root.parentModal
                }
            }
        }
        
        Loader {
            id: systemSettingsLoader
            anchors.fill: parent
            active: root.currentIndex === 103
            visible: active
            asynchronous: true
            sourceComponent: Component {
                SystemSettingsTab {
                    parentModal: root.parentModal
                }
            }
        }
        
        Loader {
            id: displaysLoader
            anchors.fill: parent
            active: root.currentIndex === 104
            visible: active
            asynchronous: true
            sourceComponent: Component {
                DisplaysTab {
                    parentModal: root.parentModal
                }
            }
        }
        
        // Legacy ThemeColorsTab for Displays tab (index 2) - will be replaced with DisplaysTab later
        Loader {
            id: themeColorsLoader

            anchors.fill: parent
            active: root.currentIndex === 2
            visible: active
            asynchronous: true

            sourceComponent: Component {
                ThemeColorsTab {
                parentModal: root.parentModal
                }
            }

        }

        Loader {
            id: hyprlandThemeLoader

            anchors.fill: parent
            active: root.currentIndex === 3
            visible: active
            asynchronous: true

            sourceComponent: Component {
                HyprlandThemeTab {
                    parentModal: root.parentModal
                }
            }

        }

        Loader {
            id: wallpaperLoader

            anchors.fill: parent
            active: root.currentIndex === 4
            visible: active
            asynchronous: true

            sourceComponent: Component {
                WallpaperTab {
                    parentModal: root.parentModal
                }
            }

        }

        Loader {
            id: dockLoader

            anchors.fill: parent
            active: root.currentIndex === 5
            visible: active
            asynchronous: true

            sourceComponent: Component {
                DockTab {
                }
            }

            onLoaded: {
                if (item) {
                    item.forceActiveFocus()
                }
            }
        }

        Loader {
            id: topBarLoader

            anchors.fill: parent
            active: root.currentIndex === 6
            visible: active
            asynchronous: true

            sourceComponent: TopBarTab {
            }

        }

        Loader {
            id: widgetsLoader

            anchors.fill: parent
            active: root.currentIndex === 7
            visible: active
            asynchronous: true

            source: "../../Modules/Settings/WidgetTweaksTab.qml"

        }

        Loader {
            id: desktopWidgetsLoader

            anchors.fill: parent
            active: root.currentIndex === 8
            visible: active
            asynchronous: true

            sourceComponent: Component {
                DesktopWidgetsTab {
                    parentModal: root.parentModal
                }
            }
        }

        Loader {
            id: positioningLoader

            anchors.fill: parent
            active: root.currentIndex === 9
            visible: active
            asynchronous: true

            sourceComponent: PositioningTab {
            }

        }

        Loader {
            id: launcherLoader

            anchors.fill: parent
            active: root.currentIndex === 10
            visible: active
            asynchronous: true

            sourceComponent: LauncherTab {
            }

        }

        Loader {
            id: defaultAppsLoader

            anchors.fill: parent
            active: root.currentIndex === 11
            visible: active
            asynchronous: true

            sourceComponent: DefaultAppsTab {
            }

        }

        Loader {
            id: displayConfigLoader

            anchors.fill: parent
            active: root.currentIndex === 12
            visible: active
            asynchronous: true

            sourceComponent: Component {
                DisplayConfigTab {
                }
            }

            onLoaded: {
                if (item && typeof item.tabActivated !== 'undefined') {
                    item.tabActivated()
                }
            }

            onActiveChanged: {
                if (active && item && typeof item.tabActivated !== 'undefined') {
                    Qt.callLater(() => {
                        if (item) {
                            item.tabActivated()
                        }
                    })
                }
            }
        }

        Loader {
            id: soundLoader

            anchors.fill: parent
            active: root.currentIndex === 13
            visible: active
            asynchronous: true

            sourceComponent: SoundTab {
            }

        }

        Loader {
            id: networkLoader

            anchors.fill: parent
            active: root.currentIndex === 14
            visible: active
            asynchronous: true

            sourceComponent: NetworkTab {
                parentModal: root.parentModal
            }

        }

        Loader {
            id: bluetoothLoader

            anchors.fill: parent
            active: root.currentIndex === 15
            visible: active
            asynchronous: true

            sourceComponent: BluetoothTab {
            }

        }

        Loader {
            id: keyboardLangLoader

            anchors.fill: parent
            active: root.currentIndex === 16
            visible: active
            asynchronous: true

            sourceComponent: KeyboardLangTab {
            }

        }

        Loader {
            id: timeLoader

            anchors.fill: parent
            active: root.currentIndex === 17
            visible: active
            asynchronous: true

            sourceComponent: TimeTab {
            }

        }

        Loader {
            id: powerLoader

            anchors.fill: parent
            active: root.currentIndex === 18
            visible: active
            asynchronous: true

            sourceComponent: PowerTab {
            }

        }

        Loader {
            id: aboutLoader

            anchors.fill: parent
            active: root.currentIndex === 19
            visible: active
            asynchronous: true

            sourceComponent: AboutTab {
            }

        }

        Loader {
            id: weatherLoader

            anchors.fill: parent
            active: root.currentIndex === 20
            visible: active
            asynchronous: true

            sourceComponent: WeatherTab {
            }

        }

        Loader {
            id: keybindsLoader

            anchors.fill: parent
            active: root.currentIndex === 21
            visible: active
            asynchronous: true

            source: "../../Modules/Settings/KeybindsTab.qml"

            }
        }
    }

}
