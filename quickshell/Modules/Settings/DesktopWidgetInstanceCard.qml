import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Settings.DesktopWidgetSettings as DWS

StyledRect {
    id: root

    required property var instanceData
    property bool isExpanded: false
    property bool confirmingDelete: false

    readonly property string instanceId: instanceData?.id ?? ""
    readonly property string widgetType: instanceData?.widgetType ?? ""
    readonly property var widgetDef: typeof DesktopWidgetRegistry !== 'undefined' ? DesktopWidgetRegistry.getWidget(widgetType) : null
    readonly property string widgetName: instanceData?.name ?? (widgetDef?.name ?? widgetType)

    readonly property var widgetIcons: {
        "desktopClock": "schedule",
        "systemMonitor": "monitoring",
        "desktopCpuTemp": "device_thermostat",
        "desktopGpuTemp": "auto_awesome_mosaic",
        "desktopTerminal": "terminal"
    }

    signal deleteRequested
    signal duplicateRequested
    signal expandedChanged(bool expanded)

    width: parent?.width ?? 400
    radius: Theme.cornerRadius
    color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, Theme.popupTransparency)
    height: {
        if (collapsed)
            return headerRow.height + Theme.spacingL * 2;
        return headerRow.height + Theme.spacingL * 2 + contentColumn.height + Theme.spacingM;
    }

    readonly property bool collapsed: !isExpanded

    Behavior on height {
        NumberAnimation {
            duration: Theme.mediumDuration
            easing.type: Theme.emphasizedEasing
        }
    }

    RowLayout {
        id: headerRow
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingL
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingL
        anchors.top: parent.top
        anchors.topMargin: Theme.spacingL
        height: Math.max(Theme.iconSize, titleText.height) + Theme.spacingS
        spacing: Theme.spacingM

        DarkIcon {
            name: widgetDef?.icon ?? widgetIcons[widgetType] ?? "widgets"
            size: Theme.iconSize
            color: Theme.primary
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: Theme.iconSize
            Layout.preferredHeight: Theme.iconSize
        }

        StyledText {
            id: titleText
            text: widgetName
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Font.Medium
            color: Theme.surfaceText
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Item {
            Layout.preferredWidth: Theme.iconSize
            Layout.preferredHeight: Theme.iconSize
            Layout.alignment: Qt.AlignVCenter

            DarkToggle {
                anchors.centerIn: parent
                checked: instanceData?.enabled ?? true
                onToggled: isChecked => {
                    if (!root.instanceId)
                        return;
                    SettingsData.updateDesktopWidgetInstance(root.instanceId, {
                        enabled: isChecked
                    });
                }
            }
        }

        DarkActionButton {
            iconName: "more_vert"
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: Theme.iconSize
            Layout.preferredHeight: Theme.iconSize
            onClicked: actionsMenu.open()

            Popup {
                id: actionsMenu
                x: -width + parent.width
                y: parent.height + Theme.spacingXS
                width: 160
                padding: Theme.spacingXS
                modal: true
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                onClosed: root.confirmingDelete = false

                background: Rectangle {
                    color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, Theme.popupTransparency)
                    radius: Theme.cornerRadius
                    border.color: Theme.outlineLight
                    border.width: 1
                }

                contentItem: Column {
                    spacing: 2

                    Rectangle {
                        width: parent.width
                        height: Theme.iconSizeLarge
                        radius: Theme.cornerRadius
                        color: duplicateArea.containsMouse ? Theme.primaryHover : "transparent"

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingS
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingS

                            DarkIcon {
                                name: "content_copy"
                                size: Theme.iconSizeSmall
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Duplicate"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                            }
                        }

                        MouseArea {
                            id: duplicateArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                actionsMenu.close();
                                root.duplicateRequested();
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: Theme.iconSizeLarge
                        radius: Theme.cornerRadius
                        color: deleteArea.containsMouse ? Theme.errorHover : "transparent"

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingS
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingS

                            DarkIcon {
                                name: root.confirmingDelete ? "warning" : "delete"
                                size: Theme.iconSizeSmall
                                color: Theme.error
                            }

                            StyledText {
                                text: root.confirmingDelete ? "Confirm Delete" : "Delete"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.error
                            }
                        }

                        MouseArea {
                            id: deleteArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.confirmingDelete) {
                                    actionsMenu.close();
                                    root.deleteRequested();
                                    return;
                                }
                                root.confirmingDelete = true;
                            }
                        }
                    }
                }
            }
        }

        DarkActionButton {
            iconName: isExpanded ? "expand_less" : "expand_more"
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: Theme.iconSize
            Layout.preferredHeight: Theme.iconSize
            onClicked: {
                isExpanded = !isExpanded;
                expandedChanged(isExpanded);
            }
        }
    }

    Column {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerRow.bottom
        anchors.topMargin: Theme.spacingM
        anchors.leftMargin: Theme.spacingL
        anchors.rightMargin: Theme.spacingL
        spacing: Theme.spacingM
        visible: root.isExpanded
        opacity: visible ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }
        }

        Row {
            width: parent.width
            spacing: Theme.spacingM

            StyledText {
                text: "Name"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                width: 80
            }

            DarkTextField {
                width: parent.width - 80 - Theme.spacingM
                text: root.widgetName
                onEditingFinished: {
                    if (!root.instanceId)
                        return;
                    SettingsData.updateDesktopWidgetInstance(root.instanceId, {
                        name: text
                    });
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.outlineMedium
        }

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
                value: Math.round((instanceData?.config?.transparency ?? 0.9) * 100)
                minimum: 10
                maximum: 100
                unit: "%"
                showValue: true
                wheelEnabled: false
                onSliderValueChanged: newValue => {
                    if (!root.instanceId)
                        return;
                    SettingsData.updateDesktopWidgetInstanceConfig(root.instanceId, {
                        transparency: newValue / 100
                    });
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.outlineMedium
        }

        Column {
            width: parent.width
            spacing: Theme.spacingS

            StyledText {
                text: "Display"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                font.weight: Font.Medium
            }

            StyledText {
                text: "Choose which displays show this widget. If not set, shows on all displays."
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: parent.width
            }

            SettingsDisplayPicker {
                width: parent.width
                displayPreferences: {
                    const prefs = root.instanceData?.config?.displayPreferences;
                    if (!prefs || prefs.length === 0) {
                        return ["all"];
                    }
                    return prefs;
                }
                onPreferencesChanged: preferences => {
                    if (!root.instanceId)
                        return;
                    SettingsData.updateDesktopWidgetInstanceConfig(root.instanceId, {
                        displayPreferences: preferences
                    });
                }
            }
        }

        Loader {
            id: widgetSettingsLoader
            width: parent.width
            active: root.isExpanded && root.widgetType !== ""
            sourceComponent: {
                switch (root.widgetType) {
                case "desktopClock":
                    return root.clockSettingsComponent;
                case "systemMonitor":
                case "systemMonitorDetailed":
                    return root.systemMonitorSettingsComponent;
                default:
                    return root.pluginSettingsComponent;
                }
            }
            onLoaded: {
                if (!item)
                    return;
                item.instanceId = root.instanceId;
                item.instanceData = Qt.binding(() => root.instanceData);
            }
        }
    }

    property Component clockSettingsComponent: Component {
        DWS.ClockSettings {}
    }

    property Component systemMonitorSettingsComponent: Component {
        DWS.SystemMonitorSettings {}
    }

    property Component pluginSettingsComponent: Component {
        DWS.PluginDesktopWidgetSettings {
            widgetType: root.widgetType
            widgetDef: root.widgetDef
        }
    }
}
