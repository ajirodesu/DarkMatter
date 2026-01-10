import Qt.labs.folderlistmodel
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modals
import qs.Modals.FileBrowser
import qs.Services
import qs.Widgets

Item {
    id: wallpaperTab

    property var parentModal: null
    property string selectedMonitorName: {
        var screens = Quickshell.screens
        return screens.length > 0 ? screens[0].name : ""
    }
    property var monitors: []
    property var monitorCapabilities: ({})
    property bool loading: false
    property string wallpaperGalleryDir: ""
    property int galleryCurrentPage: 0
    property int galleryItemsPerPage: 20
    property int galleryTotalPages: Math.max(1, Math.ceil(wallpaperGalleryModel.count / galleryItemsPerPage))
    property int galleryGridIndex: 0

    Component.onCompleted: {
        loadMonitors()
        // Wait a bit for CacheData to load, then load wallpaper directory
        Qt.callLater(() => {
            loadWallpaperGalleryDir()
        })
    }

    function loadWallpaperGalleryDir() {
        // Load from SessionData.wallpaperLastPath
        if (SessionData.wallpaperLastPath && SessionData.wallpaperLastPath !== "") {
            wallpaperGalleryDir = SessionData.wallpaperLastPath
        } else {
            // Try to get directory from current wallpaper
            var currentWallpaper = SessionData.perMonitorWallpaper ? 
                SessionData.getMonitorWallpaper(selectedMonitorName) : 
                SessionData.wallpaperPath
            if (currentWallpaper && currentWallpaper !== "" && !currentWallpaper.startsWith("#") && !currentWallpaper.startsWith("we:")) {
                var lastSlash = currentWallpaper.lastIndexOf('/')
                if (lastSlash > 0) {
                    wallpaperGalleryDir = currentWallpaper.substring(0, lastSlash)
                    SessionData.wallpaperLastPath = wallpaperGalleryDir
                    SessionData.saveSettings()
                }
            }
        }
    }

    function loadMonitors() {
        loading = true
        monitors = []
        monitorCapabilities = {}

        var screens = Quickshell.screens
        for (var i = 0; i < screens.length; i++) {
            var screen = screens[i]
            monitors.push({
                name: screen.name,
                width: screen.width,
                height: screen.height,
                scale: "1.0",
                position: "",
                disabled: false
            })
            monitorCapabilities[screen.name] = {
                width: screen.width,
                height: screen.height,
                make: screen.manufacturer || "",
                model: screen.model || "",
                description: screen.name
            }
        }

        loading = false
    }

    DarkFlickable {
        anchors.fill: parent
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingL

            StyledRect {
                width: parent.width
                height: wallpaperHeaderSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.4)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.15)
                border.width: 1

                Column {
                    id: wallpaperHeaderSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "wallpaper"
                            size: Theme.iconSize
                            color: Theme.primary
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: Theme.spacingXS
                            Layout.alignment: Qt.AlignVCenter

                            StyledText {
                                text: "Wallpaper"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: SessionData.perMonitorWallpaper ? "Set wallpapers for each monitor individually" : "Set wallpaper for all displays"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Per-Monitor Wallpapers"
                        description: "Enable different wallpapers for each connected monitor"
                        checked: SessionData.perMonitorWallpaper
                        onToggled: toggled => {
                            SessionData.setPerMonitorWallpaper(toggled)
                        }
                    }
                }
            }

            MonitorArrangementWidget {
                id: arrangementWidget
                width: parent.width
                monitors: wallpaperTab.monitors
                monitorCapabilities: wallpaperTab.monitorCapabilities
                selectedMonitor: SessionData.perMonitorWallpaper ? selectedMonitorName : ""
                visible: wallpaperTab.monitors.length > 0 && !wallpaperTab.loading
                onMonitorSelected: function(monitorName) {
                    selectedMonitorName = monitorName
                }
            }

            StyledText {
                text: "Loading monitors..."
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceVariantText
                visible: wallpaperTab.loading
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            StyledRect {
                width: parent.width
                height: allDisplaysWallpaperSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.4)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.15)
                border.width: 1
                visible: !wallpaperTab.loading && wallpaperTab.monitors.length > 0 && !SessionData.perMonitorWallpaper

                Column {
                    id: allDisplaysWallpaperSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "desktop_windows"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "All Displays"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Set the same wallpaper for all connected displays"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingL

                        StyledRect {
                            property real thumbnailWidth: Math.floor((parent.width - Theme.spacingL - 4 - (2 * 4)) / 5)
                            property real thumbnailHeight: Math.floor((300 - 4 - (2 * 2)) / 3)
                            width: thumbnailWidth
                            height: thumbnailHeight
                            radius: Theme.cornerRadius
                            color: Theme.surfaceVariant
                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                            border.width: 1

                            property string currentWallpaper: SessionData.wallpaperPath

                            CachingImage {
                                anchors.fill: parent
                                anchors.margins: 1
                                property var weExtensions: [".jpg", ".jpeg", ".png", ".webp", ".gif", ".bmp", ".tga"]
                                property int weExtIndex: 0
                                property string currentWallpaperPath: {
                                    var wp = parent.currentWallpaper
                                    if (wp && wp.startsWith("we:")) {
                                        var sceneId = wp.substring(3)
                                        return StandardPaths.writableLocation(StandardPaths.HomeLocation)
                                            + "/.local/share/Steam/steamapps/workshop/content/431960/"
                                            + sceneId + "/preview" + weExtensions[weExtIndex]
                                    }
                                    return (wp !== "" && !wp.startsWith("#")) ? wp : ""
                                }
                                imagePath: currentWallpaperPath
                                onStatusChanged: {
                                    var wp = parent.currentWallpaper
                                    if (wp && wp.startsWith("we:") && status === Image.Error) {
                                        if (weExtIndex < weExtensions.length - 1) {
                                            weExtIndex++
                                            imagePath = ""
                                            Qt.callLater(() => {
                                                imagePath = StandardPaths.writableLocation(StandardPaths.HomeLocation)
                                                    + "/.local/share/Steam/steamapps/workshop/content/431960/"
                                                    + wp.substring(3)
                                                    + "/preview" + weExtensions[weExtIndex]
                                            })
                                        } else {
                                            visible = false
                                        }
                                    }
                                }
                                fillMode: Image.PreserveAspectFit
                                visible: {
                                    var wp = parent.currentWallpaper
                                    return wp !== "" && !wp.startsWith("#")
                                }
                                maxCacheSize: 512
                                layer.enabled: true

                                layer.effect: MultiEffect {
                                    maskEnabled: true
                                    maskSource: allDisplaysWallpaperMask
                                    maskThresholdMin: 0.5
                                    maskSpreadAtMin: 1
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 1
                                radius: Theme.cornerRadius - 1
                                color: {
                                    var wp = parent.currentWallpaper
                                    return wp && wp.startsWith("#") ? wp : "transparent"
                                }
                                visible: {
                                    var wp = parent.currentWallpaper
                                    return wp !== "" && wp && wp.startsWith("#")
                                }
                            }

                            Rectangle {
                                id: allDisplaysWallpaperMask
                                anchors.fill: parent
                                anchors.margins: 1
                                radius: Theme.cornerRadius - 1
                                color: "black"
                                visible: false
                                layer.enabled: true
                            }

                            DarkIcon {
                                anchors.centerIn: parent
                                name: "image"
                                size: Theme.iconSizeLarge + 8
                                color: Theme.surfaceVariantText
                                visible: {
                                    var wp = parent.currentWallpaper
                                    return wp === ""
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 1
                                radius: Theme.cornerRadius - 1
                                color: Qt.rgba(0, 0, 0, 0.7)
                                visible: allDisplaysPreviewMouseArea.containsMouse

                                Row {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingS

                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: Theme.cornerRadius
                                        color: Qt.rgba(255, 255, 255, 0.9)

                                        DarkIcon {
                                            anchors.centerIn: parent
                                            name: "folder_open"
                                            size: 20
                                            color: "black"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (parentModal) {
                                                    parentModal.allowFocusOverride = true
                                                    parentModal.shouldHaveFocus = false
                                                }
                                                wallpaperBrowser.open()
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: Theme.cornerRadius
                                        color: Qt.rgba(255, 255, 255, 0.9)

                                        DarkIcon {
                                            anchors.centerIn: parent
                                            name: "palette"
                                            size: 20
                                            color: "black"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                colorPicker.open()
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: Theme.cornerRadius
                                        color: Qt.rgba(255, 255, 255, 0.9)
                                        visible: SessionData.wallpaperPath !== ""

                                        DarkIcon {
                                            anchors.centerIn: parent
                                            name: "clear"
                                            size: 20
                                            color: "black"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (Theme.currentTheme === Theme.dynamic)
                                                    Theme.switchTheme("blue")
                                                SessionData.clearWallpaper()
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: allDisplaysPreviewMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                propagateComposedEvents: true
                                acceptedButtons: Qt.NoButton
                            }
                        }

                        Column {
                            width: parent.width - 200 - Theme.spacingL
                            spacing: Theme.spacingS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: SessionData.wallpaperPath ? SessionData.wallpaperPath.split('/').pop() : "No wallpaper selected"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                elide: Text.ElideMiddle
                                maximumLineCount: 1
                                width: parent.width
                            }

                            StyledText {
                                text: SessionData.wallpaperPath ? SessionData.wallpaperPath : ""
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                elide: Text.ElideMiddle
                                maximumLineCount: 1
                                width: parent.width
                                visible: SessionData.wallpaperPath !== ""
                            }

                            Row {
                                spacing: Theme.spacingS
                                visible: SessionData.wallpaperPath !== "" && !SessionData.wallpaperPath.startsWith("#") && !SessionData.wallpaperPath.startsWith("we")

                                DarkActionButton {
                                    buttonSize: 36
                                    iconName: "skip_previous"
                                    iconSize: Theme.iconSizeSmall
                                    backgroundColor: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.4)
                                    iconColor: Theme.surfaceText
                                    onClicked: {
                                        WallpaperCyclingService.cyclePrevManually()
                                    }
                                }

                                DarkActionButton {
                                    buttonSize: 36
                                    iconName: "skip_next"
                                    iconSize: Theme.iconSizeSmall
                                    backgroundColor: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.4)
                                    iconColor: Theme.surfaceText
                                    onClicked: {
                                        WallpaperCyclingService.cycleNextManually()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Repeater {
                model: SessionData.perMonitorWallpaper ? wallpaperTab.monitors : []
                visible: !wallpaperTab.loading && wallpaperTab.monitors.length > 0

                delegate: StyledRect {
                    width: parent.width
                    height: monitorWallpaperSection.implicitHeight + Theme.spacingL * 2
                    radius: Theme.cornerRadius
                    color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.4)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.15)
                    border.width: 1

                    Column {
                        id: monitorWallpaperSection
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
                                    text: modelData.name
                                    font.pixelSize: Theme.fontSizeLarge
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }

                                StyledText {
                                    text: {
                                        var caps = wallpaperTab.monitorCapabilities[modelData.name] || {}
                                        return (caps.width || modelData.width) + "×" + (caps.height || modelData.height)
                                    }
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                }
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingL

                            StyledRect {
                                property real thumbnailWidth: Math.floor((parent.width - Theme.spacingL - 4 - (2 * 4)) / 5)
                                property real thumbnailHeight: Math.floor((300 - 4 - (2 * 2)) / 3)
                                width: thumbnailWidth
                                height: thumbnailHeight
                                radius: Theme.cornerRadius
                                color: Theme.surfaceVariant
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                                border.width: 1

                                property string currentWallpaper: SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(modelData.name) : SessionData.wallpaperPath

                                CachingImage {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    property var weExtensions: [".jpg", ".jpeg", ".png", ".webp", ".gif", ".bmp", ".tga"]
                                    property int weExtIndex: 0
                                    property string currentWallpaperPath: {
                                        var wp = parent.currentWallpaper
                                        if (wp && wp.startsWith("we:")) {
                                            var sceneId = wp.substring(3)
                                            return StandardPaths.writableLocation(StandardPaths.HomeLocation)
                                                + "/.local/share/Steam/steamapps/workshop/content/431960/"
                                                + sceneId + "/preview" + weExtensions[weExtIndex]
                                        }
                                        return (wp !== "" && !wp.startsWith("#")) ? wp : ""
                                    }
                                    imagePath: currentWallpaperPath
                                    onStatusChanged: {
                                        var wp = parent.currentWallpaper
                                        if (wp && wp.startsWith("we:") && status === Image.Error) {
                                            if (weExtIndex < weExtensions.length - 1) {
                                                weExtIndex++
                                                imagePath = ""
                                                Qt.callLater(() => {
                                                    imagePath = StandardPaths.writableLocation(StandardPaths.HomeLocation)
                                                        + "/.local/share/Steam/steamapps/workshop/content/431960/"
                                                        + wp.substring(3)
                                                        + "/preview" + weExtensions[weExtIndex]
                                                })
                                            } else {
                                                visible = false
                                            }
                                        }
                                    }
                                    fillMode: Image.PreserveAspectFit
                                    visible: {
                                        var wp = parent.currentWallpaper
                                        return wp !== "" && !wp.startsWith("#")
                                    }
                                    maxCacheSize: 512
                                    layer.enabled: true

                                    layer.effect: MultiEffect {
                                        maskEnabled: true
                                        maskSource: wallpaperMask
                                        maskThresholdMin: 0.5
                                        maskSpreadAtMin: 1
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    radius: Theme.cornerRadius - 1
                                    color: {
                                        var wp = parent.currentWallpaper
                                        return wp && wp.startsWith("#") ? wp : "transparent"
                                    }
                                    visible: {
                                        var wp = parent.currentWallpaper
                                        return wp !== "" && wp && wp.startsWith("#")
                                    }
                                }

                                Rectangle {
                                    id: wallpaperMask
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    radius: Theme.cornerRadius - 1
                                    color: "black"
                                    visible: false
                                    layer.enabled: true
                                }

                                DarkIcon {
                                    anchors.centerIn: parent
                                    name: "image"
                                    size: Theme.iconSizeLarge + 8
                                    color: Theme.surfaceVariantText
                                    visible: {
                                        var wp = parent.currentWallpaper
                                        return wp === ""
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    radius: Theme.cornerRadius - 1
                                    color: Qt.rgba(0, 0, 0, 0.7)
                                    visible: wallpaperPreviewMouseArea.containsMouse

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: Theme.spacingS

                                        Rectangle {
                                            width: 40
                                            height: 40
                                            radius: Theme.cornerRadius
                                            color: Qt.rgba(255, 255, 255, 0.9)

                                            DarkIcon {
                                                anchors.centerIn: parent
                                                name: "folder_open"
                                                size: 20
                                                color: "black"
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (parentModal) {
                                                        parentModal.allowFocusOverride = true
                                                        parentModal.shouldHaveFocus = false
                                                    }
                                                    wallpaperBrowser.open()
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: 40
                                            height: 40
                                            radius: Theme.cornerRadius
                                            color: Qt.rgba(255, 255, 255, 0.9)

                                            DarkIcon {
                                                anchors.centerIn: parent
                                                name: "palette"
                                                size: 20
                                                color: "black"
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    colorPicker.open()
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: 40
                                            height: 40
                                            radius: Theme.cornerRadius
                                            color: Qt.rgba(255, 255, 255, 0.9)
                                            visible: {
                                                var wp = parent.parent.parent.parent.currentWallpaper
                                                return wp !== ""
                                            }

                                            DarkIcon {
                                                anchors.centerIn: parent
                                                name: "clear"
                                                size: 20
                                                color: "black"
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (SessionData.perMonitorWallpaper) {
                                                        SessionData.setMonitorWallpaper(modelData.name, "")
                                                    } else {
                                                        if (Theme.currentTheme === Theme.dynamic)
                                                            Theme.switchTheme("blue")
                                                        SessionData.clearWallpaper()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: wallpaperPreviewMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    propagateComposedEvents: true
                                    acceptedButtons: Qt.NoButton
                                }
                            }

                            Column {
                                width: parent.width - 200 - Theme.spacingL
                                spacing: Theme.spacingS
                                anchors.verticalCenter: parent.verticalCenter

                                StyledText {
                                    text: {
                                        var wp = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(modelData.name) : SessionData.wallpaperPath
                                        return wp ? wp.split('/').pop() : "No wallpaper selected"
                                    }
                                    font.pixelSize: Theme.fontSizeLarge
                                    color: Theme.surfaceText
                                    elide: Text.ElideMiddle
                                    maximumLineCount: 1
                                    width: parent.width
                                }

                                StyledText {
                                    text: {
                                        var wp = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(modelData.name) : SessionData.wallpaperPath
                                        return wp ? wp : ""
                                    }
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    elide: Text.ElideMiddle
                                    maximumLineCount: 1
                                    width: parent.width
                                    visible: {
                                        var wp = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(modelData.name) : SessionData.wallpaperPath
                                        return wp !== ""
                                    }
                                }

                                Row {
                                    spacing: Theme.spacingS
                                    visible: {
                                        var wp = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(modelData.name) : SessionData.wallpaperPath
                                        return wp !== "" && !wp.startsWith("#") && !wp.startsWith("we")
                                    }

                                    DarkActionButton {
                                        buttonSize: 36
                                        iconName: "skip_previous"
                                        iconSize: Theme.iconSizeSmall
                                        backgroundColor: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.4)
                                        iconColor: Theme.surfaceText
                                        onClicked: {
                                            if (SessionData.perMonitorWallpaper) {
                                                WallpaperCyclingService.cyclePrevForMonitor(modelData.name)
                                            } else {
                                                WallpaperCyclingService.cyclePrevManually()
                                            }
                                        }
                                    }

                                    DarkActionButton {
                                        buttonSize: 36
                                        iconName: "skip_next"
                                        iconSize: Theme.iconSizeSmall
                                        backgroundColor: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.4)
                                        iconColor: Theme.surfaceText
                                        onClicked: {
                                            if (SessionData.perMonitorWallpaper) {
                                                WallpaperCyclingService.cycleNextForMonitor(modelData.name)
                                            } else {
                                                WallpaperCyclingService.cycleNextManually()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Current Wallpaper Banner
            StyledRect {
                width: parent.width
                height: 120
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                border.color: Theme.primary
                border.width: 1
                visible: {
                    var wp = SessionData.perMonitorWallpaper ? 
                        SessionData.getMonitorWallpaper(selectedMonitorName) : 
                        SessionData.wallpaperPath
                    return wp && wp !== "" && !wp.startsWith("#") && !wp.startsWith("we:")
                }

                Row {
                    id: currentWallpaperBannerContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Theme.spacingM
                    anchors.rightMargin: Theme.spacingM
                    spacing: Theme.spacingM

                    // Wallpaper Preview
                    StyledRect {
                        width: 160
                        height: 90
                        radius: Theme.cornerRadius
                        color: Theme.surfaceVariant
                        border.color: Theme.outline
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        property string currentWallpaperPath: {
                            var wp = SessionData.perMonitorWallpaper ? 
                                SessionData.getMonitorWallpaper(selectedMonitorName) : 
                                SessionData.wallpaperPath
                            if (!wp || wp === "" || wp.startsWith("#") || wp.startsWith("we:")) {
                                return ""
                            }
                            return wp
                        }

                        CachingImage {
                            id: bannerPreviewImage
                            anchors.fill: parent
                            anchors.margins: 1
                            imagePath: parent.currentWallpaperPath
                            maxCacheSize: 1024
                            fillMode: Image.PreserveAspectCrop

                            layer.enabled: true
                            layer.effect: MultiEffect {
                                maskEnabled: true
                                maskThresholdMin: 0.5
                                maskSpreadAtMin: 1.0
                                maskSource: ShaderEffectSource {
                                    sourceItem: Rectangle {
                                        width: bannerPreviewImage.width
                                        height: bannerPreviewImage.height
                                        radius: Theme.cornerRadius
                                        color: "black"
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 160 - Theme.spacingM
                        spacing: 4

                        StyledText {
                            text: "Current Wallpaper"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.primary
                            font.weight: Font.Medium
                        }

                        StyledText {
                            property string currentWallpaper: {
                                var wp = SessionData.perMonitorWallpaper ? 
                                    SessionData.getMonitorWallpaper(selectedMonitorName) : 
                                    SessionData.wallpaperPath
                                if (!wp || wp === "" || wp.startsWith("#") || wp.startsWith("we:")) {
                                    return ""
                                }
                                // Get just the filename
                                var parts = wp.split('/')
                                return parts.length > 0 ? parts[parts.length - 1] : wp
                            }
                            text: currentWallpaper || "No wallpaper selected"
                            font.pixelSize: Theme.fontSizeSmall - 2
                            color: Theme.surfaceText
                            elide: Text.ElideMiddle
                            width: parent.width
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: 500
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.4)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.15)
                border.width: 1
                visible: true

                Column {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingS

                    // Compact Header Section
                    Row {
                        width: parent.width
                        spacing: Theme.spacingS
                        height: 32

                        DarkActionButton {
                            id: browseGalleryButton
                            iconName: "folder_open"
                            iconSize: Theme.iconSizeSmall
                            buttonSize: 32
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                if (parentModal) {
                                    parentModal.allowFocusOverride = true
                                    parentModal.shouldHaveFocus = false
                                }
                                wallpaperBrowser.open()
                            }
                        }

                        Column {
                            width: parent.width - browseGalleryButton.width - Theme.spacingS - pageInfo.width - Theme.spacingS
                            spacing: 2
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: wallpaperGalleryDir !== "" ? wallpaperGalleryDir.replace(/^file:\/\//, '').split('/').pop() : "No folder selected"
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                                elide: Text.ElideMiddle
                                width: parent.width
                            }

                            StyledText {
                                text: wallpaperGalleryModel.count > 0 ? `${wallpaperGalleryModel.count} wallpapers` : "No wallpapers found"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                visible: wallpaperGalleryDir !== ""
                            }
                        }

                        StyledText {
                            id: pageInfo
                            text: wallpaperGalleryModel.count > 0 ? `${galleryCurrentPage + 1} / ${galleryTotalPages}` : ""
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            anchors.verticalCenter: parent.verticalCenter
                            visible: wallpaperGalleryModel.count > 0
                        }
                    }

                    Item {
                        width: parent.width
                        height: parent.height - 32 - Theme.spacingS - 40 - Theme.spacingS

                        GridView {
                            id: wallpaperGalleryGrid
                            anchors.fill: parent
                            anchors.margins: 2
                            property real availableWidth: width - 4
                            property real availableHeight: height - 4
                            property int columns: 5
                            property int rows: 4
                            property real cellSpacing: 3
                            cellWidth: Math.floor((availableWidth - (cellSpacing * (columns - 1))) / columns) + cellSpacing
                            cellHeight: Math.floor((availableHeight - (cellSpacing * (rows - 1))) / rows) + cellSpacing
                            clip: true
                            interactive: false

                            property var galleryItems: []
                            
                            function updateModel() {
                                const startIndex = galleryCurrentPage * galleryItemsPerPage;
                                const endIndex = Math.min(startIndex + galleryItemsPerPage, wallpaperGalleryModel.count);
                                const items = [];
                                for (var i = startIndex; i < endIndex; i++) {
                                    const filePath = wallpaperGalleryModel.get(i, "filePath");
                                    if (filePath) {
                                        var cleanPath = filePath.toString().replace(/^file:\/\//, '');
                                        items.push(cleanPath);
                                    }
                                }
                                galleryItems = items;
                            }

                            Component.onCompleted: {
                                Qt.callLater(() => updateModel());
                            }
                            
                            Connections {
                                target: wallpaperTab
                                function onGalleryCurrentPageChanged() {
                                    wallpaperGalleryGrid.updateModel();
                                }
                                function onWallpaperGalleryDirChanged() {
                                    Qt.callLater(() => wallpaperGalleryGrid.updateModel());
                                }
                            }
                            
                            Connections {
                                target: wallpaperGalleryModel
                                function onCountChanged() {
                                    Qt.callLater(() => wallpaperGalleryGrid.updateModel());
                                }
                                function onStatusChanged() {
                                    if (wallpaperGalleryModel.status === FolderListModel.Ready) {
                                        Qt.callLater(() => wallpaperGalleryGrid.updateModel());
                                    }
                                }
                            }

                            model: galleryItems

                            delegate: Item {
                                width: wallpaperGalleryGrid.cellWidth - wallpaperGalleryGrid.cellSpacing
                                height: wallpaperGalleryGrid.cellHeight - wallpaperGalleryGrid.cellSpacing
                                x: (index % wallpaperGalleryGrid.columns) * wallpaperGalleryGrid.cellWidth
                                y: Math.floor(index / wallpaperGalleryGrid.columns) * wallpaperGalleryGrid.cellHeight

                                // Cache isSelected calculation to avoid recalculating on every frame
                                property string currentWallpaper: Qt.binding(function() {
                                    var wp = SessionData.perMonitorWallpaper ? 
                                        SessionData.getMonitorWallpaper(selectedMonitorName) : 
                                        SessionData.wallpaperPath
                                    // Return empty string if wallpaper is a color or special value
                                    if (!wp || wp === "" || wp.startsWith("#") || wp.startsWith("we:")) {
                                        return "";
                                    }
                                    return wp;
                                })
                                
                                property bool isSelected: Qt.binding(function() {
                                    var current = currentWallpaper;
                                    var model = modelData;
                                    // Simple direct comparison - only match if both exist and are equal
                                    if (!current || current === "" || !model || model === "") {
                                        return false;
                                    }
                                    return current === model;
                                })
                                property string fileName: {
                                    if (!modelData) return "";
                                    var parts = modelData.split('/');
                                    return parts.length > 0 ? parts[parts.length - 1] : "";
                                }

                                StyledRect {
                                    anchors.fill: parent
                                    radius: Theme.cornerRadius
                                    color: thumbnailMouseArea.containsMouse ?
                                        Theme.withAlpha(Theme.surfaceContainerHigh, Theme.popupTransparency) :
                                        Theme.withAlpha(Theme.surfaceContainerHighest, Theme.popupTransparency)
                                    clip: true
                                    border.color: thumbnailMouseArea.containsMouse ? Theme.outline : "transparent"
                                    border.width: thumbnailMouseArea.containsMouse ? 1 : 0

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Theme.shortDuration
                                            easing.type: Theme.standardEasing
                                        }
                                    }
                                    Behavior on border.color {
                                        ColorAnimation {
                                            duration: Theme.shortDuration
                                            easing.type: Theme.standardEasing
                                        }
                                    }

                                    CachingImage {
                                        id: thumbnailImage
                                        anchors.fill: parent
                                        imagePath: modelData || ""
                                        maxCacheSize: 512
                                        fillMode: Image.PreserveAspectCrop

                                        layer.enabled: true
                                        layer.effect: MultiEffect {
                                            maskEnabled: true
                                            maskThresholdMin: 0.5
                                            maskSpreadAtMin: 1.0
                                            maskSource: ShaderEffectSource {
                                                sourceItem: Rectangle {
                                                    width: thumbnailImage.width
                                                    height: thumbnailImage.height
                                                    radius: Theme.cornerRadius
                                                    color: "black"
                                                }
                                            }
                                        }
                                    }


                                    // Hover overlay with filename - subtle
                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: 24
                                        color: Qt.rgba(0, 0, 0, 0.5)
                                        radius: Theme.cornerRadius
                                        visible: thumbnailMouseArea.containsMouse && !isSelected
                                        opacity: thumbnailMouseArea.containsMouse ? 1 : 0

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: 80
                                                easing.type: Easing.OutQuad
                                            }
                                        }

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: parent.parent.parent.fileName
                                            font.pixelSize: Theme.fontSizeSmall - 2
                                            color: "white"
                                            width: parent.width - Theme.spacingXS * 2
                                            elide: Text.ElideMiddle
                                            horizontalAlignment: Text.AlignHCenter
                                            maximumLineCount: 1
                                        }
                                    }

                                    StateLayer {
                                        anchors.fill: parent
                                        cornerRadius: parent.radius
                                        stateColor: Theme.primary
                                    }

                                    MouseArea {
                                        id: thumbnailMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (modelData) {
                                                if (SessionData.perMonitorWallpaper) {
                                                    SessionData.setMonitorWallpaper(selectedMonitorName, modelData)
                                                } else {
                                                    SessionData.setWallpaper(modelData)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Empty states
                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.spacingM
                            visible: wallpaperGalleryModel.count === 0 && wallpaperGalleryDir !== ""

                            DarkIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                name: "image_not_supported"
                                size: 48
                                color: Theme.surfaceVariantText
                            }

                            StyledText {
                                text: "No wallpapers found"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            StyledText {
                                text: "This folder doesn't contain any image files.\nTry selecting a different folder."
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.spacingM
                            visible: wallpaperGalleryDir === ""

                            DarkIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                name: "folder_open"
                                size: 48
                                color: Theme.surfaceVariantText
                            }

                            StyledText {
                                text: "Select a wallpaper folder"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            StyledText {
                                text: "Click the folder icon above to browse\nand select a folder with wallpapers"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                            }
                        }
                    }

                    // Compact Pagination controls
                    Row {
                        width: parent.width
                        spacing: Theme.spacingXS
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: 32

                        DarkActionButton {
                            iconName: "skip_previous"
                            iconSize: Theme.iconSizeSmall - 2
                            buttonSize: 32
                            enabled: galleryCurrentPage > 0
                            opacity: enabled ? 1.0 : 0.3
                            onClicked: {
                                if (galleryCurrentPage > 0) {
                                    galleryCurrentPage--;
                                }
                            }
                        }

                        StyledRect {
                            width: 100
                            height: 32
                            radius: Theme.cornerRadius
                            color: Theme.withAlpha(Theme.surfaceContainerHigh, Theme.popupTransparency)
                            border.color: Theme.outline
                            border.width: 1

                            StyledText {
                                anchors.centerIn: parent
                                text: wallpaperGalleryModel.count > 0 ? `${galleryCurrentPage + 1} / ${galleryTotalPages}` : "0 / 0"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                            }
                        }

                        DarkActionButton {
                            iconName: "skip_next"
                            iconSize: Theme.iconSizeSmall - 2
                            buttonSize: 32
                            enabled: galleryCurrentPage < galleryTotalPages - 1
                            opacity: enabled ? 1.0 : 0.3
                            onClicked: {
                                if (galleryCurrentPage < galleryTotalPages - 1) {
                                    galleryCurrentPage++;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    FileBrowserModal {
        id: wallpaperBrowser

        browserTitle: "Select Wallpaper Directory"
        browserIcon: "folder_open"
        browserType: "wallpaper"
        fileExtensions: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp"]
        selectFolderMode: true
        onFileSelected: path => {
            if (SessionData.perMonitorWallpaper) {
                SessionData.setMonitorWallpaper(selectedMonitorName, path)
            } else {
                SessionData.setWallpaper(path)
            }
            close()
        }
        onFolderSelected: folderPath => {
            var cleanPath = folderPath.replace(/^file:\/\//, '');
            wallpaperGalleryDir = cleanPath;
            SessionData.wallpaperLastPath = cleanPath;
            SessionData.saveSettings();
            galleryCurrentPage = 0; // Reset to first page when folder changes
            close()
        }
        onDialogClosed: {
            if (parentModal) {
                parentModal.allowFocusOverride = false
                parentModal.shouldHaveFocus = Qt.binding(() => {
                    return parentModal.shouldBeVisible
                })
            }
        }
    }

    FolderListModel {
        id: wallpaperGalleryModel

        showDirsFirst: false
        showDotAndDotDot: false
        showHidden: false
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp"]
        showFiles: true
        showDirs: false
        sortField: FolderListModel.Name
        folder: wallpaperGalleryDir ? "file://" + wallpaperGalleryDir : ""
        
        onStatusChanged: {
            if (status === FolderListModel.Ready && count > 0) {
                // Ensure gallery is visible when images are loaded
                Qt.callLater(() => {
                    if (wallpaperGalleryGrid) {
                        wallpaperGalleryGrid.updateModel()
                    }
                })
            }
        }
    }

    // Reload wallpaper directory when SessionData changes
    Connections {
        target: SessionData
        function onWallpaperLastPathChanged() {
            if (SessionData.wallpaperLastPath && SessionData.wallpaperLastPath !== "" && wallpaperGalleryDir !== SessionData.wallpaperLastPath) {
                wallpaperGalleryDir = SessionData.wallpaperLastPath
            }
        }
    }

    DarkColorPicker {
        id: colorPicker

        pickerTitle: "Choose Wallpaper Color"
        onColorSelected: selectedColor => {
            if (SessionData.perMonitorWallpaper) {
                SessionData.setMonitorWallpaper(selectedMonitorName, selectedColor)
            } else {
                SessionData.setWallpaperColor(selectedColor)
            }
        }
    }
}

