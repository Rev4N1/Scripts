#!/bin/bash
#
# Script to set up an Ubuntu / Pop!_OS 20.04 LTS distro for gaming
#
# Sudo access is mandatory to run this script
#
#
# Usage:
#	./gaming-setup.sh
#

# Go to home dir
orig_dir=$(pwd)
cd $HOME

clear
echo -e "\nEnabling 32-bit architecture...\n"
sudo dpkg --add-architecture i386

clear
# Install Standard Toolchain
# https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/linux-setup.html
echo -e "\nInstalling and updating packages...\n"
sudo apt update -qq
sudo apt full-upgrade -y -qq
sudo apt install -y -qq git wget flex bison gperf python3 python3-pip \
                        python3-setuptools cmake ninja-build ccache \
                        libffi-dev libssl-dev dfu-util libusb-1.0-0 \
sudo apt purge -y -qq snapd
sudo apt autoremove -y -qq

clear
# Install GPU Drivers
# https://github.com/lutris/docs/blob/master/InstallingDrivers.md
echo -e "\n[1] AMD\n[2] Nvidia\n[3] Intel"
read -p "Select GPU Driver to Install [1/2/3] -> " -n 1 -r
echo
if [[ $REPLY == 1 ]]
then
  echo -e "\nInstalling AMD Driver support for 32-bit games and support for Vulkan API...\n"
  sudo add-apt-repository ppa:kisak/kisak-mesa -y
  sudo apt update -qq && sudo apt upgrade -y -qq
  sudo apt install -y -qq libgl1-mesa-dri:i386
  sudo apt install -y -qq mesa-vulkan-drivers mesa-vulkan-drivers:i386
  git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
  cd linux-firmware
  sudo cp -va amdgpu/ /lib/firmware/
  sudo update-initramfs -u
  cd ..
  sudo rm -r linux-firmware
elif [[ $REPLY == 2 ]]
then
  echo -e "\nInstalling Nvidia Driver and support for Vulkan API...\n"
  sudo add-apt-repository ppa:graphics-drivers/ppa -y
  sudo apt update -qq && sudo apt upgrade -y -qq
  sudo apt install -y -qq nvidia-driver-495
  sudo apt install -y -qq libvulkan1 libvulkan1:i386
elif [[ $REPLY == 3 ]]
then
  echo -e "\nInstalling Intel Driver support for 32-bit games and support for Vulkan API...\n"
  sudo add-apt-repository ppa:kisak/kisak-mesa -y
  sudo apt update -qq && sudo apt upgrade -y -qq
  sudo apt install -y -qq libgl1-mesa-dri:i386
  sudo apt install -y -qq mesa-vulkan-drivers mesa-vulkan-drivers:i386
  git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
  cd linux-firmware
  sudo cp -va i915/ /lib/firmware/
  sudo update-initramfs -u
  cd ..
  sudo rm -r linux-firmware
  sudo chown -R $USER:$USER /etc/sysctl.d
  echo dev.i915.perf_stream_paranoid=0 > /etc/sysctl.d/60-mdapi.conf
  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"$/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i915.enable_rc6=0"/g' /etc/default/grub
  sudo update-grub
fi

clear
# Install Wine and Dependencies
# https://github.com/lutris/docs/blob/master/WineDependencies.md
echo -e "\nInstalling Wine and WineTricks...\n"
sudo apt install -y -qq wine64 wine32 libasound2-plugins:i386 libsdl2-2.0-0:i386 libdbus-1-3:i386 libsqlite3-0:i386
sudo apt install -y -qq winetricks

clear
# Install Gamemode and Dependencies
# https://github.com/FeralInteractive/gamemode#install-dependencies
echo -e "\nInstalling Gamemode...\n"
sudo apt install -y -qq meson libsystemd-dev pkg-config ninja-build git libdbus-1-dev libinih-dev build-essential dbus-user-session
git clone https://github.com/FeralInteractive/gamemode.git
cd gamemode
git checkout 1.6.1
yes | ./bootstrap.sh
cd ..
sudo rm -r gamemode

clear
# Install Lutris
# https://lutris.net/downloads/
echo -e "\nInstalling Lutris...\n"
sudo add-apt-repository ppa:lutris-team/lutris -y
sudo apt update -qq && sudo apt upgrade -y -qq
sudo apt install -y -qq lutris

clear
echo -e "\nInstalling Steam...\n"
sudo apt install -y -qq steam
steam

clear
echo -e "\nInstalling Proton-GE...\n"
wget https://raw.githubusercontent.com/flubberding/ProtonUpdater/master/cproton.sh
sudo chmod +x cproton.sh
sudo sed -i 's/^restartSteam=2$/restartSteam=1/g' cproton.sh
sudo sed -i 's/^autoInstall=false$/autoInstall=true/g' cproton.sh
./cproton.sh
rm -r cproton.sh

clear
# Install Custom Kernel
# https://liquorix.net/#install
# https://xanmod.org/
echo -e "\n[1] Liquorix Kernel\n[2] Xanmod Kernel\n[3] Mainline Linux Kernel"
read -p "Select Custom Kernel to Install [1/2/3] -> " -n 1 -r
echo
if [[ $REPLY == 1 ]]
then
  echo -e "\nInstalling Liquorix Kernel...\n"
  sudo add-apt-repository ppa:damentz/liquorix -y
  sudo apt update -qq && sudo apt upgrade -y -qq
  sudo apt install -y -qq linux-image-liquorix-amd64 linux-headers-liquorix-amd64
elif [[ $REPLY == 2 ]]
then
  echo -e "\nInstalling Xanmod Kernel...\n"
  echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
  wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -
  sudo apt update -qq && sudo apt upgrade -y -qq
  sudo apt -y -qq install linux-xanmod
elif [[ $REPLY == 3 ]]
then
  echo -e "\nInstalling Mainline Linux Kernel...\n"
  mkdir kernel
  cd kernel
  wget -O linux-headers-all.deb "https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.15.8/amd64/linux-headers-5.15.8-051508_5.15.8-051508.202112141040_all.deb"
  wget -O linux-image-unsigned-generic.deb "https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.15.8/amd64/linux-image-unsigned-5.15.8-051508-generic_5.15.8-051508.202112141040_amd64.deb"
  wget -O linux-modules-generic.deb "https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.15.8/amd64/linux-modules-5.15.8-051508-generic_5.15.8-051508.202112141040_amd64.deb"
  sudo dpkg -i *.deb
  cd ..
  sudo rm -r kernel
fi

clear
echo -e "\nFixing Audio Device automatically switches to USB...\n"
sudo sed -i 's/^load-module module-switch-on-connect$/# load-module module-switch-on-connect/g' /etc/pulse/default.pa && pulseaudio -k

clear
echo
read -p "Install GNOME Tweaks? [Y/N] -> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo -e "\nInstalling GNOME Tweaks...\n"
  sudo apt -y -qq install gnome-tweaks
fi

clear
echo
read -p "Install Google Chrome? [Y/N] -> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo -e "\nInstalling Google Chrome...\n"
  wget -O chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  sudo dpkg -i chrome.deb
  rm -r chrome.deb
fi

clear
echo
read -p "Install Discord? [Y/N] -> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo -e "\nInstalling Discord...\n"
  wget -O discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
  sudo dpkg -i discord.deb
  rm -r discord.deb
fi

clear
echo
read -p "Install Spotify? [Y/N] -> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo -e "\nInstalling Spotify...\n"
  wget -O spotify.deb "https://repository-origin.spotify.com/pool/non-free/s/spotify-client/spotify-client_1.1.72.439.gc253025e_amd64.deb"
  sudo dpkg -i spotify.deb
  rm -r spotify.deb
fi

clear
echo
read -p "Install VLC Media Player? [Y/N] -> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo -e "\nInstalling VLC Media Player...\n"
  sudo apt -y -qq install libavcodec-extra libdvd-pkg && sudo dpkg-reconfigure libdvd-pkg
  sudo apt -y -qq install vlc
fi

clear
echo
read -p "Install OBS Studio? [Y/N] -> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo -e "\nInstalling OBS Studio...\n"
  sudo apt -y -qq install obs-studio
fi

clear
sudo apt autoremove -y -qq
sudo apt --purge autoremove -y -qq
sudo apt -y -qq --fix-broken install
echo -e "Done.\n"

clear
# Done!
echo -e "To enable Proton for all games:"
echo -e "Navigate to Steam / Settings / Steam Play / Advanced and tick the Enable Steam Play for all other titles.\n"
echo -e "To enable Gamemode for a game:"
echo -e "Click on the Properties of a game, navigate to SET LAUNCH OPTIONS and type in gamemoderun %command%.\n"
echo -e "ALL DONE. Now go and play games!"
echo -e "Please restart the PC for changes to take effect."

# ONLY AMD
# sudo nano /etc/environment
# add line " RADV_PERFTEST=aco "
#
# Enabling glthread
# Run the game from terminal with an environmental variable set:
# mesa_glthread=true /path/to/your/game/executable
# In steam, you can go into Properties -> Set Launch Options and use
# mesa_glthread=true %command%

# Go back to original dir
cd "$orig_dir"
