import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: soundTab

    DarkFlickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.spacingL

            // Volume Mixer Widget (System + Applications only)
            ColumnLayout {
                width: parent.width
                spacing: Theme.spacingL

                // System Volume Controls
                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredHeight: systemVolumeRow.implicitHeight + Theme.spacingL * 2
                    radius: Theme.cornerRadius
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, Theme.getContentBackgroundAlpha() * 0.3)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                    border.width: 1

                    RowLayout {
                        id: systemVolumeRow
                        anchors.fill: parent
                        anchors.margins: Theme.spacingL
                        spacing: Theme.spacingM

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Theme.spacingXS

                            RowLayout {
                                spacing: Theme.spacingXS

                                StyledText {
                                    text: "System Volume"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: AudioService.muted ? Theme.error : Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                StyledText {
                                    text: AudioService.sink ? (" - " + AudioService.displayName(AudioService.sink)) : ""
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            DarkSlider {
                                Layout.fillWidth: true
                                minimum: 0
                                maximum: SettingsData.audioVolumeOverdrive ? 150 : 100
                                value: Math.round(AudioService.volume * 100)
                                showValue: true
                                unit: "%"
                                onSliderValueChanged: function(newValue) {
                                    AudioService.suppressOutputOSD();
                                    AudioService.setVolume(newValue / 100.0);
                                }
                            }
                        }

                        Rectangle {
                            width: Theme.iconSize + Theme.spacingM * 2
                            height: Theme.iconSize + Theme.spacingM * 2
                            radius: (Theme.iconSize + Theme.spacingM * 2) / 2
                            color: muteArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                            MouseArea {
                                id: muteArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    AudioService.suppressOutputOSD();
                                    AudioService.setOutputMuted(!AudioService.muted);
                                }
                            }

                            DarkIcon {
                                anchors.centerIn: parent
                                name: AudioService.getOutputIcon()
                                size: Theme.iconSize
                                color: AudioService.muted ? Theme.error : Theme.primary
                            }
                        }
                    }
                }

                // Application Streams
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingS

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Applications"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: `${ApplicationAudioService.applicationStreams.length} active`
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                    }

                    // Application volume controls
                    Repeater {
                        model: ApplicationAudioService.applicationStreams

                        delegate: Rectangle {
                            required property PwNode modelData

                            Layout.fillWidth: true
                            Layout.preferredHeight: appRow.implicitHeight + Theme.spacingM * 2
                            radius: Theme.cornerRadius
                            color: appArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.2)
                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                            border.width: 1

                            // Track individual node to ensure properties are bound
                            PwObjectTracker {
                                objects: modelData ? [modelData] : []
                            }

                            // Define audio properties like noctalia
                            property PwNodeAudio nodeAudio: (modelData && modelData.audio) ? modelData.audio : null
                            property real appVolume: (nodeAudio && nodeAudio.volume !== undefined) ? nodeAudio.volume : 0.0
                            property bool appMuted: (nodeAudio && nodeAudio.muted !== undefined) ? nodeAudio.muted : false

                            MouseArea {
                                id: appArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }

                            RowLayout {
                                id: appRow
                                anchors.fill: parent
                                anchors.margins: Theme.spacingM
                                spacing: Theme.spacingM

                                // App Icon
                                Image {
                                    Layout.preferredWidth: Theme.iconSize
                                    Layout.preferredHeight: Theme.iconSize
                                    Layout.alignment: Qt.AlignHCenter
                                    source: ApplicationAudioService.getApplicationIcon(modelData)
                                    sourceSize.width: Theme.iconSize * 25
                                    sourceSize.height: Theme.iconSize * 25
                                    smooth: true
                                    mipmap: true
                                    fillMode: Image.PreserveAspectFit
                                    cache: true
                                    asynchronous: true

                                    DarkIcon {
                                        anchors.fill: parent
                                        name: "apps"
                                        size: Theme.iconSize
                                        color: Theme.primary
                                        visible: parent.status === Image.Error || parent.status === Image.Null || parent.source === ""
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: Theme.spacingXS

                                    StyledText {
                                        text: ApplicationAudioService.getApplicationName(modelData)
                                        font.pixelSize: Theme.fontSizeMedium
                                        color: Theme.surfaceText
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    StyledText {
                                        text: {
                                            const device = ApplicationAudioService.getCurrentOutputDevice(modelData)
                                            return device ? (device.description || device.name || "Default") : "Default"
                                        }
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    DarkSlider {
                                        Layout.fillWidth: true
                                        minimum: 0
                                        maximum: SettingsData.audioVolumeOverdrive ? 150 : 100
                                        value: Math.round(appVolume * 100)
                                        showValue: true
                                        unit: "%"
                                        enabled: nodeAudio && modelData.ready
                                        onSliderValueChanged: function(newValue) {
                                            if (nodeAudio && modelData.ready) {
                                                nodeAudio.volume = newValue / 100.0;
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: Theme.iconSize + Theme.spacingS * 2
                                    Layout.preferredHeight: Theme.iconSize + Theme.spacingS * 2
                                    Layout.alignment: Qt.AlignBottom
                                    radius: (Theme.iconSize + Theme.spacingS * 2) / 2
                                    color: appMuteArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                                    MouseArea {
                                        id: appMuteArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (nodeAudio && modelData.ready) {
                                                nodeAudio.muted = !appMuted;
                                            }
                                        }
                                    }

                                    DarkIcon {
                                        anchors.centerIn: parent
                                        name: appMuted ? "volume_off" : "volume_up"
                                        size: Theme.iconSize - 4
                                        color: appMuted ? Theme.error : Theme.primary
                                    }
                                }
                            }
                        }
                    }

                    StyledText {
                        text: "No applications with audio output"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        visible: (ApplicationAudioService.applicationStreams || []).length === 0
                    }
                }
            }


            StyledRect {
                width: Math.min(parent.width * 1.2, parent.parent ? parent.parent.width - 48 : parent.width * 1.2)
                height: outputSection.implicitHeight + Theme.spacingL * 2
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1

                Column {
                    id: outputSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Default Output Device"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }

                    Loader {
                        width: parent.width
                        source: "../../Modules/ControlCenter/Widgets/AudioSliderRow.qml"
                    }
                }
            }


            StyledRect {
                width: Math.min(parent.width * 1.2, parent.parent ? parent.parent.width - 48 : parent.width * 1.2)
                height: outputDevicesSection.implicitHeight + Theme.spacingL * 2
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1

                Column {
                    id: outputDevicesSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Output Devices"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Repeater {
                            model: Pipewire.nodes?.values ? Pipewire.nodes.values.filter(node => {
                                return node && node.ready && node.audio && node.isSink && !node.isStream
                            }) : []

                            delegate: Rectangle {
                                required property var modelData
                                required property int index

                                width: parent.width
                                height: 50
                                radius: Theme.cornerRadius
                                color: deviceMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, index % 2 === 0 ? 0.3 : 0.2)
                                border.color: modelData === AudioService.sink ? Theme.primary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                                border.width: modelData === AudioService.sink ? 2 : 1

                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: Theme.spacingM
                                    spacing: Theme.spacingS

                                    DarkIcon {
                                        name: {
                                            if (modelData.name.includes("bluez"))
                                                return "headset"
                                            else if (modelData.name.includes("hdmi"))
                                                return "tv"
                                            else if (modelData.name.includes("usb"))
                                                return "headset"
                                            else
                                                return "speaker"
                                        }
                                        size: Theme.iconSize - 4
                                        color: modelData === AudioService.sink ? Theme.primary : Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.parent.width - parent.parent.anchors.leftMargin - parent.spacing - Theme.iconSize - Theme.spacingM

                                        StyledText {
                                            text: AudioService.displayName(modelData)
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Theme.surfaceText
                                            font.weight: modelData === AudioService.sink ? Font.Medium : Font.Normal
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }

                                        StyledText {
                                            text: modelData === AudioService.sink ? "Active" : "Available"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                    }
                                }

                                MouseArea {
                                    id: deviceMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData) {
                                            Pipewire.preferredDefaultAudioSink = modelData
                                        }
                                    }
                                }
                            }
                        }

                        StyledText {
                            text: "No output devices available"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            visible: !Pipewire.nodes || !Pipewire.nodes.values || Pipewire.nodes.values.filter(node => {
                                return node && node.ready && node.audio && node.isSink && !node.isStream
                            }).length === 0
                        }
                    }
                }
            }


            StyledRect {
                width: Math.min(parent.width * 1.2, parent.parent ? parent.parent.width - 48 : parent.width * 1.2)
                height: inputSection.implicitHeight + Theme.spacingL * 2
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1

                Column {
                    id: inputSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Default Input Device"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }

                    Loader {
                        width: parent.width
                        source: "../../Modules/ControlCenter/Widgets/InputAudioSliderRow.qml"
                    }
                }
            }


            StyledRect {
                width: Math.min(parent.width * 1.2, parent.parent ? parent.parent.width - 48 : parent.width * 1.2)
                height: inputDevicesSection.implicitHeight + Theme.spacingL * 2
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1

                Column {
                    id: inputDevicesSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Input Devices"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Repeater {
                            model: Pipewire.nodes?.values ? Pipewire.nodes.values.filter(node => {
                                return node && node.ready && node.audio && !node.isSink && !node.isStream
                            }) : []

                            delegate: Rectangle {
                                required property var modelData
                                required property int index

                                width: parent.width
                                height: 50
                                radius: Theme.cornerRadius
                                color: deviceMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, index % 2 === 0 ? 0.3 : 0.2)
                                border.color: modelData === AudioService.source ? Theme.primary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                                border.width: modelData === AudioService.source ? 2 : 1

                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: Theme.spacingM
                                    spacing: Theme.spacingS

                                    DarkIcon {
                                        name: {
                                            if (modelData.name.includes("bluez"))
                                                return "headset"
                                            else if (modelData.name.includes("usb"))
                                                return "headset"
                                            else
                                                return "mic"
                                        }
                                        size: Theme.iconSize - 4
                                        color: modelData === AudioService.source ? Theme.primary : Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.parent.width - parent.parent.anchors.leftMargin - parent.spacing - Theme.iconSize - Theme.spacingM

                                        StyledText {
                                            text: AudioService.displayName(modelData)
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Theme.surfaceText
                                            font.weight: modelData === AudioService.source ? Font.Medium : Font.Normal
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }

                                        StyledText {
                                            text: modelData === AudioService.source ? "Active" : "Available"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                    }
                                }

                                MouseArea {
                                    id: deviceMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData) {
                                            Pipewire.preferredDefaultAudioSource = modelData
                                        }
                                    }
                                }
                            }
                        }

                        StyledText {
                            text: "No input devices available"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            visible: !Pipewire.nodes || !Pipewire.nodes.values || Pipewire.nodes.values.filter(node => {
                                return node && node.ready && node.audio && !node.isSink && !node.isStream
                            }).length === 0
                        }
                    }
                }
            }

        }
    }
}
