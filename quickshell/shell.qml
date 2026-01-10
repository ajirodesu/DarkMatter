import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland
import qs.Common
import qs.Modals
import qs.Modals.Clipboard
import qs.Modals.Common
import qs.Modals.Settings
import qs.Modals.Spotlight
import qs.Modals.Overview
import qs.Modules
import qs.Modules.AppDrawer
import qs.Modules.DarkDash
import qs.Modules.Applications
import qs.Modules.ControlCenter
import qs.Modules.Dock
import qs.Modules.Lock
import qs.Modules.Notifications.Center
import qs.Widgets
import "./Modules/Notepad"
import qs.Modules.Notifications.Popup
import qs.Modules.OSD
import qs.Modules.ProcessList
import qs.Modules.Settings
import qs.Modules.TopBar
import qs.Modules.Desktop
import qs.Services
import "./Common/PowerActionUtils.js" as PowerActionUtils

ShellRoot {
    id: root

    Component.onCompleted: {
        PortalService.init()
        // Removed property accesses that were causing premature initialization
        // and triggering Qt.callLater before QCoreApplication was ready
    }

    Connections {
        target: ColorPaletteService
        function onCustomThemeCreated(themeData) {
            if (themeData) {
            }
        }
    }

    WallpaperBackground {}

    DesktopWidgetLayer {}

    Lock {
        id: lock

        anchors.fill: parent
    }

    Loader {
        id: topBarVariantsLoader
        active: true
        sourceComponent: Component {
            Variants {
                id: topBarVariants
                model: SettingsData.getFilteredScreens("topBar")

                delegate: TopBar {
                    modelData: item
                    notepadVariants: notepadSlideoutVariants
                    onColorPickerRequested: colorPickerModal.show()
                }
            }
        }
    }

    Connections {
        target: SettingsData
        function onTopBarPositionChanged() {
            Qt.callLater(() => {
                topBarVariantsLoader.active = false
                Qt.callLater(() => {
                    topBarVariantsLoader.active = true
                })
            })
        }
    }




    Loader {
        id: dockVariantsLoader
        active: true
        sourceComponent: Component {
            Variants {
                model: SettingsData.getFilteredScreens("dock")

                delegate: Dock {
                    modelData: item
                    contextMenu: dockContextMenuLoader.item ? dockContextMenuLoader.item : null
                    Component.onCompleted: {
                        dockContextMenuLoader.active = true
                    }
                }
            }
        }
    }

    Connections {
        target: SettingsData
        function onDockExpandToScreenChanged() {
            Qt.callLater(() => {
                dockVariantsLoader.active = false
                Qt.callLater(() => {
                    dockVariantsLoader.active = true
                })
            })
        }
        function onDockCenterAppsChanged() {
            Qt.callLater(() => {
                dockVariantsLoader.active = false
                Qt.callLater(() => {
                    dockVariantsLoader.active = true
                })
            })
        }
    }

    LazyLoader {
        id: darkDashLoader

        active: false

        DarkDashPopout {
            id: darkDashPopout
        }
    }

    LazyLoader {
        id: applicationsLoader

        active: false

        ApplicationsPopout {
            id: applicationsPopout
        }
    }

    LazyLoader {
        id: launchpadLoader

        active: false

        LaunchpadModal {
            id: launchpadModal
        }
    }

    LazyLoader {
        id: dockContextMenuLoader

        active: false

        DockContextMenu {
            id: dockContextMenu
        }
    }

    LazyLoader {
        id: notificationCenterLoader

        active: false

        NotificationCenterPopout {
            id: notificationCenter
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("notifications")

        delegate: NotificationPopupManager {
            modelData: item
        }
    }

    LazyLoader {
        id: controlCenterLoader

        active: false

        ControlCenterPopout {
            id: controlCenterPopout

            onPowerActionRequested: (action, title, message) => {
                                        powerConfirmModalLoader.active = true
                                        if (powerConfirmModalLoader.item) {
                                            powerConfirmModalLoader.item.confirmButtonColor = action === "poweroff" ? Theme.error : action === "reboot" ? Theme.warning : Theme.primary
                                            powerConfirmModalLoader.item.show(title, message, function () {
                                                switch (action) {
                                                case "logout":
                                                    SessionService.logout()
                                                    break
                                                case "suspend":
                                                    SessionService.suspend()
                                                    break
                                                case "reboot":
                                                    SessionService.reboot()
                                                    break
                                                case "poweroff":
                                                    SessionService.poweroff()
                                                    break
                                                }
                                            }, function () {})
                                        }
                                    }
            onLockRequested: {
                lock.activate()
            }
        }
    }

    LazyLoader {
        id: wifiPasswordModalLoader

        active: false

        WifiPasswordModal {
            id: wifiPasswordModal
        }
    }

    LazyLoader {
        id: networkInfoModalLoader

        active: false

        NetworkInfoModal {
            id: networkInfoModal
        }
    }

    LazyLoader {
        id: batteryPopoutLoader

        active: false

        BatteryPopout {
            id: batteryPopout
        }
    }

    LazyLoader {
        id: vpnPopoutLoader

        active: false

        VpnPopout {
            id: vpnPopout
        }
    }

    LazyLoader {
        id: volumeMixerPopoutLoader

        active: false

        VolumeMixerPopout {
            id: volumeMixerPopout
        }
    }

    LazyLoader {
        id: powerMenuLoader

        active: false

        PowerMenu {
            id: powerMenu

            onPowerActionRequested: (action, title, message) => {
                                        if (!PowerActionUtils.isValidPowerAction(action)) {
                                            return
                                        }
                                        powerConfirmModalLoader.active = true
                                        if (powerConfirmModalLoader.item) {
                                            powerConfirmModalLoader.item.confirmButtonColor = PowerActionUtils.getPowerActionColor(action, Theme)
                                            powerConfirmModalLoader.item.show(title, message, function () {
                                                PowerActionUtils.executePowerAction(action, SessionService)
                                            }, function () {})
                                        }
                                    }
        }
    }

    LazyLoader {
        id: powerConfirmModalLoader

        active: false

        ConfirmModal {
            id: powerConfirmModal
        }
    }

    LazyLoader {
        id: processListPopoutLoader

        active: false

        ProcessListPopout {
            id: processListPopout
        }
    }

    SettingsModal {
        id: settingsModal
    }

    LazyLoader {
        id: appDrawerLoader

        active: false

        AppDrawerPopout {
            id: appDrawerPopout
        }
    }

    SpotlightModal {
        id: spotlightModal
    }

    AltTabModal {
        id: altTabModal
    }

    Variants {
        id: overviewModalVariants
        model: Quickshell.screens
        
        property var instances: []
        property var instancesSet: null
        
        delegate: OverviewModal {
            id: overviewModalInstance
            modelData: item
            
            Component.onCompleted: {
                if (!overviewModalVariants.instancesSet) {
                    overviewModalVariants.instancesSet = new Set()
                }
                overviewModalVariants.instancesSet.add(overviewModalInstance)
                if (overviewModalVariants.instances.indexOf(overviewModalInstance) === -1) {
                    overviewModalVariants.instances.push(overviewModalInstance)
                }
            }
            
            Component.onDestruction: {
                if (overviewModalVariants.instancesSet) {
                    overviewModalVariants.instancesSet.delete(overviewModalInstance)
                }
                const index = overviewModalVariants.instances.indexOf(overviewModalInstance)
                if (index !== -1) {
                    overviewModalVariants.instances.splice(index, 1)
                }
            }
        }
    }
    
    function toggleOverview() {
        altTabModal.toggle()
    }
    
    Item {
        id: globalKeyHandler
        focus: true
        Keys.onPressed: (event) => {
            if ((event.modifiers & Qt.AltModifier) && event.key === Qt.Key_Tab) {
                toggleOverview()
                event.accepted = true
            }
        }
    }
    
    function hideAllOverviewModals() {
        const instances = overviewModalVariants.instances || []
        instances.forEach(instance => {
            if (instance && instance.hide) {
                instance.hide()
            }
        })
    }
    
    IpcHandler {
        function open(): string {
            toggleOverview()
            return "OVERVIEW_OPEN_SUCCESS"
        }

        function close(): string {
            hideAllOverviewModals()
            return "OVERVIEW_CLOSE_SUCCESS"
        }

        function toggle(): string {
            toggleOverview()
            return "OVERVIEW_TOGGLE_SUCCESS"
        }

        target: "overview"
    }

    ClipboardHistoryModal {
        id: clipboardHistoryModalPopup
    }

    NotificationModal {
        id: notificationModal
    }
    ColorPickerModal {
        id: colorPickerModal
    }

    LazyLoader {
        id: processListModalLoader

        active: false

        ProcessListModal {
            id: processListModal
        }
    }

    LazyLoader {
        id: systemUpdateLoader

        active: false

        SystemUpdatePopout {
            id: systemUpdatePopout
        }
    }

    Variants {
        id: notepadSlideoutVariants
        model: SettingsData.getFilteredScreens("notepad")

        delegate: DarkSlideout {
            id: notepadSlideout
            modelData: item
            title: qsTr("Notepad")
            slideoutWidth: 480
            expandable: true
            expandedWidthValue: 960
            customTransparency: SettingsData.notepadTransparencyOverride

            content: Component {
                Notepad {
                    onHideRequested: {
                        notepadSlideout.hide()
                    }
                }
            }

            function toggle() {
                if (isVisible) {
                    hide()
                } else {
                    show()
                }
            }
        }
    }

    LazyLoader {
        id: powerMenuModalLoader

        active: false

        PowerMenuModal {
            id: powerMenuModal

            onPowerActionRequested: (action, title, message) => {
                                        if (!PowerActionUtils.isValidPowerAction(action)) {
                                            return
                                        }
                                        powerConfirmModalLoader.active = true
                                        if (powerConfirmModalLoader.item) {
                                            powerConfirmModalLoader.item.confirmButtonColor = PowerActionUtils.getPowerActionColor(action, Theme)
                                            powerConfirmModalLoader.item.show(title, message, function () {
                                                PowerActionUtils.executePowerAction(action, SessionService)
                                            }, function () {})
                                        }
                                    }
        }
    }

    IpcHandler {
        function open() {
            powerMenuModalLoader.active = true
            if (powerMenuModalLoader.item)
                powerMenuModalLoader.item.open()

            return "POWERMENU_OPEN_SUCCESS"
        }

        function close() {
            if (powerMenuModalLoader.item)
                powerMenuModalLoader.item.close()

            return "POWERMENU_CLOSE_SUCCESS"
        }

        function toggle() {
            powerMenuModalLoader.active = true
            if (powerMenuModalLoader.item)
                powerMenuModalLoader.item.toggle()

            return "POWERMENU_TOGGLE_SUCCESS"
        }

        target: "powermenu"
    }

    IpcHandler {
        function open(): string {
            processListModalLoader.active = true
            if (processListModalLoader.item)
                processListModalLoader.item.show()

            return "PROCESSLIST_OPEN_SUCCESS"
        }

        function close(): string {
            if (processListModalLoader.item)
                processListModalLoader.item.hide()

            return "PROCESSLIST_CLOSE_SUCCESS"
        }

        function toggle(): string {
            processListModalLoader.active = true
            if (processListModalLoader.item)
                processListModalLoader.item.toggle()

            return "PROCESSLIST_TOGGLE_SUCCESS"
        }

        target: "processlist"
    }

    IpcHandler {
        function open(tab: string): string {
            darkDashLoader.active = true
            if (darkDashLoader.item) {
                switch (tab.toLowerCase()) {
                case "media":
                    darkDashLoader.item.currentTabIndex = 1
                    break
                case "weather":
                    darkDashLoader.item.currentTabIndex = SettingsData.weatherEnabled ? 2 : 0
                    break
                default:
                    darkDashLoader.item.currentTabIndex = 0
                    break
                }
                darkDashLoader.item.setTriggerPosition(Screen.width / 2, Theme.barHeight + Theme.spacingS, 100, "center", Screen)
                darkDashLoader.item.show()
                return "DASH_OPEN_SUCCESS"
            }
            return "DASH_OPEN_FAILED"
        }

        function close(): string {
            if (darkDashLoader.item) {
                darkDashLoader.item.close()
                return "DASH_CLOSE_SUCCESS"
            }
            return "DASH_CLOSE_FAILED"
        }

        function toggle(tab: string): string {
            darkDashLoader.active = true
            if (darkDashLoader.item) {
                if (darkDashLoader.item.shouldBeVisible) {
                    darkDashLoader.item.close()
                } else {
                    switch (tab.toLowerCase()) {
                    case "media":
                        darkDashLoader.item.currentTabIndex = 1
                        break
                    case "weather":
                        darkDashLoader.item.currentTabIndex = SettingsData.weatherEnabled ? 2 : 0
                        break
                    default:
                        darkDashLoader.item.currentTabIndex = 0
                        break
                    }
                    darkDashLoader.item.setTriggerPosition(Screen.width / 2, Theme.barHeight + Theme.spacingS, 100, "center", Screen)
                    darkDashLoader.item.show()
                }
                return "DASH_TOGGLE_SUCCESS"
            }
            return "DASH_TOGGLE_FAILED"
        }

        target: "darkDash"
    }

    IpcHandler {
        function getFocusedScreenName() {
            if (CompositorService.isHyprland && Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.monitor) {
                return Hyprland.focusedWorkspace.monitor.name
            }
            if (CompositorService.isNiri && NiriService.currentOutput) {
                return NiriService.currentOutput
            }
            return ""
        }

        function getActiveNotepadInstance() {
            if (notepadSlideoutVariants.instances.length === 0) {
                return null
            }

            if (notepadSlideoutVariants.instances.length === 1) {
                return notepadSlideoutVariants.instances[0]
            }

            var focusedScreen = getFocusedScreenName()
            if (focusedScreen && notepadSlideoutVariants.instances.length > 0) {
                for (var i = 0; i < notepadSlideoutVariants.instances.length; i++) {
                    var slideout = notepadSlideoutVariants.instances[i]
                    if (slideout.modelData && slideout.modelData.name === focusedScreen) {
                        return slideout
                    }
                }
            }

            for (var i = 0; i < notepadSlideoutVariants.instances.length; i++) {
                var slideout = notepadSlideoutVariants.instances[i]
                if (slideout.isVisible) {
                    return slideout
                }
            }

            return notepadSlideoutVariants.instances[0]
        }

        function open(): string {
            var instance = getActiveNotepadInstance()
            if (instance) {
                instance.show()
                return "NOTEPAD_OPEN_SUCCESS"
            }
            return "NOTEPAD_OPEN_FAILED"
        }

        function close(): string {
            var instance = getActiveNotepadInstance()
            if (instance) {
                instance.hide()
                return "NOTEPAD_CLOSE_SUCCESS"
            }
            return "NOTEPAD_CLOSE_FAILED"
        }

        function toggle(): string {
            var instance = getActiveNotepadInstance()
            if (instance) {
                instance.toggle()
                return "NOTEPAD_TOGGLE_SUCCESS"
            }
            return "NOTEPAD_TOGGLE_FAILED"
        }

        target: "notepad"
    }

    IpcHandler {
        function open(): string {
            appDrawerLoader.active = true
            if (appDrawerLoader.item) {
                appDrawerLoader.item.show()
                return "APPDRAWER_OPEN_SUCCESS"
            }
            return "APPDRAWER_OPEN_FAILED"
        }

        function close(): string {
            if (appDrawerLoader.item) {
                appDrawerLoader.item.close()
                return "APPDRAWER_CLOSE_SUCCESS"
            }
            return "APPDRAWER_CLOSE_FAILED"
        }

        function toggle(): string {
            appDrawerLoader.active = true
            if (appDrawerLoader.item) {
                if (appDrawerLoader.item.shouldBeVisible) {
                    appDrawerLoader.item.close()
                    return "APPDRAWER_CLOSE_SUCCESS"
                } else {
                    appDrawerLoader.item.show()
                    return "APPDRAWER_OPEN_SUCCESS"
                }
            }
            return "APPDRAWER_TOGGLE_FAILED"
        }

        target: "appDrawerPopout"
    }

    Variants {
        model: SettingsData.getFilteredScreens("toast")

        delegate: Toast {
            modelData: item
            visible: ToastService.toastVisible
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: VolumeOSD {
            modelData: item
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: MicMuteOSD {
            modelData: item
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: BrightnessOSD {
            modelData: item
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: IdleInhibitorOSD {
            modelData: item
        }
    }
}
