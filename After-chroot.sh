#!/bin/bash

# This is an auxiliary script that is used after chroot the base system

# Set the keyboard layout
echo "Loading es layout..."
loadkeys es

# Set the font
echo "Setting Terminus font..."
setfont Lat2-Terminus16

# Make layout and font available after reboot
echo "Making changes available after reboot..."
echo KEYMAP=es > /etc/vconsole.conf
echo FONT=Lat2-Terminus16 >> /etc/vconsole.conf

# Set locales
echo "Setting locales..."
sed -i.bak -e 's/#es_ES.UTF-8/es_ES.UTF-8/; s/en_US.UTF-8/#en_US.UTF-8/' /etc/locale.gen
locale-gen
echo LANG=es_ES.UTF-8 > /etc/locale.conf
export LANG=es_ES.UTF-8

# Set the time zone
echo "Setting the time zone..."
ln -s /usr/share/zoneinfo/Europe/Madrid /etc/localtime

# Set UTC
echo "Installing ntp and setting UTC..."
pacman -S ntp --noconfirm && ntpd -qg
hwclock --systohc --utc

# Set hostname
read -p "Type the hostname: " HOSTNAME
echo $HOSTNAME > /etc/hostname

# Check if user needs Wi-Fi
read -p "Do you need Wi-Fi? (y/n): " WIFI
while [ $WIFI -ne "y" ] || [ $WIFI -ne "n" ]; do
  echo "I don't understand you."
  read -p "Do you need Wi-Fi? (y/n): " WIFI

if [ $WIFI -e "y" ]; then
  echo "Installing wpa_supplicant and dialog for wifi-menu use..."
  pacman -S wpa_supplicant dialog --noconfirm

# Configure the network
########

# Create an initial ramdisk environment
mkinitcpio -p linux

# Set the root password
passwd

# Install GRUB
pacman -S grub os-prober --noconfirm
grub-install --target=i386-pc --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Exit chroot
exit
