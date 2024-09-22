#bin/bash

parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 1GiB -8GiB
parted /dev/sda -- mkpart primary linux-swap -8GiB 100%

parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 3 esp on
sleep 1;
mkfs.ext4 -L nixos /dev/sda1
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3
sleep 1;
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
nixos-generate-config --root /mnt;