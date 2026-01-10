#!/bin/bash

# Modern screenshot menu for Hyprland
# Shows a fancy dark mode menu to select which monitor to capture

# Get monitor information with sleek modern formatting
MONITORS=$(hyprctl monitors -j | jq -r '.[] | "🖥️  Monitor \(.id)  ·  \(.description | split(" ")[0:2] | join(" "))  ·  \(.width)×\(.height)@\(.refreshRate)Hz"')

# Show ultra-modern dark-themed menu with enhanced styling
SELECTED=$(echo "$MONITORS" | fuzzel --dmenu --prompt "📸 Capture Monitor: " --lines 6)

# Exit if no selection
[ -z "$SELECTED" ] && exit 1

# Extract monitor ID from selection (format: "🖥️  Monitor X - ...")
MONITOR_ID=$(echo "$SELECTED" | sed -n 's/🖥️  Monitor \([0-9]\+\).*/\1/p')

# Get output name for grim
OUTPUT_NAME=$(hyprctl monitors -j | jq -r ".[] | select(.id == $MONITOR_ID) | .name")

# Take screenshot based on arguments
if [ "$1" = "--file" ]; then
    # Save to file
    mkdir -p ~/Pictures/Screenshots
    FILENAME="Screenshot_Monitor${MONITOR_ID}_$(date '+%Y-%m-%d_%H-%M-%S').png"
    grim -o "$OUTPUT_NAME" ~/Pictures/Screenshots/"$FILENAME"
    notify-send -i screenshot "Screenshot saved" "$FILENAME"
else
    # Copy to clipboard
    grim -o "$OUTPUT_NAME" - | wl-copy
    notify-send -i screenshot "Screenshot taken" "Monitor $MONITOR_ID copied to clipboard"
fi