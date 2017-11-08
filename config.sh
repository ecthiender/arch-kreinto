#!/bin/bash

#
#                    -` 				     ___           _       _   __         _       _
#                   .o+`            / _ \         | |     | | / /        (_)     | |
#                  `ooo/           / /_\ \_ __ ___| |__   | |/ / _ __ ___ _ _ __ | |_ ___
#                 `+oooo:          |  _  | '__/ __| '_ \  |    \| '__/ _ \ | '_ \| __/ _ \
#                `+oooooo:         | | | | | | (__| | | | | |\  \ | |  __/ | | | | || (_) |
#                -+oooooo+:        \_| |_/_|  \___|_| |_| \_| \_/_|  \___|_|_| |_|\__\___/
#              `/:-:++oooo+:
#             `/++++/+++++++:
#            `/++++++++++++++:						(c) Copyright 2017 ecthiender (Anon Ray)
#           `/+++ooooooooooooo/`					BSD Licensed
#          ./ooosssso++osssssso+`
#         .oossssso-````/ossssss+`				This script installs a base Arch Linux system.
#        -osssssso.      :ssssssso.				It assumes this script is run from a USB and
#       :osssssss/        osssso+++.			installs the base Arch system on the primary
#      /ossssssss/        +ssssooo/-			storage disk of the computer.
#    `/ossssso+/:-        -:/+osssso+-
#   `+sso+:-`                 `.-/+oso:
#  `++:.                           `-/+/
#  .`                                 `/
#



#--------------------------#
# CONFIGURATION PARAMETERS #
#--------------------------#


# Please configure the parameters below to suit your own needs.
# NOTE: Without configuring the parameter the script would fail!

# the device in which Arch is going to be installed
DEVICE="/dev/sda"
# size of the root partition (/); follow `parted` notation like MiB, GiB etc.
ROOT_SIZE="40GiB"
# size of the home partition (/home) or else all the remaining space after root
# parition (in the latter case leave it to 100%)
HOME_SIZE="100%"


# Network related configuration
# --------------------------

# interface name on which networking has to run
INTERFACE="wlp3s0"
# hostname of the system
HOSTNAME="x89"
# locale of the system
LOCALE="en_IN.UTF-8"
# timezone in the format Zone/Sub-zone like Asia/Kolkata, Europe/London
# please see the valid timezones in /etc/share/zoneinfo
TIMEZONE="Asia/Kolkata"
# username of the default non-privileged user
USER="ecthiender"
