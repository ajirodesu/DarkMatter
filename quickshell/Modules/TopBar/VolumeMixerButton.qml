import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Pipewire
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    readonly property int textWidth: 0
    readonly property int currentContentWidth: {
        return volumeRow.implicitWidth + horizontalPadding * 2;
    }
    property string section: "center"
    property var popupTarget: null
    property var parentScreen: null
    property real barHeight: 48
    property real widgetHeight: 30
    readonly property bool isBarVertical: SettingsData.topBarPosition === "left" || SettingsData.topBarPosition === "right"
    readonly property real horizontalPadding: SettingsData.topBarNoBackground ? 0 : Math.max(Theme.spacingXS, Theme.spacingS * (widgetHeight / 30))

    signal clicked()

    width: isBarVertical ? widgetHeight : currentContentWidth
    height: isBarVertical ? currentContentWidth : widgetHeight
    radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.topBarNoBackground) {
            return "transparent";
        }

        const baseColor = volumeArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }

    MouseArea {
        id: volumeArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: {
            if (popupTarget && popupTarget.shouldBeVisible) {
                popupTarget.close();
            } else if (popupTarget) {
                const rect = volumeArea.mapToItem(null, 0, 0, width, height);
                popupTarget.setTriggerPosition(rect.x, rect.y, rect.width, section, parentScreen);
                popupTarget.open();
            }
        }
    }

    Row {
        id: volumeRow
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        DarkIcon {
            name: AudioService.getOutputIcon()
            size: 16
            color: AudioService.muted ? Theme.error : Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 1
                radius: 3
                samples: 16
                color: Qt.rgba(0, 0, 0, SettingsData.topBarDropShadowOpacity)
                transparentBorder: true
            }
        }

        StyledText {
            text: Math.round(AudioService.volume * 100) + "%"
            font.pixelSize: Theme.fontSizeSmall
            color: AudioService.muted ? Theme.error : Theme.surfaceText
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
            visible: SettingsData.mediaSize > 0

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 1
                radius: 4
                samples: 16
                color: Qt.rgba(0, 0, 0, SettingsData.topBarDropShadowOpacity)
                transparentBorder: true
            }
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: Theme.shortDuration
            easing.type: Theme.standardEasing
        }
    }
}