import QtQuick
import qs.Common
import qs.Services

Text {
    property bool isMonospace: false

    readonly property string resolvedFontFamily: {
        const requestedFont = isMonospace ? SettingsData.monoFontFamily : SettingsData.fontFamily
        const defaultFont = isMonospace ? SettingsData.defaultMonoFontFamily : SettingsData.defaultFontFamily

        if (requestedFont === defaultFont) {
            const availableFonts = Qt.fontFamilies()
            if (!availableFonts.includes(requestedFont)) {
                return isMonospace ? "Monospace" : "DejaVu Sans"
            }
        }
        return requestedFont
    }

    readonly property var standardAnimation: {
        "duration": Appearance.anim.durations.normal,
        "easing.type": Easing.BezierSpline,
        "easing.bezierCurve": Appearance.anim.curves.standard
    }

    color: Theme.surfaceText
    font.pixelSize: Appearance.fontSize.normal
    font.family: resolvedFontFamily
    font.weight: SettingsData.fontWeight
    font.letterSpacing: SettingsData.fontLetterSpacing
    font.wordSpacing: SettingsData.fontWordSpacing
    font.capitalization: SettingsData.fontCapitalization
    // Note: font.stretch is not available in QML Text, kept in SettingsData for future use
    font.italic: SettingsData.fontItalic
    font.underline: SettingsData.fontUnderline
    font.strikeout: SettingsData.fontStrikeout
    font.hintingPreference: SettingsData.fontHintingPreference
    lineHeight: SettingsData.fontLineHeight
    wrapMode: Text.WordWrap
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
    renderType: SettingsData.fontRenderType
    antialiasing: SettingsData.fontAntialiasing

    Behavior on color {
        ColorAnimation {
            duration: standardAnimation.duration
            easing.type: standardAnimation["easing.type"]
            easing.bezierCurve: standardAnimation["easing.bezierCurve"]
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: standardAnimation.duration
            easing.type: standardAnimation["easing.type"]
            easing.bezierCurve: standardAnimation["easing.bezierCurve"]
        }
    }
}
