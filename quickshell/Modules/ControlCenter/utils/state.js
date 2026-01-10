function setTriggerPosition(root, x, y, width, section, screen) {
    // Only set trigger position if position setting is "follow-trigger" or empty
    // Otherwise, DarkPopout will use the positionSetting from SettingsData
    const positionSetting = root.objectName === "controlCenterPopout" ? SettingsData.controlCenterPosition : 
                           (root.objectName === "appDrawerPopout" ? SettingsData.appDrawerPosition : "")
    
    if (positionSetting === "follow-trigger" || positionSetting === "") {
        root._calculatedTriggerX = x
        root._calculatedTriggerY = y
        root._triggerPositionSet = true
    } else {
        // Don't set trigger position - let DarkPopout use positionSetting
        root._triggerPositionSet = false
    }
    root.triggerWidth = width
    root.triggerSection = section
    root.triggerScreen = screen
}

function openWithSection(root, section) {
    if (root.shouldBeVisible) {
        root.close()
    } else {
        root.expandedSection = section
        root.open()
    }
}

function toggleSection(root, section) {
    if (root.expandedSection === section) {
        root.expandedSection = ""
        root.expandedWidgetIndex = -1
    } else {
        root.expandedSection = section
    }
}