#!/bin/bash

RED='\033[1;31m'        # ${RED}
YELLOW='\033[1;33m'    # ${YELLOW}
GREEN='\033[1;32m'    # ${GREEN}
NC='\033[0m'         # ${NC}


# Function to check and enable multilib repository
enable_multilib() {
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo "Enabling multilib repository..."
        sudo tee -a /etc/pacman.conf > /dev/null <<EOT

[multilib]
Include = /etc/pacman.d/mirrorlist
EOT
        echo "Multilib repository has been enabled."
    else
        echo "Multilib repository is already enabled."
    fi
}

# Function to install yay
install_yay() {
    if ! command -v yay &> /dev/null; then
        echo "Installing yay..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay-bin.git
        cd yay-bin || exit
        makepkg -si --noconfirm
        cd .. && rm -rf yay-bin
        export PATH="$PATH:$HOME/.local/bin"
    else
        echo "yay is already installed."
    fi
}

# Function to install KDE and KDE software
install_kde() {
    echo "Installing KDE Plasma and applications..."
    sudo pacman -S --needed --noconfirm xorg sddm
    sudo systemctl enable sddm

    sudo pacman -S --noconfirm plasma-desktop dolphin konsole systemsettings plasma-pa plasma-nm kscreen kde-gtk-config breeze-gtk powerdevil sddm-kcm kwalletmanager \
        kio-admin bluedevil

    sudo systemctl enable NetworkManager
}

# Main program
echo -e "${YELLOW}This script will configure your system for gaming and install software.${NC}"
echo -e "${YELLOW}Please make sure you have a backup of your important data.${NC}"
echo -e  "${YELLOW}Do you want to proceed? (y/n)${NC}"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation aborted.${NC}"
    exit 1
fi

# Ask for sudo rights
sudo -v

# Keep sudo rights
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

enable_multilib
sudo pacman -Syyu --noconfirm
install_yay

# desktop environment
install_kde

# Enable TRIM for SSDs
sudo systemctl enable fstrim.timer

echo -e "${YELLOW}Process completed.${NC}"

        sudo rm -R /var/lib/pacman/sync
        sudo pacman -Syy
        sudo pacman -Syu
# Ask about restart
echo -e "${GREEN}Script completed succesfully. Do you want to restart your system to apply all changes now?(y/n)${NC}"
read -r restart_response
if [[ "$restart_response" =~ ^[Yy]$ ]]; then
    sudo reboot now
else
    echo -e "${RED}No restart selected${NC}"
fi