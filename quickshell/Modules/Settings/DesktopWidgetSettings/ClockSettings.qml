import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Column {
    id: root

    property string instanceId: ""
    property var instanceData: null

    readonly property var cfg: instanceData?.config ?? {}

    function updateConfig(key, value) {
        if (!instanceId)
            return;
        var updates = {};
        updates[key] = value;
        SettingsData.updateDesktopWidgetInstanceConfig(instanceId, updates);
    }

    width: parent?.width ?? 400
    spacing: Theme.spacingM

    Row {
        width: parent.width
        spacing: Theme.spacingM

        StyledText {
            text: "Transparency"
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
            width: 120
        }

        DarkSlider {
            width: parent.width - 120 - Theme.spacingM
            height: 32
            value: Math.round((cfg.transparency ?? 0.8) * 100)
            minimum: 10
            maximum: 100
            unit: "%"
            showValue: true
            wheelEnabled: false
            onSliderValueChanged: newValue => root.updateConfig("transparency", newValue / 100)
        }
    }
}
