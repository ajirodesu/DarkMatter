pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property var extractedColors: []
    property var selectedColors: []
    property real hueShiftDegrees: 0          // -180..180
    property real saturationScale: 1.0        // 0.5..1.5
    property real lightnessScale: 1.0         // 0.5..1.5
    property bool isExtracting: false
    property string currentWallpaper: ""
    property var customThemeData: null
    property string customThemeFilePath: ""
    property bool customThemeReady: false
    property var availableThemes: []
    property string currentThemeName: {
        if (typeof SettingsData !== 'undefined') {
            return SettingsData.currentColorTheme || ""
        }
        return ""
    }
    
    property bool _initialized: false
    
    function initializeIfNeeded() {
        if (!_initialized) {
            _initialized = true
            Qt.callLater(function() {
                if (typeof SettingsData !== 'undefined' && SettingsData.savedColorThemes !== undefined) {
                    loadCustomThemeFromSettings()
                    updateAvailableThemes()
                }
            })
        }
    }

    signal colorsExtracted()
    signal colorsChanged()
    signal customThemeCreated(var themeData)
    signal themesUpdated()
    signal textColorAdjustmentChanged()

    function extractColorsFromWallpaper(wallpaperPath) {
        if (!wallpaperPath || wallpaperPath === currentWallpaper) {
            return
        }
        
        currentWallpaper = wallpaperPath
        isExtracting = true
        
        matugenProcess.command = ["matugen", "--json", "hex", "image", wallpaperPath]
        matugenProcess.running = true
    }

    function selectColor(color, selected) {
        if (selected) {
            if (!selectedColors.includes(color)) {
                selectedColors.push(color)
            }
        } else {
            const index = selectedColors.indexOf(color)
            if (index > -1) {
                selectedColors.splice(index, 1)
            }
        }
        colorsChanged()
    }

    function clearSelection() {
        selectedColors = []
        colorsChanged()
    }
    
    function getBrightness(color) {
        let r, g, b
        if (typeof color === 'string' && color.startsWith('#')) {
            r = parseInt(color.slice(1, 3), 16) / 255
            g = parseInt(color.slice(3, 5), 16) / 255
            b = parseInt(color.slice(5, 7), 16) / 255
        } else {
            r = color.r || 0
            g = color.g || 0
            b = color.b || 0
        }
        return (r * 0.299 + g * 0.587 + b * 0.114)
    }

    function clamp01(value) {
        return Math.max(0, Math.min(1, value))
    }

    function hexToHsl(hex) {
        if (typeof hex !== 'string' || !hex.startsWith('#') || (hex.length !== 7 && hex.length !== 9)) {
            return { h: 0, s: 0, l: 0 }
        }
        const r = parseInt(hex.substr(1, 2), 16) / 255
        const g = parseInt(hex.substr(3, 2), 16) / 255
        const b = parseInt(hex.substr(5, 2), 16) / 255

        const max = Math.max(r, g, b)
        const min = Math.min(r, g, b)
        let h = 0
        let s = 0
        const l = (max + min) / 2

        if (max !== min) {
            const d = max - min
            s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
            switch (max) {
            case r: h = (g - b) / d + (g < b ? 6 : 0); break
            case g: h = (b - r) / d + 2; break
            case b: h = (r - g) / d + 4; break
            }
            h /= 6
        }
        return { h, s, l }
    }

    function hslToHex(h, s, l) {
        const hue2rgb = (p, q, t) => {
            if (t < 0) t += 1
            if (t > 1) t -= 1
            if (t < 1 / 6) return p + (q - p) * 6 * t
            if (t < 1 / 2) return q
            if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6
            return p
        }

        let r, g, b

        if (s === 0) {
            r = g = b = l // achromatic
        } else {
            const q = l < 0.5 ? l * (1 + s) : l + s - l * s
            const p = 2 * l - q
            r = hue2rgb(p, q, h + 1 / 3)
            g = hue2rgb(p, q, h)
            b = hue2rgb(p, q, h - 1 / 3)
        }

        const toHex = (x) => {
            const v = Math.round(x * 255)
            return v.toString(16).padStart(2, '0')
        }

        return "#" + toHex(r) + toHex(g) + toHex(b)
    }

    function applyHueAdjustments(color) {
        if (!color) return color

        let hex = color

        // Accept Qt color objects
        if (typeof color === 'object' && color.r !== undefined) {
            const r = Math.max(0, Math.min(1, color.r))
            const g = Math.max(0, Math.min(1, color.g))
            const b = Math.max(0, Math.min(1, color.b))
            const toHex = (v) => Math.round(v * 255).toString(16).padStart(2, '0')
            hex = "#" + toHex(r) + toHex(g) + toHex(b)
        }

        if (typeof hex !== 'string' || !hex.startsWith('#')) {
            return hex
        }

        const hsl = hexToHsl(hex)
        let h = (hsl.h * 360 + hueShiftDegrees) % 360
        if (h < 0) h += 360
        h /= 360
        const s = clamp01(hsl.s * saturationScale)
        const l = clamp01(hsl.l * lightnessScale)

        return hslToHex(h, s, l)
    }

    function normalizeThemeData(themeData) {
        if (!themeData) return null
        if (themeData.dark || themeData.light) {
            const darkTheme = themeData.dark || themeData.light
            const lightTheme = themeData.light || themeData.dark
            return { dark: darkTheme, light: lightTheme }
        }
        return { dark: themeData, light: themeData }
    }

    function getPrimaryColorFromTheme(themeData) {
        if (!themeData) return "#42a5f5"
        if (themeData.primary) return themeData.primary
        if (themeData.dark && themeData.dark.primary) return themeData.dark.primary
        if (themeData.light && themeData.light.primary) return themeData.light.primary
        return "#42a5f5"
    }

    function seedSelectionFromCurrentTheme() {
        if (selectedColors.length > 0) return
        const activeTheme = root.customThemeData || (typeof Theme !== 'undefined' ? Theme.customThemeData : null)
        const primary = getPrimaryColorFromTheme(activeTheme)
        if (primary) {
            selectedColors = [primary]
            colorsChanged()
        }
    }
    
    function getTextColorForBackground(backgroundColor) {

        const brightness = getBrightness(backgroundColor)

        if (typeof SettingsData !== 'undefined' && SettingsData.extractedColorTextOverrideEnabled) {
            const hexR = Math.max(0, Math.min(255, SettingsData.extractedColorTextR)).toString(16).padStart(2, '0')
            const hexG = Math.max(0, Math.min(255, SettingsData.extractedColorTextG)).toString(16).padStart(2, '0')
            const hexB = Math.max(0, Math.min(255, SettingsData.extractedColorTextB)).toString(16).padStart(2, '0')
            return "#" + hexR + hexG + hexB
        }

        return brightness > 0.5 ? "#000000" : "#ffffff"
    }

    function generateThemeFromPrimaryColor(primaryColor, matugenType = "scheme-tonal-spot", isLightMode = false) {

        const getBrightness = (color) => {
            let r, g, b
            if (typeof color === 'string' && color.startsWith('#')) {
                r = parseInt(color.slice(1, 3), 16) / 255
                g = parseInt(color.slice(3, 5), 16) / 255
                b = parseInt(color.slice(5, 7), 16) / 255
            } else {
                r = color.r || 0
                g = color.g || 0
                b = color.b || 0
            }
            return (r * 0.299 + g * 0.587 + b * 0.114)
        }

        const getTextColorForBackground = (backgroundColor, isLightMode) => {

            if (typeof SettingsData !== 'undefined' && SettingsData.extractedColorTextOverrideEnabled) {
                const hexR = Math.max(0, Math.min(255, SettingsData.extractedColorTextR)).toString(16).padStart(2, '0')
                const hexG = Math.max(0, Math.min(255, SettingsData.extractedColorTextG)).toString(16).padStart(2, '0')
                const hexB = Math.max(0, Math.min(255, SettingsData.extractedColorTextB)).toString(16).padStart(2, '0')
                return "#" + hexR + hexG + hexB
            }

            const brightness = getBrightness(backgroundColor)
            return brightness > 0.5 ? "#000000" : "#ffffff"
        }

        const colorToHex = (color) => {
            if (typeof color === 'string') return color
            const r = Math.round((color.r || 0) * 255)
            const g = Math.round((color.g || 0) * 255)
            const b = Math.round((color.b || 0) * 255)
            return "#" + r.toString(16).padStart(2, '0') + g.toString(16).padStart(2, '0') + b.toString(16).padStart(2, '0')
        }

        const customTheme = {
            "name": "Custom Palette",
            "primary": primaryColor,
            "primaryText": getTextColorForBackground(primaryColor, isLightMode),
            "primaryContainer": isLightMode ? Qt.darker(primaryColor, 1.2) : Qt.lighter(primaryColor, 1.2),
            "primaryContainerText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 1.2) : Qt.lighter(primaryColor, 1.2)), isLightMode),

            "secondary": isLightMode ? Qt.darker(primaryColor, 1.4) : Qt.lighter(primaryColor, 1.4),
            "secondaryText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 1.4) : Qt.lighter(primaryColor, 1.4)), isLightMode),
            "secondaryContainer": isLightMode ? Qt.darker(primaryColor, 1.6) : Qt.lighter(primaryColor, 1.6),
            "secondaryContainerText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 1.6) : Qt.lighter(primaryColor, 1.6)), isLightMode),

            "tertiary": isLightMode ? Qt.darker(primaryColor, 1.8) : Qt.lighter(primaryColor, 1.8),
            "tertiaryText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 1.8) : Qt.lighter(primaryColor, 1.8)), isLightMode),
            "tertiaryContainer": isLightMode ? Qt.darker(primaryColor, 2.0) : Qt.lighter(primaryColor, 1.8),
            "tertiaryContainerText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 2.0) : Qt.lighter(primaryColor, 1.8)), isLightMode),

            "surface": isLightMode ? Qt.lighter(primaryColor, 3.0) : Qt.darker(primaryColor, 3.0),
            "surfaceText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 3.0) : Qt.darker(primaryColor, 3.0)), isLightMode),
            "surfaceVariant": isLightMode ? Qt.lighter(primaryColor, 2.5) : Qt.darker(primaryColor, 2.5),
            "surfaceVariantText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 2.5) : Qt.darker(primaryColor, 2.5)), isLightMode),
            "surfaceTint": primaryColor,
            "surfaceContainer": isLightMode ? Qt.lighter(primaryColor, 2.8) : Qt.darker(primaryColor, 2.8),
            "surfaceContainerText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 2.8) : Qt.darker(primaryColor, 2.8)), isLightMode),
            "surfaceContainerHigh": isLightMode ? Qt.lighter(primaryColor, 2.6) : Qt.darker(primaryColor, 2.6),
            "surfaceContainerHighText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 2.6) : Qt.darker(primaryColor, 2.6)), isLightMode),
            "surfaceContainerHighest": isLightMode ? Qt.lighter(primaryColor, 2.4) : Qt.darker(primaryColor, 2.4),
            "surfaceContainerHighestText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 2.4) : Qt.darker(primaryColor, 2.4)), isLightMode),

            "background": isLightMode ? Qt.lighter(primaryColor, 3.2) : Qt.darker(primaryColor, 3.2),
            "backgroundText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 3.2) : Qt.darker(primaryColor, 3.2)), isLightMode),

            "outline": isLightMode ? Qt.darker(primaryColor, 1.5) : Qt.lighter(primaryColor, 1.5),
            "outlineVariant": isLightMode ? Qt.darker(primaryColor, 2.2) : Qt.lighter(primaryColor, 2.2),

            "error": isLightMode ? "#B3261E" : "#F2B8B5",
            "errorText": isLightMode ? "#ffffff" : "#000000",
            "errorContainer": isLightMode ? "#FDEAEA" : "#8C1D18",
            "errorContainerText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter("#B3261E", 1.5) : Qt.darker("#F2B8B5", 1.5)), isLightMode),

            "warning": isLightMode ? "#F57C00" : "#FFB74D",
            "warningText": isLightMode ? "#ffffff" : "#000000",
            "warningContainer": isLightMode ? "#FFF3E0" : "#E65100",
            "warningContainerText": getTextColorForBackground(isLightMode ? "#FFF3E0" : "#E65100", isLightMode),

            "info": isLightMode ? "#1976D2" : "#64B5F6",
            "infoText": isLightMode ? "#ffffff" : "#000000",
            "infoContainer": isLightMode ? "#E3F2FD" : "#0D47A1",
            "infoContainerText": getTextColorForBackground(isLightMode ? "#E3F2FD" : "#0D47A1", isLightMode),

            "success": isLightMode ? "#2E7D32" : "#81C784",
            "successText": isLightMode ? "#ffffff" : "#000000",
            "successContainer": isLightMode ? "#E8F5E8" : "#1B5E20",
            "successContainerText": getTextColorForBackground(isLightMode ? "#E8F5E8" : "#1B5E20", isLightMode),

            "matugen_type": matugenType,
            "onSurface": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 3.0) : Qt.darker(primaryColor, 3.0)), isLightMode),
            "onSurfaceVariant": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 2.5) : Qt.darker(primaryColor, 2.5)), isLightMode),
            "onPrimary": getTextColorForBackground(primaryColor, isLightMode),
            "onSurface_12": "rgba(255,255,255,0.12)",
            "onSurface_38": "rgba(255,255,255,0.38)",
            "onSurfaceVariant_30": "rgba(255,255,255,0.30)",
            "primaryHover": isLightMode ? Qt.darker(primaryColor, 1.1) : Qt.lighter(primaryColor, 1.1),
            "primaryHoverLight": isLightMode ? Qt.darker(primaryColor, 1.05) : Qt.lighter(primaryColor, 1.05),
            "primaryPressed": isLightMode ? Qt.darker(primaryColor, 1.3) : Qt.lighter(primaryColor, 1.3),
            "primarySelected": isLightMode ? Qt.darker(primaryColor, 1.4) : Qt.lighter(primaryColor, 1.4),
            "primaryBackground": isLightMode ? Qt.darker(primaryColor, 1.8) : Qt.lighter(primaryColor, 1.8),
            "secondaryHover": isLightMode ? Qt.darker(primaryColor, 1.3) : Qt.lighter(primaryColor, 1.3),
            "surfaceHover": isLightMode ? Qt.darker(primaryColor, 1.1) : Qt.lighter(primaryColor, 1.1),
            "surfacePressed": isLightMode ? Qt.darker(primaryColor, 1.2) : Qt.lighter(primaryColor, 1.2),
            "surfaceSelected": isLightMode ? Qt.darker(primaryColor, 1.3) : Qt.lighter(primaryColor, 1.3),
            "surfaceLight": isLightMode ? Qt.darker(primaryColor, 1.05) : Qt.lighter(primaryColor, 1.05),
            "surfaceVariantAlpha": isLightMode ? Qt.darker(primaryColor, 1.2) : Qt.lighter(primaryColor, 1.2),
            "surfaceTextHover": isLightMode ? "rgba(0,0,0,0.08)" : "rgba(255,255,255,0.08)",
            "surfaceTextAlpha": isLightMode ? "rgba(0,0,0,0.3)" : "rgba(255,255,255,0.3)",
            "surfaceTextLight": isLightMode ? "rgba(0,0,0,0.06)" : "rgba(255,255,255,0.06)",
            "surfaceTextMedium": isLightMode ? "rgba(0,0,0,0.7)" : "rgba(255,255,255,0.7)",
            "outlineButton": isLightMode ? Qt.darker(primaryColor, 1.2) : Qt.lighter(primaryColor, 1.2),
            "outlineLight": isLightMode ? Qt.darker(primaryColor, 1.1) : Qt.lighter(primaryColor, 1.1),
            "outlineMedium": isLightMode ? Qt.darker(primaryColor, 1.15) : Qt.lighter(primaryColor, 1.15),
            "outlineStrong": isLightMode ? Qt.darker(primaryColor, 1.3) : Qt.lighter(primaryColor, 1.3),
            "errorHover": isLightMode ? Qt.darker("#B3261E", 1.1) : Qt.lighter("#F2B8B5", 1.1),
            "errorPressed": isLightMode ? Qt.darker("#B3261E", 1.3) : Qt.lighter("#F2B8B5", 1.3),
            "shadowMedium": "rgba(0,0,0,0.08)",
            "shadowStrong": "rgba(0,0,0,0.3)"
        }

        return customTheme
    }

    function applySelectedColors() {

        if (selectedColors.length === 0) {
            seedSelectionFromCurrentTheme()
            if (selectedColors.length === 0) {
                return
            }
        }
        
        const getBrightness = (color) => {
            let r, g, b
            if (typeof color === 'string' && color.startsWith('#')) {
                r = parseInt(color.slice(1, 3), 16) / 255
                g = parseInt(color.slice(3, 5), 16) / 255
                b = parseInt(color.slice(5, 7), 16) / 255
            } else {
                r = color.r || 0
                g = color.g || 0
                b = color.b || 0
            }
            return (r * 0.299 + g * 0.587 + b * 0.114)
        }
        
        const getTextColorForBackground = (backgroundColor, isLightMode) => {

            if (typeof SettingsData !== 'undefined' && SettingsData.extractedColorTextOverrideEnabled) {
                const hexR = Math.max(0, Math.min(255, SettingsData.extractedColorTextR)).toString(16).padStart(2, '0')
                const hexG = Math.max(0, Math.min(255, SettingsData.extractedColorTextG)).toString(16).padStart(2, '0')
                const hexB = Math.max(0, Math.min(255, SettingsData.extractedColorTextB)).toString(16).padStart(2, '0')
                return "#" + hexR + hexG + hexB
            }

            const brightness = getBrightness(backgroundColor)
            return brightness > 0.5 ? "#000000" : "#ffffff"
        }
        
        const colorToHex = (color) => {
            if (typeof color === 'string') return color
            const r = Math.round((color.r || 0) * 255)
            const g = Math.round((color.g || 0) * 255)
            const b = Math.round((color.b || 0) * 255)
            return "#" + r.toString(16).padStart(2, '0') + g.toString(16).padStart(2, '0') + b.toString(16).padStart(2, '0')
        }

        const adjustedSelection = selectedColors.map(c => applyHueAdjustments(c))
        
        const sortedColors = [...adjustedSelection].sort((a, b) => getBrightness(a) - getBrightness(b))
        
        const primaryColor = adjustedSelection[0] || applyHueAdjustments("#42a5f5")
        
        const isLightMode = typeof SessionData !== 'undefined' ? SessionData.isLightMode : false
        
        const customTheme = generateThemeFromPrimaryColor(primaryColor, "scheme-custom", isLightMode)
        

        if (typeof SettingsData !== 'undefined') {
            const hex = primaryColor.replace('#', '')
            const r = parseInt(hex.substr(0, 2), 16) / 255
            const g = parseInt(hex.substr(2, 2), 16) / 255
            const b = parseInt(hex.substr(4, 2), 16) / 255
            
            SettingsData.launcherLogoRed = r
            SettingsData.launcherLogoGreen = g
            SettingsData.launcherLogoBlue = b
            SettingsData.osLogoColorOverride = primaryColor
            
            SettingsData.saveSettings()
            
        }

        const normalizedCustomTheme = normalizeThemeData(customTheme)
        root.customThemeData = normalizedCustomTheme
        root.customThemeReady = true

        if (typeof Theme !== 'undefined') {
            
            Theme.switchTheme("custom", true, false)
            
            Theme.loadCustomTheme(normalizedCustomTheme)
            
            Theme.generateSystemThemesFromCurrentTheme()
            
            Theme.colorUpdateTrigger++
        } else {
        }

        customThemeCreated(customTheme)
    }

    Process {
        id: matugenProcess
        
        stdout: StdioCollector {
            onStreamFinished: {
                isExtracting = false
                if (text && text.trim()) {
                    try {
                        const jsonData = JSON.parse(text.trim())
                        const colors = extractColorsFromMatugen(jsonData)
                        extractedColors = colors
                        colorsExtracted()
                    } catch (e) {
                        extractedColors = []
                    }
                }
            }
        }
    }

    function extractColorsFromMatugen(jsonData) {
        const colors = []
        const toHexColor = (color) => {
            if (typeof color === "string") return color
            const r = Math.round((color.r || 0) * 255)
            const g = Math.round((color.g || 0) * 255)
            const b = Math.round((color.b || 0) * 255)
            return "#" + r.toString(16).padStart(2, "0") +
                         g.toString(16).padStart(2, "0") +
                         b.toString(16).padStart(2, "0")
        }
        const addColor = (c) => {
            const hex = toHexColor(c)
            if (hex && typeof hex === "string" && hex.startsWith("#")) {
                colors.push(hex)
            }
        }
        
        const isLightMode = typeof SessionData !== 'undefined' ? SessionData.isLightMode : false
        const currentMode = isLightMode ? 'light' : 'dark'
        
        
        if (jsonData.colors) {
            const colorKeys = [
                'primary',
                'secondary',
                'tertiary',
                'surface',
                'surface_variant',
                'outline',
                'surface_container',
                'surface_container_high',
                'surface_container_low',
                'surface_container_lowest',
                'surface_container_highest',
                'primary_container',
                'secondary_container',
                'tertiary_container',
                'primary_fixed',
                'primary_fixed_dim',
                'secondary_fixed',
                'secondary_fixed_dim',
                'tertiary_fixed',
                'tertiary_fixed_dim',
                'inverse_primary',
                'inverse_surface',
                'inverse_on_surface',
                'surface_dim',
                'surface_bright',
                'surface_tint'
            ]
            
            colorKeys.forEach(colorKey => {
                if (jsonData.colors[colorKey] && jsonData.colors[colorKey][currentMode]) {
                    addColor(jsonData.colors[colorKey][currentMode])
                }
            })
            
        } else {
        }
        

        let uniqueColors = [...new Set(colors)]
        
        if (uniqueColors.length < 16) {
            const baseColor = uniqueColors[0] || "#42a5f5"
            const multipliers = [1.05, 1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.4]
            for (let i = 0; i < multipliers.length && uniqueColors.length < 16; i++) {
                const lighter = toHexColor(Qt.lighter(baseColor, multipliers[i]))
                const darker = toHexColor(Qt.darker(baseColor, multipliers[i]))
                addColor(lighter)
                addColor(darker)
                uniqueColors = [...new Set(colors)]
                if (uniqueColors.length >= 16) break
            }
        }
        
        return uniqueColors.slice(0, 16)
    }

    function saveCustomThemeToFile(themeData, customName, customDisplayName) {
        try {
            const normalizedThemeData = normalizeThemeData(themeData)
            if (!normalizedThemeData) return false

            const primaryCandidate = getPrimaryColorFromTheme(normalizedThemeData)

            const baseName = (customName && typeof customName === "string" && customName.trim().length > 0)
                    ? customName.trim()
                    : primaryCandidate.replace('#', '').toLowerCase()

            const safeName = baseName
                    .replace(/[^a-zA-Z0-9_-]/g, "-")
                    .replace(/-+/g, "-")
                    .replace(/^-+|-+$/g, "")
                    .toLowerCase() || "custom-theme"

            const displayName = (customDisplayName && typeof customDisplayName === "string" && customDisplayName.trim().length > 0)
                    ? customDisplayName.trim()
                    : `#${primaryCandidate.replace('#', '').toUpperCase()}`

            // Extract essential data only - just the primary color and matugen type
            const essentialThemeData = {
                primary: primaryCandidate,
                matugen_type: normalizedThemeData.dark?.matugen_type || normalizedThemeData.light?.matugen_type || "scheme-tonal-spot"
            }

            const themeInfo = {
                name: safeName,
                displayName: displayName,
                primaryColor: primaryCandidate,
                themeData: essentialThemeData,  // Save only essential data
                version: 2  // Version marker for optimized themes
            }

            if (typeof SettingsData !== 'undefined') {
                let themes = SettingsData.savedColorThemes || []

                themes = themes.filter(t => t.name !== safeName)

                themes.push(themeInfo)

                SettingsData.setSavedColorThemes(themes)
                SettingsData.setCurrentColorTheme(safeName)
                SettingsData.saveTextColorPreset(safeName)

                updateAvailableThemes()
                root.customThemeData = normalizedThemeData
                return true
            } else {
                Qt.callLater(function() {
                    if (typeof SettingsData !== 'undefined') {
                        saveCustomThemeToFile(themeData, customName, customDisplayName)
                    }
                })
            }
        } catch (e) {
        }
        return false
    }

    function saveThemeWithName(themeName) {
        const data = root.customThemeData
                || (typeof Theme !== 'undefined' ? Theme.customThemeData : null)
        const normalized = normalizeThemeData(data)
        if (!normalized) {
            return false
        }
        return saveCustomThemeToFile(normalized, themeName, themeName)
    }

    function loadCustomThemeFromSettings() {
        try {
            
            if (typeof SettingsData !== 'undefined') {
                
                if (SettingsData.currentColorTheme) {
                    const currentTheme = SettingsData.currentColorTheme
                    
                    const themes = SettingsData.savedColorThemes || []
                    
                    const theme = themes.find(t => t.name === currentTheme)
                    
                    if (theme) {
                        const normalized = normalizeThemeData(theme.themeData)
                        if (!normalized) return null
                        
                        if (typeof Theme !== 'undefined') {
                            root.customThemeData = normalized
                            Theme.customThemeData = normalized
                            Theme.switchTheme("custom", true, false)
                            Theme.loadCustomTheme(normalized)
                            Theme.generateSystemThemesFromCurrentTheme()
                            
                            if (typeof SettingsData !== 'undefined') {
                                const primaryColor = getPrimaryColorFromTheme(normalized)
                                const hex = primaryColor.replace('#', '')
                                const r = parseInt(hex.substr(0, 2), 16) / 255
                                const g = parseInt(hex.substr(2, 2), 16) / 255
                                const b = parseInt(hex.substr(4, 2), 16) / 255
                                
                                SettingsData.launcherLogoRed = r
                                SettingsData.launcherLogoGreen = g
                                SettingsData.launcherLogoBlue = b
                                SettingsData.osLogoColorOverride = primaryColor
                                

                                SettingsData.loadTextColorFromTheme(currentTheme)
                            }
                        } else {
                        }
                        
                        return normalized
                    } else {
                    }
                } else {
                }
            } else {
            }
        } catch (e) {
        }
        return null
    }

    function updateCurrentThemeTextColors() {

        if (typeof SettingsData === 'undefined') return
        
        const hexR = Math.max(0, Math.min(255, SettingsData.extractedColorTextR)).toString(16).padStart(2, '0')
        const hexG = Math.max(0, Math.min(255, SettingsData.extractedColorTextG)).toString(16).padStart(2, '0')
        const hexB = Math.max(0, Math.min(255, SettingsData.extractedColorTextB)).toString(16).padStart(2, '0')
        const overrideTextColor = "#" + hexR + hexG + hexB
        

        const textColorProperties = [
            "primaryText", "primaryContainerText", "secondaryText", "secondaryContainerText",
            "tertiaryText", "tertiaryContainerText", "surfaceText", "surfaceVariantText",
            "surfaceContainerText", "surfaceContainerHighText", "surfaceContainerHighestText",
            "backgroundText", "errorContainerText", "warningContainerText", "infoContainerText",
            "successContainerText", "onSurface", "onSurfaceVariant", "onPrimary"
        ]
        

        if (SettingsData.currentColorTheme) {
            const currentTheme = SettingsData.currentColorTheme
            const themes = SettingsData.savedColorThemes || []
            const theme = themes.find(t => t.name === currentTheme)
            
            if (theme && theme.themeData) {

                if (theme.themeData.dark || theme.themeData.light) {

                    if (theme.themeData.dark) {
                        for (const prop of textColorProperties) {
                            if (theme.themeData.dark[prop] !== undefined) {
                                theme.themeData.dark[prop] = overrideTextColor
                            }
                        }
                    }
                    if (theme.themeData.light) {
                        for (const prop of textColorProperties) {
                            if (theme.themeData.light[prop] !== undefined) {
                                theme.themeData.light[prop] = overrideTextColor
                            }
                        }
                    }
                } else {

                    for (const prop of textColorProperties) {
                        if (theme.themeData[prop] !== undefined) {
                            theme.themeData[prop] = overrideTextColor
                        }
                    }
                }
                

                SettingsData.setSavedColorThemes(themes)
            }
        }
        

        if (typeof Theme !== 'undefined' && Theme.currentTheme === "custom" && Theme.customThemeData) {

            const currentThemeData = Theme.customThemeData
            

            for (const prop of textColorProperties) {
                if (currentThemeData[prop] !== undefined) {
                    currentThemeData[prop] = overrideTextColor
                }
            }
            

            Theme.customThemeData = currentThemeData
            

            Theme.generateSystemThemesFromCurrentTheme()
            if (Theme.colorUpdateTrigger !== undefined) {
                Theme.colorUpdateTrigger++
            }
        }
    }

    function updateAvailableThemes() {
        try {
            if (typeof SettingsData !== 'undefined') {
                const themes = SettingsData.savedColorThemes || []
                availableThemes = themes
                themesUpdated()
            } else {
                availableThemes = []
                themesUpdated()
            }
        } catch (e) {
            availableThemes = []
            themesUpdated()
        }
    }

    function loadThemeByName(themeName) {
        const theme = availableThemes.find(t => t.name === themeName)
        if (theme) {
            let normalized

            // Check if this is a version 2 (optimized) theme
            if (theme.version === 2) {
                // Reconstruct full theme data from essential data
                const isLightMode = typeof SessionData !== 'undefined' ? SessionData.isLightMode : false
                const essentialData = theme.themeData

                // Generate full theme from primary color
                const fullThemeData = generateThemeFromPrimaryColor(essentialData.primary, essentialData.matugen_type, isLightMode)
                normalized = normalizeThemeData(fullThemeData)
            } else {
                // Legacy theme with full data
                normalized = normalizeThemeData(theme.themeData)
            }

            if (!normalized) return false

            if (typeof SettingsData !== 'undefined') {
                SettingsData.setCurrentColorTheme(themeName)

                SettingsData.loadTextColorFromTheme(themeName)
            }

            if (typeof Theme !== 'undefined') {
                root.customThemeData = normalized
                Theme.customThemeData = normalized
                Theme.switchTheme("custom", true, false)
                Theme.loadCustomTheme(normalized)
                Theme.generateSystemThemesFromCurrentTheme()
            }

            if (typeof SettingsData !== 'undefined') {
                const primaryColor = theme.version === 2 ? theme.themeData.primary : theme.themeData.primary
                const hex = primaryColor.replace('#', '')
                const r = parseInt(hex.substr(0, 2), 16) / 255
                const g = parseInt(hex.substr(2, 2), 16) / 255
                const b = parseInt(hex.substr(4, 2), 16) / 255

                SettingsData.launcherLogoRed = r
                SettingsData.launcherLogoGreen = g
                SettingsData.launcherLogoBlue = b
                SettingsData.osLogoColorOverride = primaryColor
                SettingsData.saveSettings()
            }

            return true
        }
        return false
    }

    function deleteTheme(themeName) {
        if (typeof SettingsData !== 'undefined') {
            try {
                let themes = SettingsData.savedColorThemes || []
                themes = themes.filter(t => t.name !== themeName)
                SettingsData.setSavedColorThemes(themes)
                
                if (SettingsData.currentColorTheme === themeName) {
                    SettingsData.setCurrentColorTheme("")
                }
                
                updateAvailableThemes()
                return true
            } catch (e) {
            }
        }
        return false
    }

    Timer {
        id: initTimer
        interval: 200
        repeat: true
        running: true
        onTriggered: {
            if (typeof SettingsData !== 'undefined' && SettingsData.savedColorThemes !== undefined) {
                running = false
                loadCustomThemeFromSettings()
                updateAvailableThemes()
            } else {
            }
        }
    }

    Component.onCompleted: {
        
        if (typeof SettingsData !== 'undefined' && SettingsData.savedColorThemes !== undefined) {
            loadCustomThemeFromSettings()
            updateAvailableThemes()
        }
        
        if (typeof Theme !== 'undefined' && Theme.wallpaperPath) {
            extractColorsFromWallpaper(Theme.wallpaperPath)
        }
        
        if (typeof SessionData !== 'undefined' && typeof SessionData.lightModeChanged !== 'undefined') {
            SessionData.lightModeChanged.connect(function() {
                if (typeof Theme !== 'undefined' && Theme.wallpaperPath) {
                    extractColorsFromWallpaper(Theme.wallpaperPath)
                }
            })
        }
    }

    IpcHandler {
        target: "colorpalette"

        function extract(wallpaperPath: string): string {
            extractColorsFromWallpaper(wallpaperPath)
            return "SUCCESS: Color extraction started"
        }

        function getcolors(): string {
            return JSON.stringify(extractedColors)
        }

        function select(color: string, selected: bool): string {
            selectColor(color, selected)
            return "SUCCESS: Color selection updated"
        }

        function apply(): string {
            applySelectedColors()
            return "SUCCESS: Selected colors applied to theme"
        }
    }
}
