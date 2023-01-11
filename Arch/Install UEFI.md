## A Note about installing Arch Linux

There's a good chance by the time you are reading this that it is out of date, to stay up to date on Arch Linux Installs checkout the [Arch Wiki](https://wiki.archlinux.org/index.php/Installation_guide)

## A Note about UEFI

UEFI (Unified Extensible Firmware Interface) is replacing BIOS (Basic-Input-Output system), if you are using modern hardware you are assuredly using UEFI. If you are interested in reading more about why checkout this excellent [article](https://www.howtogeek.com/56958/htg-explains-how-uefi-will-replace-the-bios/) explaining some key differences

## Verify boot mode

This command will verify that we will boot in UEFI mode

```
ls /sys/firmware/efi/efivars
```

IF the above directory doesn't exist you are either on old hardware or you have UEFI disabled

## Internet connection

I recommend installing over ethernet if your not then you can connect using `wifi-menu`

To confirm you're internet works:

```
ping -c 5 archlinux.org
```

If your ethernet is not working then try the following:

```
ip link # this will show you a number that looks something like  enp39s0
```

Use the number you found earlier to bring up your interface:

```
ip link set dev enp39s0 up
```

Then when it is up run Dhcp to pull an IP from the server:

```
dhcpcd enp39s0
```

Set WiFi Network:

```
iwctl
station wlan0 connect "SSID"
```

Now try to ping again

## Update System clock

```
timedatectl set-ntp true
```

## Partition disks

Here is where you will most likely find the most trouble if you are not familiar with partitioning tools such as fdisk I would recommend you watch a video for this part since this really won't change much.

**First list your disks**

```
lsblk
```

You should see your disk in here mine is called /dev/sdx (WARNING do not write to any of these disks unless you know it's the one you want to install Arch on)

**Now choose the disk you wish to partition**

```
fdisk /dev/sdx
g
w
fdisk /dev/sdx
```

You should now be in the fdisk utility you can press `m` for help

All of our partitions will be **GPT** partitions so you can press `g` when ready

We will be create 3 partitions for the following:

- boot
- root
- home

### Boot partition

- Enter `n` (To create new partition)

- Enter `ENTER` (For the next available partition)

- Enter `ENTER` (To start the first available section)

- Enter `+512M` (This is the recommended size for our our boot partition)

- Enter `t` (To change the type of the partition to EFI)

- Enter `1` (To set the type of the partition we just made to EFI)

### Root partition

- Enter `n` (To create new partition)

- Enter `ENTER` (For the next available partition)

- Enter `ENTER` (To start the first available section)

- Enter `+15G` (You can increase this if you plan on installing a lot of programs 20G is usually more than enough)

- Enter `t` (To change the type of the partition to Linux Root (x86-64))

- Enter `2` (You will now need to specify which partition you are referring to since now there are two or more)

- Enter `23` (To set the type of the partition we just made to Linux Root (x86-64))

### Home partition

- Enter `n` (To create new partition)

- Enter `ENTER` (For the next available partition)

- Enter `ENTER` (To start the first available section)

- Enter `ENTER` (Just use the rest of the drive, I would even recommend putting this partition on a separate drive if you have a spare)

- Enter `t` (To change the type of the partition to Linux home)

- Enter `3` (You will now need to specify which partition you are referring to since now there are two or more)

- Enter `28` (To set the type of the partition we just made to Linux home)

### Write changes to disk

- Enter `w`

Now you can run `fdisk -l` to see your newly created partitions

## Format the partitions

We have to create 3 file systems here, so let's get started

- Format the EFI partition with:

```
mkfs.vfat /dev/sdx1
```

- Format the Root partition with:

```
mkfs.ext4 /dev/sdx2
```

- Format the Home partition with:

```
mkfs.ext4 /dev/sdx3
```

## Mount the filesystems

You will need to mount sdx1, sdx2 and sdx3, but you will need to mount Root first

- Mount sdx2 (Root)

```
mount /dev/sdx2 /mnt
```

- Mount sdx1 (Boot)

```
mkdir /mnt/boot
mount /dev/sdx1 /mnt/boot
```

- Mount sdx3 (Home)

```
mkdir /mnt/home
mount /dev/sdx3 /mnt/home
```

### Check mounts are correct

You can run `df` to make sure your mounts are in the right place

## Install essential packages (and a few others)

Run the following:

```
pacstrap /mnt base linux linux-firmware
```

## Configure the system

### Fstab

Generate UUIDs for newly created filesystem

```
genfstab -U /mnt >> /mnt/etc/fstab
```

You can check that it worked by printing the file:

```
cat /mnt/etc/fstab
```

### Chroot

Now you can change root into the new system:

```
arch-chroot /mnt
```

### Update Microcode for CPU

For AMD:

```
pacman -S amd-ucode
```

For Intel:

```
pacman -S intel-ucode
```

### Install base packages

Run the following:

```
pacman -S base-devel nano
```

### Install Packages Required for Internet and WiFi

For Both:

```
pacman -S connman
systemctl enable ConnMan
```

For WiFi:

```
pacman -S wpa_supplicant wireless_tools netctl dialog
```

### Time zone

Set the time zone:

```
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
```

Just search through /usr/share/zoneinfo until you find your nearest City

Run `hwclock`:

```
hwclock --systohc
```

### Localization

Uncommnent `en_US.UTF-8 UTF-8` in `/etc/locale.gen`:

```
sed -i  's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
```

Generate them with:

```
locale-gen
```

Create the `locale.conf` file, and set LANG variable

```
echo "LANG=en_US.UTF-8"  > /etc/locale.conf
```

## Network configuration

Create `hostname` file:

```
echo "arch-pc" > /etc/hostname
```

Add matching entries to `hosts`

```
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch-pc" >> /etc/hosts
```

## Root password

Change the root password:

```
passwd
```

## Create new User and Password

```
useradd -m -g users -G wheel benja
passwd benja
```

## Make Users Can Run Sudo Commands

UnComment "%wheel ALL=(ALL) ALL":

```
EDITOR=nano visudo
```

## Boot loader

We'll be using grub because it has the biggest presence in the boot loader world

```
pacman -S grub efibootmgr os-prober mtools
```

Now let's install our boot loader

```
grub-install --target=x86_64-efi --efi-directory=/boot --removable
```

Generate our config

```
grub-mkconfig -o /boot/grub/grub.cfg
```

## Reboot

Enter `exit` then `reboot`

## Install YAY
```
pacman -S git
git clone https://aur.atchlinux.org/yay.git
cd yay
makepkg -si
cd
rm -fr yay
yay -Syu
```

## Login as Root
`su`

## Install zRAM Service as SWAP
```
yay -S zramd
systemctl enable --now zramd
```

## Create a swap file

I'm going to use the varibale X to indicate what your swap size should be

where X is RAM+sqrt(RAM)

```
fallocate -l XGB /swapfile

chmod 600 /swapfile

mkswap /swapfile

swapon /swapfile
```

## Create fstab BackUp

Run the following:

```
cp /etc/fstab /etc/fstab.bak
```

## Add swapfile to fstab

```
echo '/swapfile none swap default 0 0' | tee -a /etc/fstab
```

## Install XOrg

Run the following:

```
pacman -S xorg-server
```

## Install Graphic Driver

For AMD or Intel:

```
pacman -S mesa
```

For NVidia:

```
pacman -S nvidia
```

## Install Minimal GNOME

Run the following:

```
pacman -S gnome-shell nautilus gnome-terminal gnome-control-center gedit xdg-user-dirs
```

## Install Display Manager

For GDM:

```
pacman -S gdm
systemctl enable gdm
```

For LightDM:

```
pacman -S lightdm lightdm-gtk-greeter
systemctl enable lightdm
```

## Reboot
`reboot`
