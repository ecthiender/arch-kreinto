#!/bin/bash

### Arch Kreinto ###

# This script installs a base Arch Linux system. It assumes this
# script is run from a USB and installs the base Arch system on the primary
# storage disk of the computer.


#--------------------------#
# CONFIGURATION PARAMETERS #
#--------------------------#


# Please configure the parameters below to suit your own needs.
# NOTE: Without configuring the parameter the script would fail!

# the device in which Arch is going to be installed
DEVICE="/dev/sda"
# size of the boot partition (/boot); follow `parted` notation like MiB, GiB etc.
BOOT_SIZE="500MiB"
# size of the root partition (/); follow `parted` notation like MiB, GiB etc.
ROOT_SIZE="100GiB"
# size of the home partition (/home) or else all the remaining space after root
# parition (in the latter case leave it to 100%)
HOME_SIZE="100%"


# Network related configuration
# --------------------------

# interface name on which networking has to run
INTERFACE="wlp5s0"
# hostname of the system
HOSTNAME="x89"
# locale of the system
LOCALE="en_IN.UTF-8"
# timezone in the format Zone/Sub-zone like Asia/Kolkata, Europe/London
# please see the valid timezones in /etc/share/zoneinfo
TIMEZONE="Asia/Kolkata"
# username of the default non-privileged user
USER="ecthiender"
