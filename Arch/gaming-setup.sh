#!/bin/bash
#
# Script to set up an Arch / Manjaro distro for gaming
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
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

clear
# Install Standard Toolchain
# https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/linux-setup.html
echo -e "\nInstalling and updating packages...\n"
yay -Syu --noconfirm
sudo pacman -Syu
sudo pacman -Syyuu
sudo pacman -S --noconfirm --needed gcc git make flex bison gperf python-pip cmake \
									ninja ccache dfu-util libusb
sudo pacman -Sc --noconfirm
sudo pacman -Scc --noconfirm
sudo rm -rf ~/.cache/*
sudo pacman -Qtdq --noconfirm
sudo pacman -Rns --noconfirm $(pacman -Qtdq)
yay -Scc --noconfirm

clear
# Install GPU Drivers
# https://github.com/lutris/docs/blob/master/InstallingDrivers.md
echo -e "\n[1] AMD\n[2] Nvidia\n[3] Intel"
read -p "Select GPU Driver to Install [1/2/3] -> " -n 1 -r
echo
if [[ $REPLY == 1 ]]
then
  echo -e "\nInstalling AMD Driver support for 32-bit games and support for Vulkan API...\n"
  sudo pacman -S --noconfirm --needed lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
  git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
  cd linux-firmware
  sudo cp -va amdgpu/ /lib/firmware/
  sudo update-initramfs -u
  cd ..
  sudo rm -r linux-firmware
elif [[ $REPLY == 2 ]]
then
  echo -e "\nInstalling Nvidia Driver and support for Vulkan API...\n"
  sudo pacman -S --noconfirm --needed nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
elif [[ $REPLY == 3 ]]
then
  echo -e "\nInstalling Intel Driver support for 32-bit games and support for Vulkan API...\n"
  sudo pacman -S --noconfirm --needed lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
  git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
  cd linux-firmware
  sudo cp -va i915/ /lib/firmware/
  sudo update-initramfs -u
  cd ..
  sudo rm -r linux-firmware
  sudo chown -R $USER /etc/sysctl.d
  echo dev.i915.perf_stream_paranoid=0 > /etc/sysctl.d/60-mdapi.conf
  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"$/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet i915.enable_rc6=0"/g' /etc/default/grub
fi

clear
# Install Wine and Dependencies
# https://github.com/lutris/docs/blob/master/WineDependencies.md
echo -e "\nInstalling Wine and WineTricks...\n"
sudo pacman -S --noconfirm --needed wine wine-mono wine-gecko
sudo pacman -S --noconfirm winetricks

clear
# Install Gamemode and Dependencies
echo -e "\nInstalling Gamemode...\n"
yay -S --noconfirm gamemode lib32-gamemode

clear
# Install Lutris
echo -e "\nInstalling Lutris...\n"
sudo pacman -S --noconfirm lutris

clear
echo -e "\nInstalling Steam...\n"
sudo pacman -S --noconfirm steam
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
echo -e "\nInstalling Linux-TKG Kernel...\n"
git clone https://github.com/graysky2/modprobed-db
cd modprobed-db
make
sudo make install
modprobed-db 
modprobed-db store
cd ..
rm -fr modprobed-db
git clone https://github.com/Frogging-Family/linux-tkg
cd linux-tkg
sudo sed -i 's/^_distro=""$/_distro="Arch"/g' customization.cfg
sudo sed -i 's/^_cpusched=""$/_cpusched="pds"/g' customization.cfg
sudo sed -i 's/^_compiler=""$/ _compiler="gcc"/g' customization.cfg
sudo sed -i 's/^_processor_opt=""$/_processor_opt="generic"/g' customization.cfg
sudo sed -i 's/^_sched_yield_type=""$/_sched_yield_type="0"/g' customization.cfg
sudo sed -i 's/^_rr_interval=""$/_rr_interval="2"/g' customization.cfg
sudo sed -i 's/^_timer_freq=""$/_timer_freq="500"/g' customization.cfg
sudo sed -i 's/^_tickless=""$/_tickless="2"/g' customization.cfg
sudo sed -i 's/^_acs_override=""$/_acs_override="false"/g' customization.cfg
sudo sed -i 's/^_bcachefs=""$/_bcachefs="false"/g' customization.cfg
sudo sed -i 's/^_anbox=""$/_anbox="false"/g' customization.cfg
sudo sed -i 's/^_menunconfig=""$/_menunconfig="false"/g' customization.cfg
sudo sed -i 's/^_modprobeddb="false"$/_modprobeddb="true"/g' customization.cfg
makepkg -si
cd ..
rm -fr linux-tkg

clear
echo
read -p "Install Mesa-Git, Wine-TKG-Git and Proton-TKG? [Y/N] -> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  clear
  echo -e "\nCloning Main Repository...\n"
  #git clone --recurse-submodules https://github.com/Tk-Glitch/PKGBUILDS
  mkdir PKGBUILDS
  cd PKGBUILDS
  rm -fr wine-tkg-git
  git clone https://github.com/Frogging-Family/wine-tkg-git
  rm -fr dxvk-tools
  git clone https://github.com/Frogging-Family/dxvk-tools
  rm -fr mesa-git
  git clone https://github.com/Frogging-Family/mesa-git

  clear
  echo -e "\nInstalling Wine-TKG-Git...\n"
  cd wine-tkg-git
  cd wine-tkg-git
  makepkg -si
  cd ..
  cd ..

  clear
  echo -e "\nUsing DXVK-Tools...\n"
  sudo pacman -S mingw-w64-gcc
  cd dxvk-tools
  ./updxvk build
  ./upvkd3d-proton build
  ./updxvk proton-tkg
  cd ..

  clear
  echo -e "\nInstalling Proton-TKG...\n"
  cd wine-tkg-git
  cd proton-tkg
  sudo sed -i 's/^_nomakepkg_dep_resolution_distro=""$/_nomakepkg_dep_resolution_distro="archlinux"/g' proton-tkg.cfg
  ./proton-tkg.sh clean
  ./proton-tkg.sh
  cd ..
  cd ..
  
  clear
  echo -e "\nInstalling Mesa-Git...\n"
  cd mesa-git
  makepkg -si
  cd ..
  
  cd ..
  rm -fr PKGBUILDS
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
  sudo pacman -S --noconfirm gnome-tweaks
fi

clear
echo
read -p "Install GNOME Shell Extensions? [Y/N] -> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  rm -fr ~/.local/share/gnome-shell/extensions/trayIconsReloaded@selfmade.pl/
  wget https://extensions.gnome.org/extension-data/trayIconsReloadedselfmade.pl.v19.shell-extension.zip
  mv trayIconsReloaded*.zip trayIconsReloaded@selfmade.pl.zip
  unzip trayIconsReloaded@selfmade.pl.zip -d ~/.local/share/gnome-shell/extensions/trayIconsReloaded@selfmade.pl/
  rm -r trayIconsReloaded@selfmade.pl.zip

  rm -fr ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/
  wget https://extensions.gnome.org/extension-data/dash-to-dockmicxgx.gmail.com.v71.shell-extension.zip
  mv dash-to-dock*.zip dash-to-dock@micxgx.gmail.com.zip
  unzip dash-to-dock@micxgx.gmail.com.zip -d ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/
  rm -r dash-to-dock@micxgx.gmail.com.zip

  rm -fr ~/.local/share/gnome-shell/extensions/desktopicons-neo@darkdemon/
  wget https://extensions.gnome.org/extension-data/desktopicons-neodarkdemon.v6.shell-extension.zip
  mv desktopicon*.zip desktopicons-neo@darkdemon.zip
  unzip desktopicons-neo@darkdemon.zip -d ~/.local/share/gnome-shell/extensions/desktopicons-neo@darkdemon/
  rm -r desktopicons-neo@darkdemon.zip
fi

clear
echo
read -p "Install Google Chrome? [Y/N] -> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo -e "\nInstalling Google Chrome...\n"
  yay -S --noconfirm google-chrome
fi

clear
echo
read -p "Install Discord? [Y/N] -> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo -e "\nInstalling Discord...\n"
  yay -S --noconfirm discord
fi

clear
echo
read -p "Install Spotify? [Y/N] -> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo -e "\nInstalling Spotify...\n"
  yay -S --noconfirm spotify
fi

clear
echo -e "\nUpdating GRUB Config...\n"
sudo grub-mkconfig -o /boot/grub/grub.cfg

clear
echo -e "\Cleaning Up...\n"
yay -Syu --noconfirm
sudo pacman -Syu
sudo pacman -Syyuu
sudo pacman -Sc --noconfirm
sudo pacman -Scc --noconfirm
sudo rm -rf ~/.cache/*
sudo pacman -Qtdq --noconfirm
sudo pacman -Rns --noconfirm $(pacman -Qtdq)
yay -Scc --noconfirm

clear
echo -e "To enable Proton for all games:"
echo -e "Navigate to Steam / Settings / Steam Play / Advanced and tick the Enable Steam Play for all other titles.\n"
echo -e "To enable Gamemode for a game:"
echo -e "Click on the Properties of a game, navigate to SET LAUNCH OPTIONS and type in gamemoderun %command%.\n"
echo -e "To enable glthread for a game:"
echo -e "Click on the Properties of a game, navigate to SET LAUNCH OPTIONS and type in mesa_glthread=true %command%.\n"
echo -e "ALL DONE. Now go and play games!"
echo -e "Please restart the PC for changes to take effect."

# ONLY AMD
# sudo nano /etc/environment
# add line " RADV_PERFTEST=aco "

# Go back to original dir
cd "$orig_dir"
