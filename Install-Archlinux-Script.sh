#!/bin/bash

# This is an easy script for my own use. It reinstalls my Archlinux system faster.

# Set the keyboard layout
echo "Loading es layout..."
loadkeys es

# Set the font
echo "Setting Terminus font..."
setfont Lat2-Terminus16

# Set locale and generate it/them
echo es_ES.UTF-8 UTF-8 > /etc/locale.gen
locale-gen
export LANG=es_ES.UTF-8

# Establish an internet connection 
########

# Preparing storage devices
########

# Mount the partitions
echo "Mounting partitions..."
mount /dev/sda1 /mnt

# Select a mirror and update pacman database
echo "Selecting the mirror and updating pacman database..."
echo 'Server = http://osl.ugr.es/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
pacman -Syy

# Install the base system
echo "Installing your system!"
pacstrap -i /mnt base --noconfirm

# Generate an fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

# Chroot and configure
arch-chroot /mnt

echo testing


