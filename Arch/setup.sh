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

install_amd() {
    echo "Installing AMD GPU drivers and tools"
    # Install AMD drivers and tools
    sudo pacman -S --noconfirm mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader libva-mesa-driver
    }

install_nvidia() {
    echo "Installing Nvidia GPU drivers"
    # Install Nvidia drivers and tools
    sudo pacman -S --noconfirm nvidia nvidia-utils lib32-nvidia-utils nvidia-settings opencl-nvidia libva-nvidia-driver
}

# Main installation
main_installation() {
    echo "Starting the main installation. This may take some time."

    # Enable TRIM for SSDs
    sudo systemctl enable fstrim.timer

    # Install bluetooth packages
    sudo pacman -S --noconfirm bluez bluez-utils
    sudo systemctl enable bluetooth.service

    # Install alsa package
    sudo pacman -S --noconfirm alsa-utils

    # CPU Power Management
    sudo pacman -S --noconfirm power-profiles-daemon
    sudo systemctl enable power-profiles-daemon

    # PowerTop
    sudo pacman -S --noconfirm powertop
    echo -e "[Unit]\nDescription=Powertop tunings\n\n[Service]\nType=oneshot\nRemainAfterExit=yes\nExecStart=/usr/bin/powertop --auto-tune\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/powertop.service &>/dev/null
    sudo systemctl enable powertop.service

    echo "Main installation completed."
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

# Ask about AMD installation
echo -e "${YELLOW}Do you want to install AMD GPU drivers? (y/n)${NC}"
read -r amd_response
if [[ "$amd_response" =~ ^[Yy]$ ]]; then
    install_amd
else
    echo -e "${RED}AMD GPU installation skipped.${NC}"
fi

# Ask about Nvidia installation
echo -e "${YELLOW}Do you want to install Nvidia GPU drivers? (y/n)${NC}"
read -r nvidia_response
if [[ "$nvidia_response" =~ ^[Yy]$ ]]; then
    install_nvidia
else
    echo -e "${RED}Nvidia GPU installation skipped.${NC}"
fi

# Ask about Main installation
echo -e "${YELLOW}Do you want to start the main installation for laptop software? (y/n)${NC}"
read -r main_response
if [[ "$main_response" =~ ^[Yy]$ ]]; then
    main_installation
else
    echo -e "${RED}Main installation skipped.${NC}"
fi

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
