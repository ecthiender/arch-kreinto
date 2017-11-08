#!/bin/bash
# Script to install a gnome in Arch Linux

# install the alsa packages
pacman -S alsa-utils
if [[ $? -ne 0 ]]; then
  echo "WARNING: Error installing Alsa packages."
  echo "Please examine later."
fi

# install Xorg
pacman -S xorg-server xorg-init xorg-server-utils mesa
if [[ $? -ne 0 ]]; then
  echo "ERROR: Error installing Xorg packages."
  echo "Aborting.."
  exit 1;
fi

# install gnome
pacman -S gnome gnome-extra gdm
if [[ $? -ne 0 ]]; then
  echo "ERROR: Error installing Gnome packages."
  echo "Aborting.."
  exit 1;
fi

# enable gdm
systemctl enable gdm.service
# restart
reboot
