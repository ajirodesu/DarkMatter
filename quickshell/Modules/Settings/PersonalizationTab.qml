import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs.Common
import qs.Modals
import qs.Modals.FileBrowser
import qs.Services
import qs.Widgets

Item {
    id: personalizationTab

    property var parentModal: null
    property string selectedMonitorName: {
        var screens = Quickshell.screens
        return screens.length > 0 ? screens[0].name : ""
    }

    Component.onCompleted: {
        WallpaperCyclingService.cyclingActive
    }

    DarkFlickable {
        id: flickable
        anchors.fill: parent
        anchors.topMargin: 0
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingL
            topPadding: Theme.spacingL
            bottomPadding: Theme.spacingL

            StyledRect {
                width: Math.min(parent.width * 1.2, parent.parent ? parent.parent.width - 48 : parent.width * 1.2)
                height: dynamicThemeSection.implicitHeight + Theme.spacingL * 2
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: dynamicThemeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "palette"
                            size: Theme.iconSize
                            color: Theme.primary
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Column {
                            spacing: Theme.spacingXS
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            StyledText {
                                text: "Dynamic Theming"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Automatically extract colors from wallpaper"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DarkToggle {
                            id: toggle
                            checked: Theme.wallpaperPath !== "" && Theme.currentTheme === Theme.dynamic
                            enabled: ToastService.wallpaperErrorStatus !== "matugen_missing" && Theme.wallpaperPath !== ""
                            onToggled: toggled => {
                                           if (toggled)
                                           Theme.switchTheme(Theme.dynamic)
                                           else
                                           Theme.switchTheme("blue")
                                       }
                        }
                    }

                    StyledText {
                        text: "matugen not detected - dynamic theming unavailable"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.error
                        visible: ToastService.wallpaperErrorStatus === "matugen_missing"
                        width: parent.width
                        leftPadding: Theme.iconSize + Theme.spacingM
                    }

                }
            }


            StyledRect {
                width: Math.min(parent.width * 1.2, parent.parent ? parent.parent.width - 48 : parent.width * 1.2)
                height: displaySection.implicitHeight + Theme.spacingL * 2
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: displaySection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "monitor"
                            size: Theme.iconSize
                            color: Theme.primary
                            Layout.alignment: Qt.AlignVCenter
                        }

                        StyledText {
                            text: "Display Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Light Mode"
                        description: "Use light theme instead of dark theme"
                        checked: SessionData.isLightMode
                        onToggled: checked => {
                                       Theme.setLightMode(checked)
                                   }
                    }


                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    DarkToggle {
                        id: nightModeToggle

                        width: parent.width
                        text: "Night Mode"
                        description: "Apply warm color temperature to reduce eye strain. Use automation settings below to control when it activates."
                        checked: DisplayService.nightModeEnabled
                        onToggled: checked => {
                                       DisplayService.toggleNightMode()
                                   }

                        Connections {
                            function onNightModeEnabledChanged() {
                                nightModeToggle.checked = DisplayService.nightModeEnabled
                            }

                            target: DisplayService
                        }
                    }

                    DarkDropdown {
                        width: parent.width
                        text: "Temperature"
                        description: "Color temperature for night mode"
                        currentValue: SessionData.nightModeTemperature + "K"
                        options: {
                            var temps = []
                            for (var i = 2500; i <= 6000; i += 500) {
                                temps.push(i + "K")
                            }
                            return temps
                        }
                        onValueChanged: value => {
                                            var temp = parseInt(value.replace("K", ""))
                                            SessionData.setNightModeTemperature(temp)
                                        }
                    }

                    DarkToggle {
                        id: automaticToggle
                        width: parent.width
                        text: "Automatic Control"
                        description: "Only adjust gamma based on time or location rules."
                        checked: SessionData.nightModeAutoEnabled
                        onToggled: checked => {
                                       if (checked && !DisplayService.nightModeEnabled) {
                                           DisplayService.toggleNightMode()
                                       } else if (!checked && DisplayService.nightModeEnabled) {
                                           DisplayService.toggleNightMode()
                                       }
                                       SessionData.setNightModeAutoEnabled(checked)
                                   }

                        Connections {
                            target: SessionData
                            function onNightModeAutoEnabledChanged() {
                                automaticToggle.checked = SessionData.nightModeAutoEnabled
                            }
                        }
                    }

                    Column {
                        id: automaticSettings
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: SessionData.nightModeAutoEnabled
                        leftPadding: Theme.spacingM

                        Connections {
                            target: SessionData
                            function onNightModeAutoEnabledChanged() {
                                automaticSettings.visible = SessionData.nightModeAutoEnabled
                            }
                        }

                        Item {
                            width: 200
                            height: 45 + Theme.spacingM

                            DarkTabBar {
                                id: modeTabBarNight
                                width: 200
                                height: 45
                                model: [{
                                        "text": "Time",
                                        "icon": "access_time"
                                    }, {
                                        "text": "Location",
                                        "icon": "place"
                                    }]

                                Component.onCompleted: {
                                    currentIndex = SessionData.nightModeAutoMode === "location" ? 1 : 0
                                    Qt.callLater(updateIndicator)
                                }

                                onTabClicked: index => {
                                                  DisplayService.setNightModeAutomationMode(index === 1 ? "location" : "time")
                                                  currentIndex = index
                                              }

                                Connections {
                                    target: SessionData
                                    function onNightModeAutoModeChanged() {
                                        modeTabBarNight.currentIndex = SessionData.nightModeAutoMode === "location" ? 1 : 0
                                        Qt.callLater(modeTabBarNight.updateIndicator)
                                    }
                                }
                            }
                        }

                        Column {
                            property bool isTimeMode: SessionData.nightModeAutoMode === "time"
                            visible: isTimeMode
                            spacing: Theme.spacingM


                            Row {
                                spacing: Theme.spacingM
                                height: 20
                                leftPadding: 45

                                StyledText {
                                    text: "Hour"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: 50
                                    horizontalAlignment: Text.AlignHCenter
                                    anchors.bottom: parent.bottom
                                }

                                StyledText {
                                    text: "Minute"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: 50
                                    horizontalAlignment: Text.AlignHCenter
                                    anchors.bottom: parent.bottom
                                }
                            }


                            Row {
                                spacing: Theme.spacingM
                                height: 32

                                StyledText {
                                    id: startLabel
                                    text: "Start"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceText
                                    width: 50
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                DarkDropdown {
                                    width: 60
                                    height: 32
                                    text: ""
                                    currentValue: SessionData.nightModeStartHour.toString()
                                    options: {
                                        var hours = []
                                        for (var i = 0; i < 24; i++) {
                                            hours.push(i.toString())
                                        }
                                        return hours
                                    }
                                    onValueChanged: value => {
                                                        SessionData.setNightModeStartHour(parseInt(value))
                                                    }
                                }

                                DarkDropdown {
                                    width: 60
                                    height: 32
                                    text: ""
                                    currentValue: SessionData.nightModeStartMinute.toString().padStart(2, '0')
                                    options: {
                                        var minutes = []
                                        for (var i = 0; i < 60; i += 5) {
                                            minutes.push(i.toString().padStart(2, '0'))
                                        }
                                        return minutes
                                    }
                                    onValueChanged: value => {
                                                        SessionData.setNightModeStartMinute(parseInt(value))
                                                    }
                                }
                            }


                            Row {
                                spacing: Theme.spacingM
                                height: 32

                                StyledText {
                                    text: "End"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceText
                                    width: startLabel.width
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                DarkDropdown {
                                    width: 60
                                    height: 32
                                    text: ""
                                    currentValue: SessionData.nightModeEndHour.toString()
                                    options: {
                                        var hours = []
                                        for (var i = 0; i < 24; i++) {
                                            hours.push(i.toString())
                                        }
                                        return hours
                                    }
                                    onValueChanged: value => {
                                                        SessionData.setNightModeEndHour(parseInt(value))
                                                    }
                                }

                                DarkDropdown {
                                    width: 60
                                    height: 32
                                    text: ""
                                    currentValue: SessionData.nightModeEndMinute.toString().padStart(2, '0')
                                    options: {
                                        var minutes = []
                                        for (var i = 0; i < 60; i += 5) {
                                            minutes.push(i.toString().padStart(2, '0'))
                                        }
                                        return minutes
                                    }
                                    onValueChanged: value => {
                                                        SessionData.setNightModeEndMinute(parseInt(value))
                                                    }
                                }
                            }
                        }

                        Column {
                            property bool isLocationMode: SessionData.nightModeAutoMode === "location"
                            visible: isLocationMode
                            spacing: Theme.spacingM
                            width: parent.width

                            DarkToggle {
                                width: parent.width
                                text: "Auto-location"
                                description: DisplayService.geoclueAvailable ? "Use automatic location detection (geoclue2)" : "Geoclue service not running - cannot auto-detect location"
                                checked: SessionData.nightModeLocationProvider === "geoclue2"
                                enabled: DisplayService.geoclueAvailable
                                onToggled: checked => {
                                               if (checked && DisplayService.geoclueAvailable) {
                                                   SessionData.setNightModeLocationProvider("geoclue2")
                                                   SessionData.setLatitude(0.0)
                                                   SessionData.setLongitude(0.0)
                                               } else {
                                                   SessionData.setNightModeLocationProvider("")
                                               }
                                           }
                            }

                            StyledText {
                                text: "Manual Coordinates"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                visible: SessionData.nightModeLocationProvider !== "geoclue2"
                            }

                            Row {
                                spacing: Theme.spacingM
                                visible: SessionData.nightModeLocationProvider !== "geoclue2"

                                Column {
                                    spacing: Theme.spacingXS

                                    StyledText {
                                        text: "Latitude"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    DarkTextField {
                                        width: 120
                                        height: 40
                                        text: SessionData.latitude.toString()
                                        placeholderText: "0.0"
                                        onTextChanged: {
                                            const lat = parseFloat(text) || 0.0
                                            if (lat >= -90 && lat <= 90) {
                                                SessionData.setLatitude(lat)
                                            }
                                        }
                                    }
                                }

                                Column {
                                    spacing: Theme.spacingXS

                                    StyledText {
                                        text: "Longitude"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    DarkTextField {
                                        width: 120
                                        height: 40
                                        text: SessionData.longitude.toString()
                                        placeholderText: "0.0"
                                        onTextChanged: {
                                            const lon = parseFloat(text) || 0.0
                                            if (lon >= -180 && lon <= 180) {
                                                SessionData.setLongitude(lon)
                                            }
                                        }
                                    }
                                }
                            }

                            StyledText {
                                text: "Uses sunrise/sunset times to automatically adjust night mode based on your location."
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: parent.width
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }


            StyledRect {
                width: Math.min(parent.width * 1.2, parent.parent ? parent.parent.width - 48 : parent.width * 1.2)
                height: lockScreenSection.implicitHeight + Theme.spacingL * 2
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: lockScreenSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "lock"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Lock Screen"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Show Power Actions"
                        description: "Show power, restart, and logout buttons on the lock screen"
                        checked: SettingsData.lockScreenShowPowerActions
                        onToggled: checked => {
                                       SettingsData.setLockScreenShowPowerActions(checked)
                                   }
                    }
                }
            }

            StyledRect {
                width: Math.min(parent.width * 1.2, parent.parent ? parent.parent.width - 48 : parent.width * 1.2)
                height: deviceModeSection.implicitHeight + Theme.spacingL * 2
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: deviceModeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: SettingsData.handheldMode ? "smartphone" : "computer"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Device Mode"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: SettingsData.handheldMode ? "Handheld Mode" : "Desktop Mode"
                        description: SettingsData.handheldMode ?
                            "Optimized for handheld/tablet use with smaller widgets and compact layout" :
                            "Standard desktop mode with full widget support"
                        checked: SettingsData.handheldMode
                        onToggled: checked => {
                                       SettingsData.handheldMode = checked
                                   }
                    }

                    StyledText {
                        text: SettingsData.handheldMode ?
                            "Handheld mode hides desktop widgets, reduces dock size, and optimizes the interface for touch interaction." :
                            "Desktop mode shows all widgets, uses full dock size, and provides complete desktop functionality."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

}
