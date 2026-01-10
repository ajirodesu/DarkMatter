import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property var instanceData: null
    property var screen: null

    readonly property var cfg: instanceData?.config ?? {}
    readonly property string desktopPath: StandardPaths.writableLocation(StandardPaths.DesktopLocation)

    // Grid layout properties
    readonly property int iconSize: cfg.iconSize ?? 64
    readonly property int iconSpacing: cfg.iconSpacing ?? 20
    readonly property int labelHeight: 20

    anchors.fill: parent

    FolderListModel {
        id: folderModel
        folder: "file://" + desktopPath
        showDirsFirst: true
        showDotAndDotDot: false
        showHidden: cfg.showHidden ?? false
        nameFilters: ["*.desktop", "*"] // Show .desktop files and all other files
        showFiles: true
        showDirs: true
        sortField: FolderListModel.Name
        sortReversed: false

        onStatusChanged: {
            if (status === FolderListModel.Ready) {
                // Model is ready, icons will be displayed
            }
        }
    }

    GridView {
        id: iconsGrid
        anchors.fill: parent
        anchors.leftMargin: iconSpacing
        anchors.topMargin: iconSpacing
        anchors.rightMargin: iconSpacing
        anchors.bottomMargin: iconSpacing

        cellWidth: iconSize + iconSpacing
        cellHeight: iconSize + iconSpacing + labelHeight

        model: folderModel
        clip: true

        delegate: Item {
            id: iconItem
            width: iconsGrid.cellWidth
            height: iconsGrid.cellHeight

            readonly property bool isDesktopFile: fileName.endsWith(".desktop")
            readonly property string fileName: folderModel.get(index, "fileName")
            readonly property string filePath: folderModel.get(index, "filePath")
            readonly property bool isDir: folderModel.get(index, "fileIsDir")
            readonly property string fileUrl: folderModel.get(index, "fileURL")

            // Extract name (remove .desktop extension)
            readonly property string displayName: {
                if (isDesktopFile) {
                    // Try to read .desktop file for proper name
                    return fileName.replace(/\.desktop$/, "");
                }
                return fileName;
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4

                // Icon
                Rectangle {
                    width: iconSize
                    height: iconSize
                    radius: Theme.cornerRadius
                    color: iconMouseArea.containsMouse ? Theme.surfaceHover : "transparent"
                    anchors.horizontalCenter: parent.horizontalCenter

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.shortDuration
                            easing.type: Theme.standardEasing
                        }
                    }

                    // Icon image/icon
                    Item {
                        anchors.fill: parent
                        anchors.margins: 8

                        // For .desktop files, try to load the icon
                        // For directories, use folder icon
                        // For files, use file icon
                        DarkIcon {
                            anchors.centerIn: parent
                            name: {
                                if (isDir) return "folder";
                                if (isDesktopFile) return "description"; // .desktop file icon
                                // Could try to detect file type and use appropriate icon
                                return "insert_drive_file";
                            }
                            size: iconSize - 16
                            color: Theme.surfaceText
                        }

                        // TODO: Load actual file/application icons
                        // This would require:
                        // 1. Reading .desktop file to get Icon= field
                        // 2. Using Quickshell.iconPath() or similar to resolve icon
                        // 3. Using CachingImage or similar to display icon
                    }
                }

                // Label
                StyledText {
                    width: iconSize + 20
                    text: displayName
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideMiddle
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                id: iconMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: function(mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        // Single click - open file/folder
                        if (isDir) {
                            // Open folder in file manager
                            Quickshell.execDetached(["xdg-open", fileUrl]);
                        } else if (isDesktopFile) {
                            // Execute .desktop file
                            Quickshell.execDetached(["gtk-launch", fileName.replace(/\.desktop$/, "")]);
                        } else {
                            // Open file with default application
                            Quickshell.execDetached(["xdg-open", fileUrl]);
                        }
                    } else if (mouse.button === Qt.RightButton) {
                        // Right click - show context menu
                        // TODO: Implement context menu
                    }
                }

                onDoubleClicked: {
                    // Double click - same as single click for now
                    if (isDir) {
                        Quickshell.execDetached(["xdg-open", fileUrl]);
                    } else if (isDesktopFile) {
                        Quickshell.execDetached(["gtk-launch", fileName.replace(/\.desktop$/, "")]);
                    } else {
                        Quickshell.execDetached(["xdg-open", fileUrl]);
                    }
                }
            }
        }
    }
}
