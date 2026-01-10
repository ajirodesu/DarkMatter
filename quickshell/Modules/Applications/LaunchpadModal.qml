import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Modules.AppDrawer
import qs.Modals.Common
import qs.Services
import qs.Widgets

DarkModal {
    id: launchpad

    objectName: "launchpadModal"
    WlrLayershell.namespace: "quickshell:dock:blur"
    

    property bool launchpadOpen: false
    property var targetScreen: null
    property int gridSpacing: Theme.spacingXL
    property int horizontalPadding: 8
    property int verticalPadding: Theme.spacingS
    property int currentPage: 0
    readonly property int labelHeight: Theme.fontSizeSmall + Theme.spacingM
    readonly property int headerAllowance: 110
    readonly property int footerAllowance: 40
    readonly property var allowedScreens: SettingsData.getFilteredScreens("launchpad")
    readonly property var activeScreen: (targetScreen && allowedScreens.includes(targetScreen))
                                        ? targetScreen
                                        : (allowedScreens.length > 0 ? allowedScreens[0] : (Quickshell.screens.length > 0 ? Quickshell.screens[0] : null))
    readonly property int availableWidth: Math.max(1, width - horizontalPadding * 2)
    readonly property int availableHeight: Math.max(1, height - headerAllowance - footerAllowance - verticalPadding * 2)
    // Fixed grid to 15x15
    readonly property int columns: 12
    readonly property int rows: 6
    readonly property int itemsPerPage: columns * rows
    readonly property real gridIconSize: 128
    readonly property int pageCount: Math.max(1, Math.ceil(appLauncher.model.count / itemsPerPage))
    readonly property color surfaceBase: (Theme.surface && Theme.surface.r !== undefined) ? Theme.surface : Theme.background
    readonly property color surfaceContainerColor: (Theme.surfaceContainer && Theme.surfaceContainer.r !== undefined) ? Theme.surfaceContainer : surfaceBase
    readonly property color surfaceContainerHighColor: (Theme.surfaceContainerHigh && Theme.surfaceContainerHigh.r !== undefined) ? Theme.surfaceContainerHigh : surfaceContainerColor
    readonly property color surfaceContainerHighestColor: (Theme.surfaceContainerHighest && Theme.surfaceContainerHighest.r !== undefined) ? Theme.surfaceContainerHighest : surfaceContainerHighColor

    width: activeScreen ? activeScreen.width : (Quickshell.screens.length > 0 ? Quickshell.screens[0].width : 1920)
    height: activeScreen ? activeScreen.height : (Quickshell.screens.length > 0 ? Quickshell.screens[0].height : 1080)
    screen: activeScreen
    cornerRadius: 0
    enableShadow: false
    showBackground: true
    backgroundOpacity: 0.30
    backgroundColor: Qt.rgba(surfaceContainerHighColor.r, surfaceContainerHighColor.g, surfaceContainerHighColor.b, 0.75)
    animationType: "fade"
    closeOnEscapeKey: true
    closeOnBackgroundClick: true
    allowStacking: false
    shouldBeVisible: launchpadOpen
    shouldHaveFocus: launchpadOpen
    onBackgroundClicked: hide()
    onDialogClosed: launchpadOpen = false

    function show() {
        launchpadOpen = true
        open()
        currentPage = 0
        appLauncher.searchQuery = ""
        appLauncher.selectedIndex = 0
        Qt.callLater(() => {
            if (contentLoader.item && contentLoader.item.searchField) {
                contentLoader.item.searchField.forceActiveFocus()
            }
        })
    }

    function hide() {
        launchpadOpen = false
        close()
    }

    function toggle() {
        if (launchpadOpen) {
            hide()
        } else {
            show()
        }
    }

    onPageCountChanged: {
        if (currentPage >= pageCount) {
            currentPage = Math.max(0, pageCount - 1)
        }
    }

    AppLauncher {
        id: appLauncher
        viewMode: "grid"
        gridColumns: columns
        debounceSearch: true
        debounceInterval: 75
        maxResults: 800
        onAppLaunched: launchpad.hide()
    }

    content: Component {
        Rectangle {
            id: contentRoot

            anchors.fill: parent
            color: Qt.rgba(surfaceBase.r, surfaceBase.g, surfaceBase.b, 0.25)
            focus: true

            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_Escape) {
                    launchpad.hide()
                    event.accepted = true
                } else if (event.key === Qt.Key_Left && pageCount > 1 && !searchField.activeFocus) {
                    pageView.currentIndex = Math.max(0, pageView.currentIndex - 1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Right && pageCount > 1 && !searchField.activeFocus) {
                    pageView.currentIndex = Math.min(pageCount - 1, pageView.currentIndex + 1)
                    event.accepted = true
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.topMargin: launchpad.verticalPadding
                anchors.bottomMargin: 8
                spacing: Theme.spacingL

                Item {
                    Layout.preferredHeight: Theme.spacingXL
                }

                RowLayout {
                    id: searchRow
                    Layout.fillWidth: true
                    spacing: Theme.spacingS

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        id: searchFieldBox

                        Layout.preferredWidth: Math.min(520, launchpad.availableWidth * 0.6)
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        height: 48
                        radius: Theme.cornerRadius
                        color: Qt.rgba(surfaceContainerHighestColor.r, surfaceContainerHighestColor.g, surfaceContainerHighestColor.b, 0.9)
                        border.color: Qt.rgba(1, 1, 1, 0.35) // subtle light outline
                        border.width: 1
                        antialiasing: true

                        Row {
                            anchors.centerIn: parent
                            spacing: Theme.spacingS

                            DarkIcon {
                                id: searchIcon
                                name: "search"
                                size: Theme.iconSize
                                color: searchField.activeFocus ? Theme.primary : Theme.surfaceVariantText
                            }

                            TextInput {
                                id: searchField

                                width: Math.max(200, searchFieldBox.width - searchIcon.width - Theme.spacingM * 4)
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                horizontalAlignment: TextInput.AlignHCenter
                                verticalAlignment: TextInput.AlignVCenter
                                selectByMouse: true
                                clip: true
                                onTextChanged: {
                                    appLauncher.searchQuery = text
                                    launchpad.currentPage = 0
                                    pageView.currentIndex = 0
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Search apps"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceVariantText
                            horizontalAlignment: Text.AlignHCenter
                            visible: searchField.text.length === 0 && !searchField.activeFocus
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.IBeamCursor
                            onClicked: {
                                searchField.forceActiveFocus()
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                Item {
                    id: gridArea

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    SwipeView {
                        id: pageView

                        anchors.fill: parent
                        clip: false
                        interactive: pageCount > 1
                        currentIndex: launchpad.currentPage

                        onCurrentIndexChanged: launchpad.currentPage = currentIndex

                        Repeater {
                            model: launchpad.pageCount

                            Item {
                                property int pageIndex: index

                                width: pageView.width
                                height: pageView.height

                                Grid {
                                    id: iconGrid

                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    columns: launchpad.columns
                                    columnSpacing: launchpad.gridSpacing
                                    rowSpacing: launchpad.gridSpacing

                                    readonly property real cellWidth: launchpad.gridIconSize + Theme.spacingS * 2
                                    readonly property real cellHeight: launchpad.gridIconSize + launchpad.labelHeight + Theme.spacingM
                                    readonly property real computedWidth: columns * cellWidth + launchpad.gridSpacing * (launchpad.columns - 1)
                                    readonly property real computedHeight: launchpad.rows * cellHeight + launchpad.gridSpacing * (launchpad.rows - 1)

                                    width: Math.min(parent.width, computedWidth)
                                    height: Math.min(parent.height, computedHeight)

                                    Repeater {
                                        model: launchpad.itemsPerPage

                                        Item {
                                            property int globalIndex: (pageIndex * launchpad.itemsPerPage) + index
                                            property bool hasApp: globalIndex < appLauncher.model.count
                                            property var app: hasApp ? appLauncher.model.get(globalIndex) : null

                                            width: iconGrid.cellWidth
                                            height: iconGrid.cellHeight
                                            visible: hasApp

                                            Column {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: Theme.spacingXS
                                                opacity: hasApp ? 1.0 : 0.25

                                                Rectangle {
                                                    width: launchpad.gridIconSize
                                                    height: launchpad.gridIconSize
                                                    radius: Theme.cornerRadius * 1.2
                                                    color: appArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                                                    Item {
                                                        anchors.fill: parent
                                                        anchors.margins: Theme.spacingS
                                                        layer.enabled: SettingsData.systemIconTinting

                                                        Image {
                                                            anchors.fill: parent
                                                            sourceSize.width: parent.width
                                                            sourceSize.height: parent.height
                                                            fillMode: Image.PreserveAspectFit
                                                            source: hasApp ? Quickshell.iconPath(app.icon || "application-x-executable", true) : ""
                                                            smooth: true
                                                            asynchronous: true
                                                            visible: hasApp && status === Image.Ready
                                                        }

                                                        layer.effect: MultiEffect {
                                                            colorization: SettingsData.systemIconTinting ? SettingsData.iconTintIntensity : 0
                                                            colorizationColor: Theme.primary
                                                        }

                                                        Rectangle {
                                                            anchors.fill: parent
                                                            visible: !(hasApp && parent.children[0].visible)
                                                            color: Theme.surfaceLight
                                                            radius: Theme.cornerRadius
                                                            border.width: 0
                                                            border.color: "transparent"

                                                            StyledText {
                                                                anchors.centerIn: parent
                                                                text: hasApp && app.name && app.name.length > 0 ? app.name.charAt(0).toUpperCase() : "A"
                                                                font.pixelSize: parent.width * 0.4
                                                                color: Theme.primary
                                                                font.weight: Font.Bold
                                                            }
                                                        }
                                                    }

                                                    MouseArea {
                                                        id: appArea

                                                        anchors.fill: parent
                                                        hoverEnabled: hasApp
                                                        enabled: hasApp
                                                        cursorShape: hasApp ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                        onClicked: {
                                                            if (hasApp) {
                                                                appLauncher.launchApp(app)
                                                            }
                                                        }
                                                    }
                                                }

                                                StyledText {
                                                    width: launchpad.gridIconSize + Theme.spacingM
                                                    text: hasApp && app.name ? app.name : ""
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    font.weight: Font.Medium
                                                    color: Theme.surfaceText
                                                    horizontalAlignment: Text.AlignHCenter
                                                    elide: Text.ElideRight
                                                    maximumLineCount: 2
                                                    wrapMode: Text.WordWrap
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    radius: Theme.cornerRadius
                                    color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.35)
                                    visible: appLauncher.model.count === 0
                                    width: Math.min(parent.width * 0.5, 320)
                                    height: 120
                                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.25)
                                    border.width: 1
                                    z: 5

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: Theme.spacingS

                                        StyledText {
                                            text: "No apps found"
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Medium
                                            color: Theme.surfaceText
                                            horizontalAlignment: Text.AlignHCenter
                                            width: parent.width
                                        }

                                        StyledText {
                                            text: "Try a different search or install more apps."
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                            horizontalAlignment: Text.AlignHCenter
                                            width: parent.width - Theme.spacingM
                                            wrapMode: Text.WordWrap
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    id: pageIndicators

                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.iconSize
                    visible: launchpad.pageCount > 1

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.spacingS

                        Repeater {
                            model: launchpad.pageCount

                            Rectangle {
                                width: launchpad.currentPage === index ? 18 : 10
                                height: 6
                                radius: 3
                                color: launchpad.currentPage === index ? Theme.primary : Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.35)
                                opacity: 0.9
                            }
                        }
                    }
                }
            }

            Connections {
                target: launchpad
                function onShouldBeVisibleChanged() {
                    if (!launchpad.shouldBeVisible) {
                        searchField.text = ""
                    } else {
                        Qt.callLater(() => searchField.forceActiveFocus())
                    }
                }
            }
        }
    }
}

