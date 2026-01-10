import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

StyledRect {
    id: root

    property var monitors: []
    property var monitorCapabilities: ({})
    property string selectedMonitor: ""
    signal monitorSelected(string monitorName)
    signal positionChanged(string monitorName, string newPosition)

    height: arrangementColumn.implicitHeight
    radius: Theme.cornerRadius
    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
    border.width: 1

    function parsePosition(pos) {
        if (!pos || pos === "") return {x: 0, y: 0}
        var parts = pos.split("x")
        if (parts.length >= 2) {
            return {x: parseInt(parts[0]) || 0, y: parseInt(parts[1]) || 0}
        }
        return {x: 0, y: 0}
    }

    function calculateAutoPosition(index) {
        var x = 0
        for (var i = 0; i < index; i++) {
            if (i < monitors.length && !monitors[i].disabled) {
                var caps = monitorCapabilities[monitors[i].name] || {}
                var width = caps.width || 1920
                var scale = parseFloat(monitors[i].scale || "1.0")
                x += (width / scale)
            }
        }
        return {x: x, y: 0}
    }

    function getMonitorBounds() {
        var minX = 0, minY = 0, maxX = 0, maxY = 0
        for (var i = 0; i < monitors.length; i++) {
            var monitor = monitors[i]
            if (monitor.disabled) continue
            var pos
            if (monitor.position && monitor.position !== "") {
                pos = parsePosition(monitor.position)
            } else {
                pos = calculateAutoPosition(i)
            }
            var caps = monitorCapabilities[monitor.name] || {}
            var width = caps.width || 1920
            var height = caps.height || 1080
            var scale = parseFloat(monitor.scale || "1.0")

            var scaledWidth = width / scale
            var scaledHeight = height / scale

            if (pos.x < minX) minX = pos.x
            if (pos.y < minY) minY = pos.y
            if (pos.x + scaledWidth > maxX) maxX = pos.x + scaledWidth
            if (pos.y + scaledHeight > maxY) maxY = pos.y + scaledHeight
        }
        return {minX: minX, minY: minY, maxX: maxX, maxY: maxY, width: maxX - minX, height: maxY - minY}
    }

    function alignMonitorsToTop() {

        var topmostY = null
        for (var i = 0; i < monitors.length; i++) {
            var monitor = monitors[i]
            if (monitor.disabled) continue
            var pos
            if (monitor.position && monitor.position !== "") {
                pos = parsePosition(monitor.position)
            } else {
                pos = calculateAutoPosition(i)
            }
            if (topmostY === null || pos.y < topmostY) {
                topmostY = pos.y
            }
        }


        if (topmostY === null) return


        for (var j = 0; j < monitors.length; j++) {
            var monitorToAlign = monitors[j]
            if (monitorToAlign.disabled) continue

            var currentPos
            if (monitorToAlign.position && monitorToAlign.position !== "") {
                currentPos = parsePosition(monitorToAlign.position)
            } else {
                currentPos = calculateAutoPosition(j)
            }


            if (currentPos.y !== topmostY) {
                var newPosition = currentPos.x + "x" + topmostY
                positionChanged(monitorToAlign.name, newPosition)
            }
        }
    }

    Column {
        id: arrangementColumn
        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM

        Item {
            width: parent.width
            height: Math.max(monitorArrangementText.implicitHeight, alignButton.height)

            StyledText {
                id: monitorArrangementText
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Monitor Arrangement"
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            StyledRect {
                id: alignButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                width: alignButtonText.implicitWidth + Theme.spacingM * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                border.color: Theme.primary
                border.width: 1
                visible: monitors.length > 0

                StyledText {
                    id: alignButtonText
                    anchors.centerIn: parent
                    text: "Align Top"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.primary
                }

                StateLayer {
                    stateColor: Theme.primary
                    cornerRadius: parent.radius
                    onClicked: {
                        root.alignMonitorsToTop()
                    }
                }
            }
        }

        Flickable {
            id: arrangementFlickable
            width: parent.width
            height: {
                // Responsive height based on available space
                const availableHeight = root.parent ? (root.parent.height || 600) : 600
                const minHeight = 300
                const maxHeight = Math.max(minHeight, availableHeight * 0.6)
                const calculatedHeight = arrangementArea.bounds.height * arrangementArea.scaleFactor + 40
                return Math.max(minHeight, Math.min(maxHeight, calculatedHeight))
            }
            clip: true
            flickableDirection: Flickable.HorizontalAndVerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.horizontal: DarkScrollbar {
                id: hbar
                orientation: Qt.Horizontal
            }

            ScrollBar.vertical: DarkScrollbar {
                id: vbar
                orientation: Qt.Vertical
            }

            property var bounds: ({minX: 0, minY: 0, maxX: 0, maxY: 0, width: 0, height: 0})
            
            function updateBounds() {
                bounds = root.getMonitorBounds()
            }
            
            property real baseScaleFactor: {
                if (bounds.width === 0 || bounds.height === 0) return 0.1
                var widthScale = (width - 40) / Math.max(bounds.width, 1920)
                var heightScale = (height - 40) / Math.max(bounds.height, 1080)
                return Math.min(widthScale, heightScale, 0.2)
            }
            property real zoomLevel: 0.8
            property real scaleFactor: baseScaleFactor * zoomLevel

            contentWidth: Math.max(width * 5, bounds.width * scaleFactor + 1000)
            contentHeight: Math.max(height * 5, bounds.height * scaleFactor + 1000)
            
            Component.onCompleted: {
                updateBounds()
            }
            
            Connections {
                target: root
                function onMonitorsChanged() {
                    arrangementFlickable.updateBounds()
                }
                function onMonitorCapabilitiesChanged() {
                    arrangementFlickable.updateBounds()
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                propagateComposedEvents: true
                onWheel: wheel => {
                    var delta = wheel.angleDelta.y
                    var oldZoom = arrangementFlickable.zoomLevel
                    var zoomFactor = delta > 0 ? 1.1 : 0.9
                    arrangementFlickable.zoomLevel = Math.max(0.1, Math.min(3.0, arrangementFlickable.zoomLevel * zoomFactor))

                    if (oldZoom !== arrangementFlickable.zoomLevel) {
                        var zoomRatio = arrangementFlickable.zoomLevel / oldZoom
                        var centerX = wheel.x
                        var centerY = wheel.y

                        var oldContentX = arrangementFlickable.contentX
                        var oldContentY = arrangementFlickable.contentY

                        var newContentX = oldContentX + (centerX - oldContentX) * (1 - zoomRatio)
                        var newContentY = oldContentY + (centerY - oldContentY) * (1 - zoomRatio)

                        arrangementFlickable.contentX = Math.max(0, Math.min(arrangementFlickable.contentWidth - arrangementFlickable.width, newContentX))
                        arrangementFlickable.contentY = Math.max(0, Math.min(arrangementFlickable.contentHeight - arrangementFlickable.height, newContentY))
                    }
                    wheel.accepted = true
                }
            }

            Item {
                id: arrangementArea
                width: Math.max(arrangementFlickable.contentWidth, parent.width * 5)
                height: Math.max(arrangementFlickable.contentHeight, parent.height * 5)

                property var bounds: arrangementFlickable.bounds
                property real scaleFactor: arrangementFlickable.scaleFactor

                Repeater {
                    model: root.monitors

                    delegate: Item {
                        id: monitorDelegate
                        property var monitor: modelData
                        property var pos: {
                            if (monitor.position && monitor.position !== "") {
                                return root.parsePosition(monitor.position)
                            }
                            return root.calculateAutoPosition(index)
                        }
                        property var caps: root.monitorCapabilities[monitor.name] || {}
                        property real monitorWidth: caps.width || 1920
                        property real monitorHeight: caps.height || 1080
                        property real monitorScale: parseFloat(monitor.scale || "1.0")
                        property real scaledWidth: (monitorWidth / monitorScale) * arrangementArea.scaleFactor
                        property real scaledHeight: (monitorHeight / monitorScale) * arrangementArea.scaleFactor
                        property bool isSelected: root.selectedMonitor === monitor.name
                        
                        // Cache monitor description text to avoid recalculating on every frame
                        property string monitorDescription: {
                            var make = caps.make || ""
                            var model = caps.model || ""
                            if (make && model) {
                                return make + " " + model
                            } else if (make) {
                                return make
                            } else if (model) {
                                return model
                            } else {
                                var desc = caps.description || ""
                                if (desc) {
                                    var parts = desc.split(" ")
                                    if (parts.length > 0) {
                                        return parts[0]
                                    }
                                }
                                return ""
                            }
                        }

                        x: (pos.x - arrangementArea.bounds.minX) * arrangementArea.scaleFactor + 20
                        y: (pos.y - arrangementArea.bounds.minY) * arrangementArea.scaleFactor + 20
                        width: scaledWidth
                        height: scaledHeight
                        z: isSelected ? 10 : 1

                        property point dragStart: Qt.point(0, 0)
                        property point startPos: Qt.point(0, 0)

                    StyledRect {
                        anchors.fill: parent
                        radius: Theme.cornerRadius
                        color: isSelected ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.4)
                        border.color: isSelected ? Theme.primary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
                        border.width: isSelected ? 2 : 1

                        Item {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingS

                            Column {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS
                                width: parent.width

                                StyledText {
                                    id: monitorNameText
                                    width: parent.width
                                    text: monitor.name
                                    property real calculatedFontSize: {
                                        var widthBased = parent.width / 5
                                        var heightBased = parent.height / 3
                                        return Math.max(36, Math.min(72, Math.min(widthBased, heightBased)))
                                    }
                                    font.pixelSize: calculatedFontSize
                                    font.weight: Font.Bold
                                    color: Theme.surfaceText
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                StyledText {
                                    width: parent.width
                                    text: monitorDelegate.monitorDescription
                                    property real calculatedFontSize: {
                                        var widthBased = parent.width / 20
                                        var heightBased = parent.height / 10
                                        return Math.max(10, Math.min(16, Math.min(widthBased, heightBased)))
                                    }
                                    font.pixelSize: calculatedFontSize
                                    font.weight: Font.Medium
                                    color: Theme.surfaceVariantText
                                    horizontalAlignment: Text.AlignHCenter
                                    visible: text !== ""
                                }
                            }
                        }
                    }

                    function checkCollision(newX, newY) {
                        var bounds = arrangementArea.bounds
                        var scale = arrangementArea.scaleFactor
                        var minX = bounds.minX
                        var minY = bounds.minY
                        var padding = 0.05
                        var newRight = newX + scaledWidth + padding
                        var newBottom = newY + scaledHeight + padding
                        
                        for (var i = 0; i < root.monitors.length; i++) {
                            var otherMonitor = root.monitors[i]
                            if (otherMonitor.name === monitor.name || otherMonitor.disabled) continue

                            var otherCaps = root.monitorCapabilities[otherMonitor.name] || {}
                            var otherPos
                            if (otherMonitor.position && otherMonitor.position !== "") {
                                otherPos = root.parsePosition(otherMonitor.position)
                            } else {
                                otherPos = root.calculateAutoPosition(i)
                            }
                            var otherWidth = (otherCaps.width || 1920) / parseFloat(otherMonitor.scale || "1.0")
                            var otherHeight = (otherCaps.height || 1080) / parseFloat(otherMonitor.scale || "1.0")

                            var otherScaledX = (otherPos.x - minX) * scale + 20
                            var otherScaledY = (otherPos.y - minY) * scale + 20
                            var otherRight = otherScaledX + (otherWidth * scale) + padding
                            var otherBottom = otherScaledY + (otherHeight * scale) + padding

                            if (newX < otherRight &&
                                newRight > otherScaledX &&
                                newY < otherBottom &&
                                newBottom > otherScaledY) {
                                return true
                            }
                        }
                        return false
                    }

                    function findSnapX(newX) {
                        var snapThreshold = 15
                        var currentLeft = newX
                        var currentRight = newX + scaledWidth
                        var bestSnapX = newX
                        var bestDistance = snapThreshold + 1
                        
                        var bounds = arrangementArea.bounds
                        var scale = arrangementArea.scaleFactor
                        var minX = bounds.minX

                        for (var i = 0; i < root.monitors.length; i++) {
                            var otherMonitor = root.monitors[i]
                            if (otherMonitor.name === monitor.name || otherMonitor.disabled) continue

                            var otherCaps = root.monitorCapabilities[otherMonitor.name] || {}
                            var otherPos
                            if (otherMonitor.position && otherMonitor.position !== "") {
                                otherPos = root.parsePosition(otherMonitor.position)
                            } else {
                                otherPos = root.calculateAutoPosition(i)
                            }
                            var otherWidth = (otherCaps.width || 1920) / parseFloat(otherMonitor.scale || "1.0")

                            var otherScaledX = (otherPos.x - minX) * scale + 20
                            var otherScaledWidth = otherWidth * scale
                            var otherLeft = otherScaledX
                            var otherRight = otherScaledX + otherScaledWidth

                            // Snap to left edge of other monitor (position this monitor to the left)
                            var leftDiff = Math.abs(currentRight - otherLeft)
                            if (leftDiff < bestDistance) {
                                bestSnapX = otherLeft - scaledWidth
                                bestDistance = leftDiff
                            }

                            // Snap to right edge of other monitor (position this monitor to the right)
                            var rightDiff = Math.abs(currentLeft - otherRight)
                            if (rightDiff < bestDistance) {
                                bestSnapX = otherRight
                                bestDistance = rightDiff
                            }

                            // Snap left edge to left edge
                            var leftLeftDiff = Math.abs(currentLeft - otherLeft)
                            if (leftLeftDiff < bestDistance) {
                                bestSnapX = otherLeft
                                bestDistance = leftLeftDiff
                            }

                            // Snap right edge to right edge
                            var rightRightDiff = Math.abs(currentRight - otherRight)
                            if (rightRightDiff < bestDistance) {
                                bestSnapX = otherRight - scaledWidth
                                bestDistance = rightRightDiff
                            }
                        }

                        if (bestDistance < snapThreshold) {
                            return bestSnapX
                        }
                        return newX
                    }

                    function findSnapY(newY) {
                        var snapThreshold = 15
                        var currentTop = newY
                        var currentBottom = newY + scaledHeight
                        var bestSnapY = newY
                        var bestDistance = snapThreshold + 1
                        
                        var bounds = arrangementArea.bounds
                        var scale = arrangementArea.scaleFactor
                        var minY = bounds.minY

                        for (var i = 0; i < root.monitors.length; i++) {
                            var otherMonitor = root.monitors[i]
                            if (otherMonitor.name === monitor.name || otherMonitor.disabled) continue

                            var otherCaps = root.monitorCapabilities[otherMonitor.name] || {}
                            var otherPos
                            if (otherMonitor.position && otherMonitor.position !== "") {
                                otherPos = root.parsePosition(otherMonitor.position)
                            } else {
                                otherPos = root.calculateAutoPosition(i)
                            }
                            var otherHeight = (otherCaps.height || 1080) / parseFloat(otherMonitor.scale || "1.0")

                            var otherScaledY = (otherPos.y - minY) * scale + 20
                            var otherScaledHeight = otherHeight * scale
                            var otherTop = otherScaledY
                            var otherBottom = otherScaledY + otherScaledHeight


                            var topDiff = Math.abs(currentTop - otherTop)
                            if (topDiff < bestDistance) {
                                bestSnapY = otherTop
                                bestDistance = topDiff
                            }


                            var topBottomDiff = Math.abs(currentTop - otherBottom)
                            if (topBottomDiff < bestDistance) {
                                bestSnapY = otherBottom
                                bestDistance = topBottomDiff
                            }


                            var bottomTopDiff = Math.abs(currentBottom - otherTop)
                            if (bottomTopDiff < bestDistance) {
                                bestSnapY = otherTop - scaledHeight
                                bestDistance = bottomTopDiff
                            }


                            var bottomDiff = Math.abs(currentBottom - otherBottom)
                            if (bottomDiff < bestDistance) {
                                bestSnapY = otherBottom - scaledHeight
                                bestDistance = bottomDiff
                            }
                        }


                        if (bestDistance < snapThreshold) {
                            return bestSnapY
                        }
                        return newY
                    }

                    MouseArea {
                        anchors.fill: parent
                        drag.target: parent
                        drag.axis: Drag.XAndYAxis
                        drag.threshold: 0
                        drag.minimumX: -50000
                        drag.maximumX: 50000
                        drag.minimumY: -50000
                        drag.maximumY: 50000

                        property real lastValidX: monitorDelegate.x
                        property real lastValidY: monitorDelegate.y
                        property bool isDragging: false

                        onPressed: mouse => {
                            root.selectedMonitor = monitor.name
                            root.monitorSelected(monitor.name)
                            monitorDelegate.dragStart = Qt.point(mouse.x, mouse.y)
                            monitorDelegate.startPos = Qt.point(monitorDelegate.x, monitorDelegate.y)
                            lastValidX = monitorDelegate.x
                            lastValidY = monitorDelegate.y
                            isDragging = false
                        }

                        onPositionChanged: mouse => {
                            if (drag.active) {
                                isDragging = true
                                var newX = monitorDelegate.x
                                var newY = monitorDelegate.y

                                // Only snap vertically during drag, horizontal snapping happens on release
                                var snappedY = findSnapY(newY)
                                newY = snappedY

                                if (checkCollision(newX, newY)) {
                                    monitorDelegate.x = lastValidX
                                    monitorDelegate.y = lastValidY
                                    return
                                }

                                monitorDelegate.x = newX
                                monitorDelegate.y = newY
                                lastValidX = newX
                                lastValidY = newY
                            }
                        }

                        onReleased: {
                            isDragging = false

                            var actualX = ((monitorDelegate.x - 20) / arrangementArea.scaleFactor) + arrangementArea.bounds.minX
                            var actualY = ((monitorDelegate.y - 20) / arrangementArea.scaleFactor) + arrangementArea.bounds.minY

                            // Check for alignment with adjacent monitors to prevent gaps
                            var caps = root.monitorCapabilities[monitor.name] || {}
                            var monitorWidth = (caps.width || 1920) / parseFloat(monitor.scale || "1.0")
                            var monitorRight = actualX + monitorWidth
                            var alignmentThreshold = 20 // pixels in actual coordinates

                            for (var i = 0; i < root.monitors.length; i++) {
                                var otherMonitor = root.monitors[i]
                                if (otherMonitor.name === monitor.name || otherMonitor.disabled) continue

                                var otherCaps = root.monitorCapabilities[otherMonitor.name] || {}
                                var otherPos
                                if (otherMonitor.position && otherMonitor.position !== "") {
                                    otherPos = root.parsePosition(otherMonitor.position)
                                } else {
                                    otherPos = root.calculateAutoPosition(i)
                                }
                                var otherWidth = (otherCaps.width || 1920) / parseFloat(otherMonitor.scale || "1.0")
                                var otherRight = otherPos.x + otherWidth

                                // If this monitor's left edge is close to another monitor's right edge
                                // (this monitor is to the right), align perfectly with no gap
                                var distanceToRight = Math.abs(actualX - otherRight)
                                if (distanceToRight < alignmentThreshold) {
                                    actualX = otherRight
                                    break
                                }
                                
                                // If this monitor's right edge is close to another monitor's left edge
                                // (this monitor is to the left), align perfectly with no gap
                                var distanceToLeft = Math.abs(monitorRight - otherPos.x)
                                if (distanceToLeft < alignmentThreshold) {
                                    actualX = otherPos.x - monitorWidth
                                    break
                                }
                            }

                            // Round to nearest pixel for precision
                            actualX = Math.round(actualX)
                            actualY = Math.round(actualY)

                            var newPosition = actualX + "x" + actualY
                            if (newPosition !== monitor.position) {
                                root.positionChanged(monitor.name, newPosition)
                            }
                        }
                    }
                }
            }
        }
    }
    }
}

