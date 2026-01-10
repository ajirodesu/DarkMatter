#!/bin/bash

BORDER_SIZE="$1"
CONFIG_FILE="$HOME/.config/hypr/hyprland/colors.conf"

if [ -z "$BORDER_SIZE" ]; then
    echo "Usage: $0 <border_size>"
    exit 1
fi

sed -i "s/border_size = [0-9]\+/border_size = $BORDER_SIZE/" "$CONFIG_FILE"

hyprctl reload >/dev/null 2>&1 || true

echo "Updated Hyprland border size to ${BORDER_SIZE}px"