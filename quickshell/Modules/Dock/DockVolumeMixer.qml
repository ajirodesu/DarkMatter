import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.TopBar

Item {
    id: root

    property real widgetHeight: 40

    width: Theme.iconSizeLarge + 16
    height: widgetHeight

    // Volume Mixer popup target
    property var popupTarget: volumeMixerPopoutLoader.item

    LazyLoader {
        id: volumeMixerPopoutLoader
        active: false

        VolumeMixerPopout {
            id: volumeMixerPopout
            screen: Screen
            objectName: "dockVolumeMixerPopout"
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.3)
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
        clip: false

        DarkIcon {
            id: icon
            anchors.centerIn: parent
            name: getVolumeIcon()
            size: Theme.iconSizeLarge
            color: Theme.primary
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            scrollGestureEnabled: true
            
            onPressed: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    if (popupTarget && popupTarget.shouldBeVisible) {
                        popupTarget.close();
                    } else {
                        // Activate the lazy loader first
                        volumeMixerPopoutLoader.active = true;

                        // Calculate dock button position in screen coordinates
                        const rect = parent.mapToItem(null, 0, 0, width, height);

                        // Adjust for dock position (bottom by default)
                        var barPosition = SettingsData?.dockPosition || "bottom";
                        var barFloating = SettingsData?.dockFloating || false;
                        var barMarginH = barFloating ? (SettingsData?.dockMarginHorizontal || 0) : 0;
                        var barMarginV = barFloating ? (SettingsData?.dockMarginVertical || 0) : 0;
                        // Use dock exclusive zone for thickness (matches DarkPopout pattern)
                        // Exclusive zone includes: dockExclusiveZone + dockBottomGap + (dockTopPadding * 2)
                        var dockThickness = (SettingsData?.dockExclusiveZone || 0) + (SettingsData?.dockBottomGap || 0) + ((SettingsData?.dockTopPadding || 0) * 2);
                        // Fallback to dockHeight if exclusive zone not set
                        if (dockThickness === 0) {
                            dockThickness = (SettingsData?.dockHeight || 48) + (SettingsData?.dockBottomGap || 0) + ((SettingsData?.dockTopPadding || 0) * 2);
                        }

                        var screenX = rect.x;
                        var screenY = rect.y;

                        if (barPosition === "bottom") {
                            screenY += Screen.height - barMarginV - dockThickness;
                        } else if (barPosition === "top") {
                            screenY += barMarginV + dockThickness;
                        } else if (barPosition === "left") {
                            screenX += barMarginH + dockThickness;
                        } else if (barPosition === "right") {
                            screenX += Screen.width - barMarginH - dockThickness;
                        }

                        popupTarget.setTriggerPosition(screenX, screenY, rect.width, "dock", Screen);
                        popupTarget.open();
                    }
                }
            }
            
            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) {
                    // Scroll up - increase volume
                    AudioService.increaseVolume();
                } else if (wheel.angleDelta.y < 0) {
                    // Scroll down - decrease volume
                    AudioService.decreaseVolume();
                }
            }
        }
    }

    function getVolumeIcon() {
        // Use AudioService's built-in icon function if available, otherwise use our logic
        if (AudioService.getOutputIcon) {
            return AudioService.getOutputIcon()
        }
        
        // Fallback logic
        if (AudioService.muted) return "volume_off"
        
        const volume = AudioService.volume || 0
        if (volume === 0 || volume < 0.01) return "volume_off"
        if (volume <= 0.5) return "volume_down"
        return "volume_up"
    }
}