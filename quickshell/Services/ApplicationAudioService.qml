pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root
    readonly property int totalNodeCount: (Pipewire.nodes?.values || []).length

    signal applicationVolumeChanged
    signal applicationMuteChanged
    signal streamsChanged

    Component.onCompleted: {
        if (Pipewire.nodes) {
        }

        if (Pipewire.nodes) {
            Pipewire.nodes.valuesChanged.connect(() => {

                streamsChanged()
            })
        }
    }

    function isValidNode(node) {
        if (!node) return false
        if (!node.audio) return false

        try {
            if (node.isStream) {
                return true
            }

            if (!node.ready) return false
            return true
        } catch (e) {
            return false
        }
    }

    function isValidStreamNode(node) {
        if (!node) return false
        if (!node.audio) return false

        try {
            return node.isStream !== undefined
        } catch (e) {
            return false
        }
    }
    
    function isNodeReadyForVolumeControl(node) {
        if (!node || !node.audio) return false




        if (node.ready === false) {
            return false
        }


        return true
    }

    readonly property var applicationStreams: (Pipewire.nodes?.values || []).filter(node => {
        if (!isValidStreamNode(node)) return false
        try {
            return node.isStream && node.isSink
        } catch (e) {
            return false
        }
    })

    readonly property var applicationInputStreams: (Pipewire.nodes?.values || []).filter(node => {
        if (!isValidStreamNode(node)) return false
        try {
            return node.isStream && !node.isSink
        } catch (e) {
            return false
        }
    })

    readonly property var outputDevices: (Pipewire.nodes?.values || []).filter(node => {
        if (!isValidNode(node)) return false
        try {
            return !node.isStream && node.isSink
        } catch (e) {
            return false
        }
    })

    readonly property var inputDevices: (Pipewire.nodes?.values || []).filter(node => {
        if (!isValidNode(node)) return false
        try {
            return !node.isStream && !node.isSink
        } catch (e) {
            return false
        }
    })

    function getApplicationName(node) {
        if (!node) {
            return "Unknown Application";
        }

        const props = node.properties || {};
        const desc = node.description || "";
        const name = node.name || "";

        // Debug logging for Electron apps
        const appName = props["application.name"] || "";
        const binaryName = props["application.process.binary"] || "";
        if (binaryName.includes("chromium") || binaryName.includes("electron") || appName.toLowerCase().includes("cider")) {
            console.log("AudioService Debug - Node:", name, "App:", appName, "Binary:", binaryName, "Props:", JSON.stringify(props));
        }

        // If properties aren't available yet, try description or name
        if (!props) {
            if (desc) {
                return desc;
            }
            if (name) {
                // Try to extract meaningful name from node name
                const nameParts = name.split(/[-_]/);
                if (nameParts.length > 0) {
                    const extracted = nameParts[0];
                    if (extracted) {
                        return extracted.charAt(0).toUpperCase() + extracted.slice(1);
                    }
                }
                return name;
            }
            return "Unknown Application";
        }

        // Try to get application name from various properties
        let computedAppName = props["application.name"] || "";
        const mediaName = props["media.name"] || "";
        const mediaTitle = props["media.title"] || "";
        const appId = props["application.id"] || "";
        // binaryName already declared above for debug logging

        // Special handling for Electron apps like Cider
        if (binaryName && binaryName.toLowerCase().includes("cider")) {
            console.log("AudioService Debug - Detected Cider from binary:", binaryName, "-> Setting name to 'Cider'");
            computedAppName = "Cider";
        }

        // If we have application.id, try to extract app name from it (e.g., "firefox.desktop" -> "firefox")
        if (!computedAppName && appId) {
            const parts = appId.split(".");
            if (parts.length > 0) {
                computedAppName = parts[0];
                // Capitalize first letter and format nicely
                if (computedAppName) {
                    computedAppName = computedAppName.charAt(0).toUpperCase() + computedAppName.slice(1);
                }
            }
        }

        // Try binary name as fallback (but avoid generic Electron names)
        if (!computedAppName && binaryName) {
            const binParts = binaryName.split("/");
            if (binParts.length > 0) {
                const binBaseName = binParts[binParts.length - 1];
                // Skip generic Electron/Chromium binaries if we have application.name
                if (binBaseName !== "chromium" && binBaseName !== "electron" && binBaseName !== "chrome") {
                    computedAppName = binBaseName.charAt(0).toUpperCase() + binBaseName.slice(1);
                }
            }
        }

        // Priority: application.name > media.title > media.name > binary > description > name
        let result = computedAppName || mediaTitle || mediaName || binaryName || desc || name;

        // If we still don't have a good name, try to extract from node name
        if (!result || result === "" || result === "Unknown Application") {
            if (name) {
                // Try to extract meaningful name from node name (e.g., "firefox-1234" -> "firefox")
                const nameParts = name.split(/[-_]/);
                if (nameParts.length > 0) {
                    result = nameParts[0];
                    // Capitalize first letter
                    if (result) {
                        result = result.charAt(0).toUpperCase() + result.slice(1);
                    }
                }
            }
        }

        return result || "Unknown Application";
    }

    function getApplicationIconName(node) {
        if (!node) return ""

        const props = node.properties || {}
        const binaryName = props["application.process.binary"] || "";

        // Special handling for Electron apps like Cider
        if (binaryName && binaryName.toLowerCase().includes("cider")) {
            return "cider";
        }

        // Try application.icon-name first (from Pipewire)
        let iconName = props["application.icon-name"] || "";
        if (iconName) {
            // Debug logging
            const appName = props["application.name"] || "";
            if (appName.toLowerCase().includes("cider") || iconName.includes("chromium")) {
                console.log("AudioService Debug - Icon from application.icon-name:", iconName, "for app:", appName);
            }
            return iconName;
        }

        // Try to get app ID and extract icon name from it (e.g., "cider.desktop" -> "cider")
        const appId = props["application.id"] || "";
        if (appId) {
            const parts = appId.split(".");
            if (parts.length > 0) {
                const extractedIcon = parts[0].toLowerCase();
                // Skip generic names
                if (extractedIcon !== "chromium" && extractedIcon !== "electron") {
                    return extractedIcon;
                }
            }
        }

        // Try application.name (prioritize this for Electron apps)
        const appName = props["application.name"] || "";
        if (appName) {
            // For known Electron apps, use the app name
            const lowerAppName = appName.toLowerCase();
            if (lowerAppName === "cider" || lowerAppName === "discord" || lowerAppName === "slack" ||
                lowerAppName === "vscode" || lowerAppName === "code" || lowerAppName.includes("electron")) {
                return lowerAppName;
            }
            return lowerAppName;
        }

        // Try binary name (avoid generic Electron names)
        if (binaryName) {
            const binParts = binaryName.split("/");
            if (binParts.length > 0) {
                const binName = binParts[binParts.length - 1].toLowerCase();
                // Skip generic Electron/Chromium binaries
                if (binName !== "chromium" && binName !== "electron" && binName !== "chrome") {
                    return binName;
                }
            }
        }

        // Try node name as fallback
        const nodeName = node.name || "";
        if (nodeName) {
            const nameParts = nodeName.split(/[-_]/);
            if (nameParts.length > 0) {
                const extractedName = nameParts[0].toLowerCase();
                // Skip generic names
                if (extractedName !== "chromium" && extractedName !== "electron") {
                    return extractedName;
                }
            }
        }

        return ""
    }

    function getApplicationIcon(node) {
        const iconName = getApplicationIconName(node)
        if (iconName) {
            try {
                const iconPath = Quickshell.iconPath(iconName, "application-x-executable")
                // Debug logging
                const appName = node?.properties?.["application.name"] || "";
                if (appName.toLowerCase().includes("cider") || iconName.includes("chromium")) {
                    console.log("AudioService Debug - Resolved icon:", iconName, "->", iconPath, "for app:", appName);
                }
                return iconPath
            } catch (e) {
                return ""
            }
        }
        return ""
    }

    function isNodeBound(node) {
        return isNodeReadyForVolumeControl(node)
    }

    function setApplicationVolume(node, percentage) {
        if (!node || !node.audio) {
            return "No audio stream available"
        }
        
        if (node.ready === false) {
            return "Node not ready"
        }

        try {
            const clampedVolume = Math.max(0, Math.min(100, percentage))
            const volumeValue = clampedVolume / 100
            node.audio.volume = volumeValue
            root.applicationVolumeChanged()
            return `Volume set to ${clampedVolume}%`
        } catch (e) {
            return "Failed to set volume"
        }
    }

    function toggleApplicationMute(node) {
        if (!node || !node.audio) {
            return "No audio stream available"
        }
        
        if (!isNodeBound(node)) {
            return "Node not ready"
        }

        try {
            node.audio.muted = !node.audio.muted
            root.applicationMuteChanged()
            return node.audio.muted ? "Application muted" : "Application unmuted"
        } catch (e) {
            return "Failed to toggle mute"
        }
    }

    function setApplicationInputVolume(node, percentage) {
        if (!node || !node.audio) {
            return "No audio input stream available"
        }
        
        if (!isNodeBound(node)) {
            return "Node not ready"
        }

        try {
            const clampedVolume = Math.max(0, Math.min(100, percentage))
            node.audio.volume = clampedVolume / 100
            root.applicationVolumeChanged()
            return `Input volume set to ${clampedVolume}%`
        } catch (e) {
            return "Failed to set input volume"
        }
    }

    function toggleApplicationInputMute(node) {
        if (!node || !node.audio) {
            return "No audio input stream available"
        }
        
        if (!isNodeBound(node)) {
            return "Node not ready"
        }

        try {
            node.audio.muted = !node.audio.muted
            root.applicationMuteChanged()
            return node.audio.muted ? "Application input muted" : "Application input unmuted"
        } catch (e) {
            return "Failed to toggle input mute"
        }
    }

    function routeStreamToOutput(streamNode, targetSinkNode) {
        if (!streamNode || !targetSinkNode) {
            return "Invalid stream or target device"
        }
        if (!streamNode.isStream || !streamNode.isSink) {
            return "Not an output stream"
        }
        if (targetSinkNode.isStream || !targetSinkNode.isSink) {
            return "Not a valid output device"
        }
        
        try {
            const streamId = streamNode.id
            const sinkId = targetSinkNode.id
            
            if (!streamId || !sinkId) {
                return "Invalid stream or sink ID"
            }
            
            




            const connectCmd = ["pw-link", streamId.toString(), sinkId.toString()]
            

            const connectProcess = connectProcessComponent.createObject(root, {
                streamId: streamId,
                sinkId: sinkId,
                deviceName: targetSinkNode.description || targetSinkNode.name,
                callback: function() {
                    root.applicationVolumeChanged()
                }
            })
            
            return "Routing stream..."
        } catch (e) {
            return "Failed to route stream: " + e
        }
    }
    
    Component {
        id: connectProcessComponent
        Process {
            property int streamId
            property int sinkId
            property string deviceName
            property var callback
            
            command: ["pw-link", streamId.toString(), sinkId.toString()]
            
            Component.onCompleted: {
                running = true
            }
            
            onExited: function(exitCode) {
                if (exitCode === 0) {
                    if (callback) callback()
                } else {
                    if (typeof LoggingService !== 'undefined') {
                        LoggingService.debug("ApplicationAudioService", "Primary connection failed, trying alternative", { exitCode: exitCode, streamId: streamId, sinkId: sinkId })
                    }
                    const altProcess = connectProcessAltComponent.createObject(root, {
                        streamId: streamId,
                        sinkId: sinkId,
                        deviceName: deviceName,
                        callback: callback
                    })
                    if (!altProcess) {
                        if (typeof LoggingService !== 'undefined') {
                            LoggingService.error("ApplicationAudioService", "Failed to create alternative connection process")
                        }
                    }
                }
                destroy()
            }
        }
    }
    
    Component {
        id: connectProcessAltComponent
        Process {
            property int streamId
            property int sinkId
            property string deviceName
            property var callback
            

            command: ["pw-link", streamId.toString() + ":output_FL", sinkId.toString() + ":input_FL"]
            
            Component.onCompleted: {
                running = true
            }
            
            onExited: function(exitCode) {
                if (exitCode === 0 && callback) {
                    callback()
                } else {
                    if (typeof LoggingService !== 'undefined') {
                        LoggingService.warn("ApplicationAudioService", "Alternative connection process failed", { exitCode: exitCode, streamId: streamId, sinkId: sinkId })
                    }
                }
                destroy()
            }
        }
    }

    function routeStreamToInput(streamNode, targetSourceNode) {
        if (!streamNode || !targetSourceNode) {
            return "Invalid stream or target device"
        }
        if (!streamNode.isStream || streamNode.isSink) {
            return "Not an input stream"
        }
        if (targetSourceNode.isStream || targetSourceNode.isSink) {
            return "Not a valid input device"
        }
        
        try {
            const streamId = streamNode.id
            const sourceId = targetSourceNode.id
            
            if (!streamId || !sourceId) {
                return "Invalid stream or source ID"
            }
            
            



            const connectCmd = ["pw-link", sourceId.toString(), streamId.toString()]
            
            const connectProcess = connectInputProcessComponent.createObject(root, {
                streamId: streamId,
                sourceId: sourceId,
                deviceName: targetSourceNode.description || targetSourceNode.name,
                callback: function() {
                    root.applicationVolumeChanged()
                }
            })
            
            return "Routing input stream..."
        } catch (e) {
            return "Failed to route stream: " + e
        }
    }
    
    Component {
        id: connectInputProcessComponent
        Process {
            property int streamId
            property int sourceId
            property string deviceName
            property var callback
            
            command: ["pw-link", sourceId.toString(), streamId.toString()]
            
            Component.onCompleted: {
                running = true
            }
            
            onExited: function(exitCode) {
                if (exitCode === 0) {
                    if (callback) callback()
                } else {

                    const altProcess = connectInputProcessAltComponent.createObject(root, {
                        streamId: streamId,
                        sourceId: sourceId,
                        deviceName: deviceName,
                        callback: callback
                    })
                }
                destroy()
            }
        }
    }
    
    Component {
        id: connectInputProcessAltComponent
        Process {
            property int streamId
            property int sourceId
            property string deviceName
            property var callback
            
            command: ["pw-link", sourceId.toString() + ":output_FL", streamId.toString() + ":input_FL"]
            
            Component.onCompleted: {
                running = true
            }
            
            onExited: function(exitCode) {
                if (exitCode === 0 && callback) {
                    callback()
                } else {
                    if (typeof LoggingService !== 'undefined') {
                        LoggingService.warn("ApplicationAudioService", "Alternative input connection process failed", { exitCode: exitCode, streamId: streamId, sourceId: sourceId })
                    }
                }
                destroy()
            }
        }
    }

    function getCurrentOutputDevice(streamNode) {
        if (!streamNode || !streamNode.isStream || !streamNode.isSink) {
            return null
        }



        return AudioService.sink
    }

    function getCurrentInputDevice(streamNode) {
        if (!streamNode || !streamNode.isStream || streamNode.isSink) {
            return null
        }

        return AudioService.source
    }


    function getTrackableNodes() {
        if (!Pipewire.nodes?.values) return []
        const nodes = []
        for (let i = 0; i < Pipewire.nodes.values.length; i++) {
            const node = Pipewire.nodes.values[i]
            if (!node) continue


            if (node.ready && node.audio) {
                try {

                    if (node.properties !== undefined && node.name !== undefined) {
                        nodes.push(node)
                    }
                } catch (e) {

                }
            }
        }
        return nodes
    }

    PwObjectTracker { 
        objects: root.getTrackableNodes()
        Component.onCompleted: {
        }
    }

    function debugAllNodes() {
        if (!Pipewire.ready || !Pipewire.nodes?.values) {
            return
        }
    }
}
