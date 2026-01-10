pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int cavaBars: 6
    readonly property int cavaFramerate: 25
    readonly property int cavaSensitivity: 30
    readonly property int cavaLowerFreq: 50
    readonly property int cavaHigherFreq: 12000
    readonly property int cavaNoiseReduction: 35
    readonly property int cavaIntegral: 90
    readonly property int cavaGravity: 95
    readonly property int cavaIgnore: 2
    readonly property real cavaMonstercat: 1.5
    
    property list<int> values: Array(cavaBars)
    property int refCount: 0
    property bool cavaAvailable: false

    Process {
        id: cavaCheck

        command: ["which", "cava"]
        running: false
        onExited: exitCode => {
            root.cavaAvailable = exitCode === 0
        }
    }

    Component.onCompleted: {
        cavaCheck.running = true
    }

    Process {
        id: cavaProcess

        running: root.cavaAvailable && root.refCount > 0
        
        command: ["sh", "-c", `printf '[general]\\nmode=normal\\nframerate=${root.cavaFramerate}\\nautosens=0\\nsensitivity=${root.cavaSensitivity}\\nbars=${root.cavaBars}\\nlower_cutoff_freq=${root.cavaLowerFreq}\\nhigher_cutoff_freq=${root.cavaHigherFreq}\\n[output]\\nmethod=raw\\nraw_target=/dev/stdout\\ndata_format=ascii\\nchannels=mono\\nmono_option=average\\n[smoothing]\\nnoise_reduction=${root.cavaNoiseReduction}\\nintegral=${root.cavaIntegral}\\ngravity=${root.cavaGravity}\\nignore=${root.cavaIgnore}\\nmonstercat=${root.cavaMonstercat}' | cava -p /dev/stdin`]

        onRunningChanged: {
            if (!running) {
                root.values = Array(root.cavaBars).fill(0)
            }
        }

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (root.refCount > 0 && data.trim()) {
                    let points = data.split(";").map(p => {
                                                         return parseInt(p.trim(), 10)
                                                     }).filter(p => {
                                                                   return !isNaN(p)
                                                               })
                    if (points.length >= root.cavaBars) {
                        root.values = points.slice(0, root.cavaBars)
                    }
                }
            }
        }
    }

    Component.onDestruction: {
        if (cavaCheck.running) {
            cavaCheck.running = false
        }
        if (cavaProcess.running) {
            cavaProcess.running = false
        }
    }
}


