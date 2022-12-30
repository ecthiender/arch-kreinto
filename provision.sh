#!/bin/bash
set -euo -pipefail

### Arch Kreinto ###

# This script installs a base Arch Linux system. It assumes this script is run
# from a USB and installs the base Arch system on the primary storage disk of
# the computer.

# Source the configuration file
chmod u+x ./config.sh
. config.sh

# this will erase all of the data on the hard disk,
# this is a helper function and not really used in the installation
erase_entire_disk() {
  echo "OBLITERATING THE WORLD!!!!!!"
  echo "Erasing entire disk??!!!"
  sgdisk --zap-all $DEVICE
}

is_uefi() {
  efivar -l
  if [[ $? -ne 0 ]]; then
    # not a UEFI mobo
    echo "no"
  else
    #UEFI
    echo "yes"
  fi
}

verify_connectivity() {
  ping -c 1 8.8.8.8 &> /dev/null
  echo $?
}

update_system_clock() {
  echo "Update system clock..."
  timedatectl set-ntp true
}

# create partition and make filesystem
create_partition_n_mkfs() {
  echo "Partitioning the drives..."
  parted $DEVICE -s mklabel msdos && \
  # TODO: why is /boot fat32?
  parted $DEVICE -s mkpart primary fat32 1MiB 100MiB && \ # --> /boot
  parted $DEVICE -s set 1 boot on && \
  parted $DEVICE -s mkpart primary ext4 100MiB $ROOT_SIZE && \ # --> /
  parted $DEVICE -s mkpart primary ext4 $ROOT_SIZE $HOME_SIZE && \ # --> /home
  echo "Formatting the partitions...."
  mkfs.fat -F32 $DEVICE"1" && \ # --> /boot
  mkfs.ext4 $DEVICE"2" && \ # --> /
  mkfs.ext4 $DEVICE"3" # --> /home
}

mount_fs() {
  echo "Mounting the newly created partitions..."
  mount $DEVICE"2" /mnt &&\
  mkdir -p /mnt/boot &&\
  mount $DEVICE"1" /mnt/boot &&\
  mkdir -p /mnt/home &&\
  mount $DEVICE"3" /mnt/home
}

install_base_system() {
  echo "Installing the base system!..."
  pacman-key --refresh-keys
  pacstrap /mnt base base-devel linux linux-firmware
}

change_locale() {
  echo "Configuring locale..."
  sed -i "s/#$LOCALE UTF-8/$LOCALE UTF-8/" /etc/locale.gen
  locale-gen
  echo "LANG=$LOCALE" > /etc/locale.conf
}

configure_tz() {
  echo "Configuring timezone.."
  ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
  hwclock --systohc --utc
}

initramfs() {
  echo "Making initramfs..."
  mkinitcpio -p linux
}

install_grub() {
  echo "Installing and configuring grub..."
  pacman -S grub os-prober
  grub-install --recheck $DEVICE
  grub-mkconfig -o /boot/grub/grub.cfg
}

config_netw() {
  echo "Configuring networking..."
  echo $HOSTNAME > /etc/hostname
  systemctl enable "dhcpcd@$INTERFACE.service"
  pacman -S iw wpa_supplicant dialog
}

install_chroot_sys() {
  # none of the below tasks are parallel. all are sequential, hence the
  # ampersand
  change_locale \
    && configure_tz \
    && initramfs \
    && install_grub \
    && config_netw
}

configure_system() {
  echo "Configuring the system post install..."
  genfstab -U /mnt > /mnt/etc/fstab
  this_file=$(basename $0)
  cmd="cd /mnt && bash ${this_file} chroot"
  cp ${this_file} /mnt/
  echo "Entering into chroot of base system to generate initramfs and grub..."
  echo "Cmd is: $cmd"
  arch-chroot /mnt /bin/bash -c '${cmd}'
}

configure_users() {
  echo "Adding user $USER.."
  useradd -G wheel -m $USER
  pacman -S sudo \
    && sed -i 's/#%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
}

reboot_system() {
  sync
  sleep 1
  echo "Synced.."
  echo "Unmounting /mnt..."
  umount -R /mnt
  sleep 1
  echo ""
  echo "-------------------"
  echo "Arch Linux system installed successfully."
  echo "Please review the installation and then reboot by running: 'reboot'"
  echo "-------------------"
}

# the main installation function
install() {
  # If its a UEFI system, we can't proceed. User has to configure their BIOS to
  # enable legacy boot option. So that we can boot from arbitrary device to
  # install systems.

  if [[ $(is_uefi) == "yes" ]]; then
    echo "UEFI system don't know how to proceed :("
    echo "Aborting..."
    exit 1;
  else
    # Check if internet connection is available. It is required to install our
    # system.
    echo "Checking connectivity..."
    conn=$(verify_connectivity)
    if [[ "$conn" -ne 0 ]]; then
      echo "No internet connection detected! :("
      echo "This Arch Linux installation requires internet to continue."
      echo "Aborting..."
      exit 1;
    fi

    # else install the system..
    # by the following steps performed strictly in order :
    #  1. Create the actual partitions and format the filesystem.
    #  2. Mount the newly created filesystem to install the base system.
    #  3. Use arch utility pacstrap to install the base system.
    #  4. Chroot into the system and setup the boot procedures; and then
    #     configure the system with locale, timezone, users etc.
    #  5. Finally, reboot the system and we should boot into our new Arch!! \o/

    update_system_clock \
      && create_partition_n_mkfs \
      && mount_fs \
      && install_base_system \
      && configure_system \
      && reboot_system
  fi
}

usage() {
  echo "Usage:  "
  echo "$0 ACTION         where ACTION is:"
  echo "      main: Install the main system."
  echo "      obliterate: Destroys all the data"
  echo "                  of the device entered"
  echo "                  in the configuration. (like /dev/sda etc.)"
  echo "      help: Display this help."
}

arg="$1"

if [[ $arg == "main" ]];then
  install
elif [[ $arg == "chroot" ]]; then
  install_chroot_sys
elif [[ $arg == "obliterate" ]]; then
  erase_entire_disk
elif [[ $arg == "--help" || $arg == "help" || $arg == "-h" ]];then
  usage
  exit 0
else
  echo "Invalid action!"
  usage
  exit 1
fi
