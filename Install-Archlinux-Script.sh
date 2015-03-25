#!/bin/bash

# This is an easy script for my own use. It reinstalls my Archlinux system faster.
echo "This script is for reinstall my Archlinux system faster."
read -p "I'm not responsible for any damage in your system. Do you agree? (y/n)" RESPONSE

while [ ${RESPONSE,,} -ne "y" ] || [ ${RESPONSE,,} -ne "n" ]; do
  echo "I don't understand you."
  read -p "I'm not responsible for any damage in your system. Do you agree? (y/n)" RESPONSE

# Set the keyboard layout
echo "Loading es layout..."
loadkeys es

# Set the font
echo "Setting Terminus font..."
setfont Lat2-Terminus16

# Set locale and generate it/them
sed -i.bak -e 's/#es_ES.UTF-8/es_ES.UTF-8/; s/en_US.UTF-8/#en_US.UTF-8/' /etc/locale.gen
locale-gen
export LANG=es_ES.UTF-8

# Establish an internet connection
########

# Preparing storage devices
mkfs.ext4 /dev/sda1
mkfs.reiserfs /dev/sda2
########

# Mount the partitions
echo "Mounting partitions..."
mount /dev/sda1 /mnt
mkdir /mnt/var
mount /dev/sda2 /mnt/var

# Select a mirror and update pacman database
echo "Selecting the osl mirror and updating pacman database..."
sed -i.bak '1iServer = http://osl.ugr.es/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
pacman -Syy

# Install the base system
echo "Installing your system!"
pacstrap -i /mnt base base-devel --noconfirm

# Generate an fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

# Download chroot script
wget http://goo.gl/EVv7cm -O /mnt/After-chroot.sh

# Chroot and configure
arch-chroot /mnt /bin/bash -c "chmod u+x After-chroot.sh && ./After-chroot.sh"

# Umount all partitions
umount -R /mnt

echo "Voilá! Reboot your system and enjoy Archlinux!"
