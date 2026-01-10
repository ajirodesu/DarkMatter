#!/bin/bash

# PikaOS Package Installation Script
# Converted from Fedora package installation script
# Maps Fedora packages to their Debian/Ubuntu/PikaOS equivalents

# Don't exit on error immediately - we'll handle errors manually
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting PikaOS package installation...${NC}\n"

# Check if running as root, if not re-execute with sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}This script requires sudo privileges. Requesting sudo access...${NC}"
    exec sudo "$0" "$@"
fi

# Update system first
echo -e "${YELLOW}Updating system...${NC}"
run_apt apt update -y
run_apt apt upgrade -y

# Prevent gdm from being installed as a recommended dependency
echo -e "${YELLOW}Configuring apt to avoid installing gdm...${NC}"
run_apt apt-mark hold gdm gdm3 2>/dev/null || true

# Note: PikaOS uses its own PPA (ppa.pika-os.com) which should already be configured
# If you need additional repositories, add them here
# For example, if hyprpicker or other packages need additional repos:
# echo -e "\n${YELLOW}Adding additional repositories if needed...${NC}"
# add-apt-repository -y ppa:some/repo  # Uncomment and modify as needed

# Note: gdm (GNOME Display Manager) is intentionally not installed
# Hyprland works with other display managers or can be started directly

# Update package cache after adding repositories
echo -e "\n${YELLOW}Updating package cache...${NC}"
run_apt apt update

# NVIDIA drivers (optional - uncomment if needed)
# echo -e "\n${YELLOW}Installing NVIDIA drivers...${NC}"
# apt install -y nvidia-driver-535  # Adjust version as needed
# apt install -y nvidia-cuda-toolkit  # Optional for cuda/nvdec/nvenc support

# Development tools and dependencies
echo -e "\n${YELLOW}Installing development tools and dependencies...${NC}"
wait_for_apt
run_apt apt install -y --no-install-recommends \
    rustc cargo \
    gcc g++ pkg-config \
    libssl-dev \
    libx11-dev libxcursor-dev libxrandr-dev libxi-dev \
    libgl1-mesa-dev \
    libfontconfig-dev libfreetype-dev libexpat1-dev \
    curl unzip fontconfig \
    libcairo2-dev \
    libgtk-4-dev \
    libgtk-layer-shell-dev \
    qtbase5-dev \
    qt6-base-dev \
    python3-pyqt6 \
    python3 python3-dev \
    libcurl4-openssl-dev \
    fuse libfuse2t64 \
    mate-polkit-bin \
    zenity \
    golang-go make python-pip

# Desktop environment and window manager
echo -e "\n${YELLOW}Installing desktop environment components...${NC}"
wait_for_apt
run_apt apt install -y --no-install-recommends \
    hyprland \
    swww \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-wlr \
    xdg-desktop-portal-gnome \
    gnome-keyring

# Note: hyprpicker and hyprpolkitagent may need to be built from source
# or installed from additional repositories
echo -e "\n${YELLOW}Checking for hyprpicker and hyprpolkitagent...${NC}"
if apt-cache show hyprpicker >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends hyprpicker
else
    echo -e "${YELLOW}hyprpicker not found in repos - may need to build from source${NC}"
    echo -e "${YELLOW}See: https://github.com/hyprwm/hyprpicker${NC}"
fi

if apt-cache show hyprpolkitagent >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends hyprpolkitagent
else
    echo -e "${YELLOW}hyprpolkitagent not found in repos - may need to build from source${NC}"
    echo -e "${YELLOW}See: https://github.com/hyprwm/hypridle${NC}"
fi

# System utilities
echo -e "\n${YELLOW}Installing system utilities...${NC}"
wait_for_apt
run_apt apt install -y --no-install-recommends \
    brightnessctl \
    cliphist \
    easyeffects \
    fuzzel \
    gnome-system-monitor \
    gnome-text-editor \
    grim \
    nautilus \
    pavucontrol \
    ptyxis \
    slurp \
    swappy \
    tesseract-ocr \
    wl-clipboard \
    wlogout \
    yad \
    btop \
    lm-sensors \
    gedit

# Applications
echo -e "\n${YELLOW}Installing applications...${NC}"
wait_for_apt
run_apt apt install -y --no-install-recommends \
    firefox \
    obs-studio \
    steam \
    lutris \
    mangohud \
    gamescope

# GUI tools
echo -e "\n${YELLOW}Installing GUI tools...${NC}"
wait_for_apt
run_apt apt install -y --no-install-recommends \
    qt6ct \
    nwg-look

# Quickshell
echo -e "\n${YELLOW}Installing Quickshell...${NC}"
if apt-cache show quickshell-git >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends quickshell-git
elif apt-cache show quickshell >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends quickshell
else
    echo -e "${YELLOW}quickshell not found in repos - may need to build from source${NC}"
    echo -e "${YELLOW}See: https://github.com/Quickshell/quickshell${NC}"
fi

# Additional packages that may be needed
echo -e "\n${YELLOW}Installing additional dependencies...${NC}"
# Note: apr and libxcrypt-compat may not be needed or may have different names
# These are optional dependencies that were in the Fedora script

# Qt5 graphical effects (may be in different package)
if apt-cache show qt5-graphicaleffects >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends qt5-graphicaleffects
elif apt-cache show qml-module-qtquick-controls >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends qml-module-qtquick-controls
else
    echo -e "${YELLOW}Qt5 graphical effects package not found - may not be needed${NC}"
fi

# Qt6 Qt5Compat (may be in different package)
if apt-cache show qt6-qt5compat >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends qt6-qt5compat
elif apt-cache show qml6-module-qt5compat >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends qml6-module-qt5compat
else
    echo -e "${YELLOW}Qt6 Qt5Compat package not found - may not be needed${NC}"
fi

# dgop (build from source)
echo -e "\n${YELLOW}Building and installing dgop...${NC}"
# Note: golang-go, git, and make are already installed in the development tools section above
cd /tmp
git clone https://github.com/AvengeMedia/dgop.git
cd dgop
make
make install
cd .. && rm -rf dgop
cd ~
echo -e "${GREEN}dgop installed successfully!${NC}"
echo -e "${YELLOW}Note: For NVIDIA GPU temperature monitoring, install nvidia-utils (optional): sudo apt install -y nvidia-utils${NC}"

# matugen (install via cargo)
echo -e "\n${YELLOW}Installing matugen via cargo...${NC}"
if ! command -v matugen &> /dev/null; then
    cargo install matugen
    echo -e "${GREEN}matugen installed successfully!${NC}"
else
    echo -e "${GREEN}matugen is already installed!${NC}"
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}Note: You may need to reboot if you installed NVIDIA drivers or kernel packages.${NC}"
echo -e "${YELLOW}Some packages (hyprpicker, hyprpolkitagent) may need to be built from source if not available in repos.${NC}"

