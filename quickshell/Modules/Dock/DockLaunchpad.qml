import QtQuick
import Quickshell
import qs.Common
import qs.Widgets

Rectangle {
    id: root

    

    property real widgetHeight: 40
    property var parentScreen: null

    readonly property real horizontalPadding: Math.max(Theme.spacingXS, Theme.spacingS * (widgetHeight / 30))

    width: launchpadIcon.width
    height: launchpadIcon.height
    radius: 0
    color: "transparent"

    function getLaunchpadLoader() {
        let current = root
        while (current) {
            if (current.launchpadLoader) {
                return current.launchpadLoader
            }
            current = current.parent
        }

        if (typeof launchpadLoader !== "undefined") {
            return launchpadLoader
        }

        return null
    }

    function openLaunchpad() {
        const loader = getLaunchpadLoader()
        if (!loader) {
            return
        }

        loader.active = true
        if (loader.item) {
            loader.item.targetScreen = parentScreen || (root.Window && root.Window.window ? root.Window.window.screen : Screen)
            if (loader.item.show) {
                loader.item.show()
            }
        }
    }

    Image {
        id: launchpadIcon
        anchors.centerIn: parent
        source: (typeof SessionData !== "undefined" && SessionData.isLightMode)
                 ? Qt.resolvedUrl("../../assets/Light_Launchpad.svg")
                 : Qt.resolvedUrl("../../assets/Dark_Launchpad.svg")
        width: 48
        height: 48
        smooth: true
        fillMode: Image.PreserveAspectFit
        mipmap: true
    }

    MouseArea {
        id: launchpadArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: root.openLaunchpad()
    }
}

