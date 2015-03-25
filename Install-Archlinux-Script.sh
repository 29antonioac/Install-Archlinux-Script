#!/bin/bash

# This is an easy script for my own use. It reinstalls my Archlinux system faster.
echo "This script is for reinstall my Archlinux system faster."
read -p "I'm not responsible for any damage in your system. Do you agree? (y/n) " RESPONSE

while [ "${RESPONSE,,}" != "y" ] && [ "${RESPONSE,,}" != "n" ]
do
  echo "I don't understand you."
  read -p "I'm not responsible for any damage in your system. Do you agree? (y/n) " RESPONSE
done

if [ "${RESPONSE,,}" == "n" ]
then
  exit 1
fi

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
CORRECT="n"
ROOT=""
while [ ${CORRECT,,} == "n" ]
do
  read -p "Number of partitions: " PARTITIONS
  declare -A mountpoints
  for (( partition=1 ; partition<=$PARTITIONS ; partition++ ))
  do
    read -p "Type the partition (/dev/sdxn), a mountpoint (/,/home...) " PARTITION MOUNTPOINT
    mountpoints["$PARTITION"]="$MOUNTPOINT"
    if [ $MOUNTPOINT == "/" ]
    then
      ROOT="$PARTITION"
    fi
  done

  for mountpoint in "${!mountpoints[@]}"; do echo "$mountpoint -> ${mountpoints["$mountpoint"]}"; done
  read -p "Is this correct? (y/n) " CORRECT
  while [ "${CORRECT,,}" != "y" ] && [ "${CORRECT,,}" != "n" ]
  do
    echo "I don't understand you."
    read -p "I'm not responsible for any damage in your system. Do you agree? (y/n) " CORRECT
  done

  if [ ${ROOT,,} == "" ]
  then
    CORRECT="n"
    echo "Not / partition found"
  fi

done

for partition in "${!mountpoints[@]}"
do
  mkfs.ext4 $partition
done
########

# Mount the partitions
echo "Mounting partitions..."
mount $ROOT /mnt
unset mountpoints[$ROOT]

for partition in "${!mountpoints[@]}"
do
  mkdir /mnt${mountpoints["$partition"]}
  mount $partition /mnt${mountpoints["$partition"]}
done


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
