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
    id: fontsTab

    property var parentModal: null
    property real fullWidth: {
        // Get the full width of the settings content area
        var parentItem = parent
        while (parentItem && parentItem.width === undefined) {
            parentItem = parentItem.parent
        }
        return parentItem ? parentItem.width : width
    }
    property var cachedFontFamilies: []
    property var cachedMonoFamilies: []
    property bool fontsEnumerated: false
    
    readonly property string fontWeightText: {
        switch (SettingsData.fontWeight) {
        case Font.Thin: return "Thin"
        case Font.ExtraLight: return "Extra Light"
        case Font.Light: return "Light"
        case Font.Normal: return "Regular"
        case Font.Medium: return "Medium"
        case Font.DemiBold: return "Demi Bold"
        case Font.Bold: return "Bold"
        case Font.ExtraBold: return "Extra Bold"
        case Font.Black: return "Black"
        default: return "Regular"
        }
    }

    function enumerateFonts() {
        var fonts = ["Default"]
        var availableFonts = Qt.fontFamilies()
        var rootFamilies = []
        var seenFamilies = new Set()
        for (var i = 0; i < availableFonts.length; i++) {
            var fontName = availableFonts[i]
            if (fontName.startsWith("."))
                continue

            if (fontName === SettingsData.defaultFontFamily)
                continue

            var rootName = fontName.replace(/ (Thin|Extra Light|Light|Regular|Medium|Semi Bold|Demi Bold|Bold|Extra Bold|Black|Heavy)$/i, "").replace(/ (Italic|Oblique|Condensed|Extended|Narrow|Wide)$/i,
                                                                                                                                                      "").replace(/ (UI|Display|Text|Mono|Sans|Serif)$/i, function (match, suffix) {
                                                                                                                                                          return match
                                                                                                                                                      }).trim()
            if (!seenFamilies.has(rootName) && rootName !== "") {
                seenFamilies.add(rootName)
                rootFamilies.push(rootName)
            }
        }
        cachedFontFamilies = fonts.concat(rootFamilies.sort())
        var monoFonts = ["Default"]
        var monoFamilies = []
        var seenMonoFamilies = new Set()
        for (var j = 0; j < availableFonts.length; j++) {
            var fontName2 = availableFonts[j]
            if (fontName2.startsWith("."))
                continue

            if (fontName2 === SettingsData.defaultMonoFontFamily)
                continue

            var lowerName = fontName2.toLowerCase()
            if (lowerName.includes("mono") || lowerName.includes("code") || lowerName.includes("console") || lowerName.includes("terminal") || lowerName.includes("courier") || lowerName.includes("dejavu sans mono") || lowerName.includes(
                        "jetbrains") || lowerName.includes("fira") || lowerName.includes("hack") || lowerName.includes("source code") || lowerName.includes("ubuntu mono") || lowerName.includes("cascadia")) {
                var rootName2 = fontName2.replace(/ (Thin|Extra Light|Light|Regular|Medium|Semi Bold|Demi Bold|Bold|Extra Bold|Black|Heavy)$/i, "").replace(/ (Italic|Oblique|Condensed|Extended|Narrow|Wide)$/i, "").trim()
                if (!seenMonoFamilies.has(rootName2) && rootName2 !== "") {
                    seenMonoFamilies.add(rootName2)
                    monoFamilies.push(rootName2)
                }
            }
        }
        cachedMonoFamilies = monoFonts.concat(monoFamilies.sort())
    }

    Component.onCompleted: {
        if (!fontsEnumerated) {
            enumerateFonts()
            fontsEnumerated = true
        }
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
                height: fontSection.implicitHeight + Theme.spacingL * 2
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: fontSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "font_download"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Font Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DarkDropdown {
                        width: parent.width
                        text: "Font Family"
                        description: "Select system font family"
                        currentValue: {
                            if (SettingsData.fontFamily === SettingsData.defaultFontFamily)
                                return "Default"
                            else
                                return SettingsData.fontFamily || "Default"
                        }
                        enableFuzzySearch: true
                        popupWidthOffset: 100
                        maxPopupHeight: 400
                        options: cachedFontFamilies
                        onValueChanged: value => {
                                            if (value.startsWith("Default"))
                                            SettingsData.setFontFamily(SettingsData.defaultFontFamily)
                                            else
                                            SettingsData.setFontFamily(value)
                                        }
                    }

                    DarkDropdown {
                        width: parent.width
                        text: "Font Weight"
                        description: "Select font weight"
                        currentValue: {
                            switch (SettingsData.fontWeight) {
                            case Font.Thin:
                                return "Thin"
                            case Font.ExtraLight:
                                return "Extra Light"
                            case Font.Light:
                                return "Light"
                            case Font.Normal:
                                return "Regular"
                            case Font.Medium:
                                return "Medium"
                            case Font.DemiBold:
                                return "Demi Bold"
                            case Font.Bold:
                                return "Bold"
                            case Font.ExtraBold:
                                return "Extra Bold"
                            case Font.Black:
                                return "Black"
                            default:
                                return "Regular"
                            }
                        }
                        options: ["Thin", "Extra Light", "Light", "Regular", "Medium", "Demi Bold", "Bold", "Extra Bold", "Black"]
                        onValueChanged: value => {
                                            var weight
                                            switch (value) {
                                                case "Thin":
                                                weight = Font.Thin
                                                break
                                                case "Extra Light":
                                                weight = Font.ExtraLight
                                                break
                                                case "Light":
                                                weight = Font.Light
                                                break
                                                case "Regular":
                                                weight = Font.Normal
                                                break
                                                case "Medium":
                                                weight = Font.Medium
                                                break
                                                case "Demi Bold":
                                                weight = Font.DemiBold
                                                break
                                                case "Bold":
                                                weight = Font.Bold
                                                break
                                                case "Extra Bold":
                                                weight = Font.ExtraBold
                                                break
                                                case "Black":
                                                weight = Font.Black
                                                break
                                                default:
                                                weight = Font.Normal
                                                break
                                            }
                                            SettingsData.setFontWeight(weight)
                                        }
                    }

                    DarkDropdown {
                        width: parent.width
                        text: "Monospace Font"
                        description: "Select monospace font for process list and technical displays"
                        currentValue: {
                            if (SettingsData.monoFontFamily === SettingsData.defaultMonoFontFamily)
                                return "Default"

                            return SettingsData.monoFontFamily || "Default"
                        }
                        enableFuzzySearch: true
                        popupWidthOffset: 100
                        maxPopupHeight: 400
                        options: cachedMonoFamilies
                        onValueChanged: value => {
                                            if (value === "Default")
                                            SettingsData.setMonoFontFamily(SettingsData.defaultMonoFontFamily)
                                            else
                                            SettingsData.setMonoFontFamily(value)
                                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 60
                        radius: Theme.cornerRadius
                        color: "transparent"

                        Column {
                            anchors.left: parent.left
                            anchors.right: fontScaleControls.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: Theme.spacingM
                            anchors.rightMargin: Theme.spacingM
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Font Scale"
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Scale all font sizes"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: parent.width
                            }
                        }

                        Row {
                            id: fontScaleControls

                            width: 180
                            height: 36
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingS

                            DarkActionButton {
                                buttonSize: 32
                                iconName: "remove"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.fontScale > 1.0
                                backgroundColor: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.5)
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newScale = Math.max(1.0, SettingsData.fontScale - 0.05)
                                    SettingsData.setFontScale(newScale)
                                }
                            }

                            StyledRect {
                                width: 60
                                height: 32
                                radius: Theme.cornerRadius
                                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                border.width: 1

                                StyledText {
                                    anchors.centerIn: parent
                                    text: (SettingsData.fontScale * 100).toFixed(0) + "%"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }
                            }

                            DarkActionButton {
                                buttonSize: 32
                                iconName: "add"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.fontScale < 2.0
                                backgroundColor: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.5)
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newScale = Math.min(2.0, SettingsData.fontScale + 0.05)
                                    SettingsData.setFontScale(newScale)
                                }
                            }
                        }
                    }
                }
            }

            // Font Preview Section
            StyledRect {
                width: Math.min(parent.width * 1.2, parent.parent ? parent.parent.width - 48 : parent.width * 1.2)
                height: previewSection.implicitHeight + Theme.spacingL * 2
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: previewSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "preview"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Font Preview"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM

                        Column {
                            spacing: Theme.spacingXS
                            Layout.alignment: Qt.AlignVCenter

                            StyledText {
                                text: "Preview"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }

                            Rectangle {
                                id: previewBox
                                width: 295
                                height: 295
                                radius: Theme.cornerRadius
                                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.8)
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
                                border.width: 2

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingL
                                    spacing: Theme.spacingS

                                    StyledText {
                                        text: "The quick brown fox"
                                        font.pixelSize: (Theme.fontSizeLarge * SettingsData.fontScale)
                                        font.family: SettingsData.fontFamily
                                        font.weight: SettingsData.fontWeight
                                        font.letterSpacing: SettingsData.fontLetterSpacing
                                            font.wordSpacing: SettingsData.fontWordSpacing
                                            font.capitalization: SettingsData.fontCapitalization
                                            font.italic: SettingsData.fontItalic
                                        font.underline: SettingsData.fontUnderline
                                        font.strikeout: SettingsData.fontStrikeout
                                        font.hintingPreference: SettingsData.fontHintingPreference
                                        renderType: SettingsData.fontRenderType
                                        antialiasing: SettingsData.fontAntialiasing
                                        lineHeight: SettingsData.fontLineHeight
                                        color: Theme.surfaceText
                                        width: parent.width
                                    }

                                    StyledText {
                                        text: "jumps over the lazy dog"
                                        font.pixelSize: (Theme.fontSizeMedium * SettingsData.fontScale)
                                        font.family: SettingsData.fontFamily
                                        font.weight: SettingsData.fontWeight
                                        font.letterSpacing: SettingsData.fontLetterSpacing
                                            font.wordSpacing: SettingsData.fontWordSpacing
                                            font.capitalization: SettingsData.fontCapitalization
                                            font.italic: SettingsData.fontItalic
                                        font.underline: SettingsData.fontUnderline
                                        font.strikeout: SettingsData.fontStrikeout
                                        font.hintingPreference: SettingsData.fontHintingPreference
                                        renderType: SettingsData.fontRenderType
                                        antialiasing: SettingsData.fontAntialiasing
                                        lineHeight: SettingsData.fontLineHeight
                                        color: Theme.surfaceText
                                        width: parent.width
                                    }

                                    Item {
                                        width: parent.width
                                        height: Theme.spacingXS
                                    }

                                    StyledText {
                                        text: "ABCDEFGHIJKLM"
                                        font.pixelSize: (Theme.fontSizeLarge * SettingsData.fontScale)
                                        font.family: SettingsData.fontFamily
                                        font.weight: SettingsData.fontWeight
                                        font.letterSpacing: SettingsData.fontLetterSpacing
                                            font.wordSpacing: SettingsData.fontWordSpacing
                                            font.capitalization: SettingsData.fontCapitalization
                                            font.italic: SettingsData.fontItalic
                                        font.underline: SettingsData.fontUnderline
                                        font.strikeout: SettingsData.fontStrikeout
                                        font.hintingPreference: SettingsData.fontHintingPreference
                                        renderType: SettingsData.fontRenderType
                                        antialiasing: SettingsData.fontAntialiasing
                                        lineHeight: SettingsData.fontLineHeight
                                        color: Theme.surfaceText
                                        width: parent.width
                                    }

                                    StyledText {
                                        text: "NOPQRSTUVWXYZ"
                                        font.pixelSize: (Theme.fontSizeLarge * SettingsData.fontScale)
                                        font.family: SettingsData.fontFamily
                                        font.weight: SettingsData.fontWeight
                                        font.letterSpacing: SettingsData.fontLetterSpacing
                                            font.wordSpacing: SettingsData.fontWordSpacing
                                            font.capitalization: SettingsData.fontCapitalization
                                            font.italic: SettingsData.fontItalic
                                        font.underline: SettingsData.fontUnderline
                                        font.strikeout: SettingsData.fontStrikeout
                                        font.hintingPreference: SettingsData.fontHintingPreference
                                        renderType: SettingsData.fontRenderType
                                        antialiasing: SettingsData.fontAntialiasing
                                        lineHeight: SettingsData.fontLineHeight
                                        color: Theme.surfaceText
                                        width: parent.width
                                    }

                                    Item {
                                        width: parent.width
                                        height: Theme.spacingXS
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: Theme.spacingM

                                        StyledText {
                                            text: "0123456789"
                                            font.pixelSize: (Theme.fontSizeMedium * SettingsData.fontScale)
                                            font.family: SettingsData.fontFamily
                                            font.weight: SettingsData.fontWeight
                                            font.letterSpacing: SettingsData.fontLetterSpacing
                                            font.wordSpacing: SettingsData.fontWordSpacing
                                            font.capitalization: SettingsData.fontCapitalization
                                            font.italic: SettingsData.fontItalic
                                            font.underline: SettingsData.fontUnderline
                                            font.strikeout: SettingsData.fontStrikeout
                                            font.hintingPreference: SettingsData.fontHintingPreference
                                            renderType: SettingsData.fontRenderType
                                            antialiasing: SettingsData.fontAntialiasing
                                            lineHeight: SettingsData.fontLineHeight
                                            color: Theme.surfaceText
                                        }

                                        StyledText {
                                            text: "!@#$%^&*()"
                                            font.pixelSize: (Theme.fontSizeMedium * SettingsData.fontScale)
                                            font.family: SettingsData.fontFamily
                                            font.weight: SettingsData.fontWeight
                                            font.letterSpacing: SettingsData.fontLetterSpacing
                                            font.wordSpacing: SettingsData.fontWordSpacing
                                            font.capitalization: SettingsData.fontCapitalization
                                            font.italic: SettingsData.fontItalic
                                            font.underline: SettingsData.fontUnderline
                                            font.strikeout: SettingsData.fontStrikeout
                                            font.hintingPreference: SettingsData.fontHintingPreference
                                            renderType: SettingsData.fontRenderType
                                            antialiasing: SettingsData.fontAntialiasing
                                            lineHeight: SettingsData.fontLineHeight
                                            color: Theme.surfaceText
                                        }
                                    }

                                    Item {
                                        Layout.fillHeight: true
                                    }

                                    StyledText {
                                        text: "Aa Bb Cc Dd Ee"
                                        font.pixelSize: (Theme.fontSizeSmall * SettingsData.fontScale)
                                        font.family: SettingsData.fontFamily
                                        font.weight: SettingsData.fontWeight
                                        font.letterSpacing: SettingsData.fontLetterSpacing
                                            font.wordSpacing: SettingsData.fontWordSpacing
                                            font.capitalization: SettingsData.fontCapitalization
                                            font.italic: SettingsData.fontItalic
                                        font.underline: SettingsData.fontUnderline
                                        font.strikeout: SettingsData.fontStrikeout
                                        font.hintingPreference: SettingsData.fontHintingPreference
                                        renderType: SettingsData.fontRenderType
                                        antialiasing: SettingsData.fontAntialiasing
                                        lineHeight: SettingsData.fontLineHeight
                                        color: Theme.surfaceVariantText
                                        width: parent.width
                                    }
                                }
                            }
                        }

                        Column {
                            spacing: Theme.spacingS
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            StyledText {
                                text: "Sample Text"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "This preview shows how your selected font settings will appear throughout the interface. Adjust the font family, weight, scale, letter spacing, hinting, and render type to see real-time changes."
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                                lineHeight: 1.4
                            }

                            Item {
                                width: parent.width
                                height: Theme.spacingM
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingXS

                                StyledText {
                                    text: "Current Settings:"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }

                                StyledText {
                                    text: "• Family: " + (SettingsData.fontFamily || "Default")
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: parent.width
                                }

                                StyledText {
                                    text: "• Weight: " + fontsTab.fontWeightText
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: parent.width
                                }

                                StyledText {
                                    text: "• Scale: " + (SettingsData.fontScale * 100).toFixed(0) + "%"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: parent.width
                                }

                                StyledText {
                                    text: "• Letter Spacing: " + SettingsData.fontLetterSpacing.toFixed(1) + "px"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: parent.width
                                }
                            }
                        }
                    }
                }
            }

            // Notepad Font Settings Section
            StyledRect {
                width: Math.min(parent.width * 1.2, parent.parent ? parent.parent.width - 48 : parent.width * 1.2)
                height: notepadSection.implicitHeight + Theme.spacingL * 2
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: notepadSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "description"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Notepad Font Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Use Monospace Font"
                        description: "Use monospace font in notepad"
                        checked: SettingsData.notepadUseMonospace
                        onToggled: SettingsData.notepadUseMonospace = checked
                    }

                    DarkDropdown {
                        width: parent.width
                        text: "Notepad Font Family"
                        description: "Select font for notepad (empty = use system font)"
                        currentValue: SettingsData.notepadFontFamily || "System Default"
                        enableFuzzySearch: true
                        popupWidthOffset: 100
                        maxPopupHeight: 400
                        options: ["System Default"].concat(cachedFontFamilies.slice(1))
                        onValueChanged: value => {
                                            SettingsData.notepadFontFamily = (value === "System Default") ? "" : value
                                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Font Size"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: SettingsData.notepadFontSize
                            minimum: 8
                            maximum: 32
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.notepadFontSize = newValue
                                                  }
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Show Line Numbers"
                        description: "Display line numbers in notepad"
                        checked: SettingsData.notepadShowLineNumbers
                        onToggled: SettingsData.notepadShowLineNumbers = checked
                    }
                }
            }

            // Font Rendering Options Section
            StyledRect {
                width: Math.min(parent.width * 1.2, parent.parent ? parent.parent.width - 48 : parent.width * 1.2)
                height: renderingSection.implicitHeight + Theme.spacingL * 2
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: renderingSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "tune"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Font Rendering"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Font Antialiasing"
                        description: "Enable smooth font rendering"
                        checked: SettingsData.fontAntialiasing
                        onToggled: SettingsData.fontAntialiasing = checked
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Letter Spacing"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: Math.round(SettingsData.fontLetterSpacing * 10)
                            minimum: -20
                            maximum: 100
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.fontLetterSpacing = newValue / 10.0
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Word Spacing"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: Math.round(SettingsData.fontWordSpacing * 2)
                            minimum: 0
                            maximum: 200
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.fontWordSpacing = newValue / 2.0
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Line Height"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: Math.round(SettingsData.fontLineHeight * 100)
                            minimum: 80
                            maximum: 250
                            unit: "%"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.fontLineHeight = newValue / 100.0
                                                  }
                        }
                    }

                    DarkDropdown {
                        width: parent.width
                        text: "Text Capitalization"
                        description: "Transform text capitalization"
                        currentValue: {
                            switch (SettingsData.fontCapitalization) {
                            case Font.MixedCase:
                                return "Mixed Case"
                            case Font.AllUppercase:
                                return "All Uppercase"
                            case Font.AllLowercase:
                                return "All Lowercase"
                            case Font.SmallCaps:
                                return "Small Caps"
                            case Font.Capitalize:
                                return "Capitalize"
                            default:
                                return "Mixed Case"
                            }
                        }
                        options: ["Mixed Case", "All Uppercase", "All Lowercase", "Small Caps", "Capitalize"]
                        onValueChanged: value => {
                                            var cap
                                            switch (value) {
                                            case "All Uppercase":
                                                cap = Font.AllUppercase
                                                break
                                            case "All Lowercase":
                                                cap = Font.AllLowercase
                                                break
                                            case "Small Caps":
                                                cap = Font.SmallCaps
                                                break
                                            case "Capitalize":
                                                cap = Font.Capitalize
                                                break
                                            default:
                                                cap = Font.MixedCase
                                                break
                                            }
                                            SettingsData.fontCapitalization = cap
                                        }
                    }

                    DarkDropdown {
                        width: parent.width
                        text: "Font Stretch"
                        description: "Condensed or expanded font width (limited QML support)"
                        currentValue: {
                            switch (SettingsData.fontStretch) {
                            case Font.UltraCondensed:
                                return "Ultra Condensed"
                            case Font.ExtraCondensed:
                                return "Extra Condensed"
                            case Font.Condensed:
                                return "Condensed"
                            case Font.SemiCondensed:
                                return "Semi Condensed"
                            case Font.NormalStretch:
                                return "Normal"
                            case Font.SemiExpanded:
                                return "Semi Expanded"
                            case Font.Expanded:
                                return "Expanded"
                            case Font.ExtraExpanded:
                                return "Extra Expanded"
                            case Font.UltraExpanded:
                                return "Ultra Expanded"
                            default:
                                return "Normal"
                            }
                        }
                        options: ["Ultra Condensed", "Extra Condensed", "Condensed", "Semi Condensed", 
                                  "Normal", "Semi Expanded", "Expanded", "Extra Expanded", "Ultra Expanded"]
                        onValueChanged: value => {
                                            var stretch
                                            switch (value) {
                                            case "Ultra Condensed":
                                                stretch = Font.UltraCondensed
                                                break
                                            case "Extra Condensed":
                                                stretch = Font.ExtraCondensed
                                                break
                                            case "Condensed":
                                                stretch = Font.Condensed
                                                break
                                            case "Semi Condensed":
                                                stretch = Font.SemiCondensed
                                                break
                                            case "Semi Expanded":
                                                stretch = Font.SemiExpanded
                                                break
                                            case "Expanded":
                                                stretch = Font.Expanded
                                                break
                                            case "Extra Expanded":
                                                stretch = Font.ExtraExpanded
                                                break
                                            case "Ultra Expanded":
                                                stretch = Font.UltraExpanded
                                                break
                                            default:
                                                stretch = Font.NormalStretch
                                                break
                                            }
                                            SettingsData.fontStretch = stretch
                                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Italic Style"
                        description: "Apply italic style to text"
                        checked: SettingsData.fontItalic
                        onToggled: SettingsData.fontItalic = checked
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Underline"
                        description: "Add underline to text"
                        checked: SettingsData.fontUnderline
                        onToggled: SettingsData.fontUnderline = checked
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Strikeout"
                        description: "Add strikeout line to text"
                        checked: SettingsData.fontStrikeout
                        onToggled: SettingsData.fontStrikeout = checked
                    }

                    DarkDropdown {
                        width: parent.width
                        text: "Font Hinting"
                        description: "Control font rendering clarity"
                        currentValue: {
                            switch (SettingsData.fontHintingPreference) {
                            case Font.PreferDefaultHinting:
                                return "Default"
                            case Font.PreferNoHinting:
                                return "None"
                            case Font.PreferVerticalHinting:
                                return "Vertical Only"
                            case Font.PreferFullHinting:
                                return "Full"
                            default:
                                return "Default"
                            }
                        }
                        options: ["Default", "None", "Vertical Only", "Full"]
                        onValueChanged: value => {
                                            var hint
                                            switch (value) {
                                            case "None":
                                                hint = Font.PreferNoHinting
                                                break
                                            case "Vertical Only":
                                                hint = Font.PreferVerticalHinting
                                                break
                                            case "Full":
                                                hint = Font.PreferFullHinting
                                                break
                                            default:
                                                hint = Font.PreferDefaultHinting
                                                break
                                            }
                                            SettingsData.fontHintingPreference = hint
                                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Render Type"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        StyledText {
                            text: "Font rendering engine"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        DarkButtonGroup {
                            width: parent.width
                            model: ["Qt Rendering", "Native Rendering", "Curve Rendering"]
                            currentIndex: {
                                switch (SettingsData.fontRenderType) {
                                case Text.QtRendering:
                                    return 0
                                case Text.NativeRendering:
                                    return 1
                                case Text.CurveRendering:
                                    return 2
                                default:
                                    return 0
                                }
                            }
                            selectionMode: "single"
                            buttonHeight: 40
                            minButtonWidth: 100
                            buttonPadding: Theme.spacingM
                            textSize: Theme.fontSizeSmall
                            spacing: Theme.spacingS
                            onSelectionChanged: (index, selected) => {
                                                  if (selected) {
                                                      var render
                                                      switch (index) {
                                                      case 0:
                                                          render = Text.QtRendering
                                                          break
                                                      case 1:
                                                          render = Text.NativeRendering
                                                          break
                                                      case 2:
                                                          render = Text.CurveRendering
                                                          break
                                                      default:
                                                          render = Text.QtRendering
                                                          break
                                                      }
                                                      SettingsData.fontRenderType = render
                                                  }
                                              }
                        }
                    }
                }
            }
        }
    }
}
