import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Modals.Common
import qs.Services
import qs.Widgets

DarkModal {
    id: altTabModal

    WlrLayershell.namespace: "quickshell:dock:blur"

    property bool altTabOpen: false
    property var targetScreen: null
    property int selectedIndex: 0
    readonly property var allWindows: {
        if (!CompositorService.sortedToplevels) {
            return []
        }

        // Use CompositorService.sortedToplevels for consistent ordering
        const toplevels = CompositorService.sortedToplevels.slice(0, 10)
        const allWindowsData = OverviewService.getAllWindowsFlat()

        return toplevels.map((toplevel, index) => {
            // Find the corresponding window data from OverviewService
            const windowData = allWindowsData.find(w => w.toplevel === toplevel)
            if (windowData) {
                return {
                    toplevel: windowData.toplevel,
                    appId: windowData.appId,
                    title: windowData.title,
                    address: windowData.address,
                    isActive: windowData.isActive,
                    workspaceId: windowData.workspaceId,
                    monitorName: windowData.monitorName,
                    index: index,
                    globalIndex: index
                }
            }

            // Fallback if OverviewService doesn't have data for this toplevel
            const hyprlandToplevels = Array.from(Hyprland.toplevels?.values || [])
            const hyprToplevel = hyprlandToplevels.find(ht => ht.wayland === toplevel)

            return {
                toplevel: toplevel,
                appId: hyprToplevel?.appId || hyprToplevel?.class || "",
                title: hyprToplevel?.title || "",
                address: hyprToplevel?.address || "",
                isActive: hyprToplevel?.active || false,
                workspaceId: hyprToplevel?.workspace?.id || -1,
                monitorName: hyprToplevel?.monitor?.name || "unknown",
                index: index,
                globalIndex: index
            }
        })
    }
    readonly property var allowedScreens: SettingsData.getFilteredScreens("alttab")
    readonly property var activeScreen: (targetScreen && allowedScreens.includes(targetScreen))
                                        ? targetScreen
                                        : (allowedScreens.length > 0 ? allowedScreens[0] : (Quickshell.screens.length > 0 ? Quickshell.screens[0] : null))

    // Compact modal settings - transparent overlay
    width: Math.min(activeScreen ? activeScreen.width * 0.8 : 1200, allWindows.length * 200 + 100)
    height: 180
    screen: activeScreen
    cornerRadius: Theme.cornerRadius
    backgroundOpacity: 0.0
    backgroundColor: "transparent"
    showBackground: false
    enableShadow: false
    animationType: "fade"
    closeOnEscapeKey: true
    closeOnBackgroundClick: false
    allowStacking: false
    shouldBeVisible: altTabOpen
    shouldHaveFocus: altTabOpen
    positioning: "center"

    function show() {
        console.log("AltTabModal: show() called")
        altTabOpen = true
        console.log("AltTabModal: set altTabOpen to true, shouldHaveFocus:", shouldHaveFocus)
        open()
        selectedIndex = 0
        console.log("AltTabModal: opened modal, selectedIndex:", selectedIndex, "allWindows.length:", allWindows.length)
        OverviewService.refreshWindows()
        OverviewService.captureAllScreenshots()
    }

    function hide() {
        altTabOpen = false
        close()
    }

    function toggle() {
        if (altTabOpen) {
            hide()
        } else {
            show()
        }
    }

    function selectWindow(index) {
        if (index >= 0 && index < allWindows.length) {
            const window = allWindows[index]
            if (window) {
                OverviewService.activateWindow(window)
                hide()
            }
        }
    }



    content: Component {
        Item {
            anchors.fill: parent
            focus: true

            Keys.onPressed: (event) => {
                console.log("AltTabModal: Key pressed:", event.key, "altTabOpen:", altTabModal.altTabOpen)
                if (event.key === Qt.Key_Escape) {
                    console.log("AltTabModal: Escape pressed, hiding")
                    altTabModal.hide()
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    console.log("AltTabModal: Enter pressed, selecting window", altTabModal.selectedIndex)
                    altTabModal.selectWindow(altTabModal.selectedIndex)
                    event.accepted = true
                } else if (event.key === Qt.Key_Left) {
                    altTabModal.selectedIndex = Math.max(0, altTabModal.selectedIndex - 1)
                    console.log("AltTabModal: Left arrow, new selectedIndex:", altTabModal.selectedIndex)
                    event.accepted = true
                } else if (event.key === Qt.Key_Right) {
                    altTabModal.selectedIndex = Math.min(altTabModal.allWindows.length - 1, altTabModal.selectedIndex + 1)
                    console.log("AltTabModal: Right arrow, new selectedIndex:", altTabModal.selectedIndex)
                    event.accepted = true
                } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                    const num = event.key - Qt.Key_1 // 0-8 for keys 1-9
                    console.log("AltTabModal: Number key", event.key - Qt.Key_0, "pressed, num:", num, "allWindows.length:", altTabModal.allWindows.length)
                    if (num < altTabModal.allWindows.length) {
                        console.log("AltTabModal: Selecting window at index", num)
                        altTabModal.selectWindow(num)
                        event.accepted = true
                    }
                } else if (event.key === Qt.Key_0) {
                    console.log("AltTabModal: Key 0 pressed, allWindows.length:", altTabModal.allWindows.length)
                    if (altTabModal.allWindows.length >= 10) {
                        console.log("AltTabModal: Selecting 10th window (index 9)")
                        altTabModal.selectWindow(9) // 0 key selects the 10th window (index 9)
                        event.accepted = true
                    }
                }
            }

            Component.onCompleted: {
                console.log("AltTabModal content: Component completed, forcing focus")
                forceActiveFocus()
            }

            onActiveFocusChanged: {
                console.log("AltTabModal content: Active focus changed to:", activeFocus)
            }

            Row {
                anchors.centerIn: parent
                spacing: Theme.spacingM

                Repeater {
                    model: Math.min(allWindows.length, 10) // Limit to 10 windows

                    Rectangle {
                        id: windowItem

                        property bool isSelected: index === selectedIndex
                        property var windowData: allWindows[index]

                        width: 160
                        height: 120
                        radius: Theme.cornerRadius
                        color: isSelected ? Theme.primaryContainer : Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.8)
                        border.width: isSelected ? 3 : 1
                        border.color: isSelected ? Theme.primary : Theme.outlineMedium

                        scale: isSelected ? 1.05 : 1.0
                        Behavior on scale {
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }

                        Column {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingS
                            spacing: Theme.spacingXS

                            // Window preview/thumbnail
                            Rectangle {
                                width: parent.width
                                height: parent.height - 30
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceVariant
                                clip: true

                                Image {
                                    id: windowScreenshot
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectCrop
                                    source: windowData ? OverviewService.getWindowScreenshot(windowData) : ""
                                    visible: status === Image.Ready && source !== ""
                                    asynchronous: true
                                }

                                Image {
                                    id: appIcon
                                    anchors.centerIn: parent
                                    width: 48
                                    height: 48
                                    fillMode: Image.PreserveAspectFit
                                    source: windowData ? OverviewService.getAppIcon(windowData.appId) : ""
                                    visible: (windowScreenshot.status !== Image.Ready || !windowScreenshot.source) && status === Image.Ready && source !== ""
                                }

                                DarkIcon {
                                    anchors.centerIn: parent
                                    size: 48
                                    name: "window"
                                    color: Theme.surfaceText
                                    visible: (windowScreenshot.status !== Image.Ready || !windowScreenshot.source) &&
                                             (appIcon.status !== Image.Ready || appIcon.source === "")
                                }

                                // Number label
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: Theme.spacingXS
                                    width: 24
                                    height: 24
                                    radius: 12
                                    color: Theme.primary
                                    visible: index < 10

                                                StyledText {
                                                    anchors.centerIn: parent
                                                    text: index === 9 ? "0" : String(index + 1)
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    font.weight: Font.Bold
                                                    color: Theme.onPrimary
                                                }
                                }

                                // Active indicator
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: 4
                                    color: Theme.primary
                                    visible: windowData && windowData.isActive
                                }
                            }

                            // Window title
                            StyledText {
                                width: parent.width
                                text: windowData ? windowData.title : ""
                                font.pixelSize: Theme.fontSizeSmall
                                color: isSelected ? Theme.primaryText : Theme.surfaceText
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                                maximumLineCount: 1
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                selectedIndex = index
                                selectWindow(index)
                            }

                            onEntered: {
                                selectedIndex = index
                            }
                        }
                    }
                }
            }

            // Empty state
            Item {
                anchors.centerIn: parent
                width: 200
                height: 100
                visible: allWindows.length === 0

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.spacingM

                    DarkIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        size: 48
                        name: "window"
                        color: Theme.surfaceTextAlpha
                    }

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No windows open"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceTextMedium
                    }
                }
            }
        }
    }

    Connections {
        target: ModalManager
        function onCloseAllModalsExcept(excludedModal) {
            if (excludedModal !== altTabModal && altTabOpen) {
                altTabOpen = false
            }
        }
    }
}