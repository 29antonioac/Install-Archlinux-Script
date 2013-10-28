#!/bin/bash

# This is an easy script for my own use. It reinstalls my Archlinux system faster.

# Set the keyboard layout
loadkeys es

# Set the font
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
mount /dev/sda1 /mnt

# Select a mirror
echo "Server = http://osl.ugr.es/archlinux/$repo/os/$arch" > /etc/pacman.d/mirrorlist
pacman -Syy
pacstrap -i /mnt base
