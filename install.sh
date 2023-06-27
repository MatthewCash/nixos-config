#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash parted util-linux cryptsetup systemd kmod lvm2 coreutils

# Set this to either the by-path/ or by-id/ path for the disk
disk=/dev/disk/by-path/pci-0000:00:0e.0-pci-10000:e1:00.0-nvme-1

# Partition disk

parted $disk mklabel gpt
parted $disk mkpart efi 0% 500M
parted $disk set 1 esp on
parted $disk mkpart lvm 500M 100%

# Setup EFI partition

mkfs.vfat ${disk}-part1 -n efi

# Setup Encrypted LVM Partition

cryptsetup luksFormat ${disk}-part2
cryptsetup luksOpen ${disk}-part2 main
cryptsetup config ${disk}p2 --label crypt-main
systemd-cryptenroll --tmp2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-label/crypt-main

# Setup LVM

modprobe dm_thin_pool

pvcreate ${disk}-part2
vgcreate main ${disk}-part2

lvcreate -T -l 95%FREE main -n thin-main

lvcreate -V 1T --thinpool thin-main main -n nix
lvcreate -V 32G --thinpool thin-main main -n swap
lvcreate -V 1T --thinpool thin-main main -n persist
lvcreate -V 1T --thinpool thin-main main -n crypt-home-matthew

# Setup Encrypted Home Volume

cryptsetup luksFormat /dev/main/crypt-home-matthew
cryptsetup luksOpen /dev/main/crypt-home-matthew home-matthew
cryptsetup config /dev/main/crypt-home-matthew --label crypt-home-matthew

mkfs.btrfs /dev/mapper/home-matthew -L home-matthew

# Setup Persist file system

mkfs.btrfs /dev/main/persist -L persist

# Setup Nix file system

mkfs.btrfs /dev/main/nix -L nix

# Mount filesystems

mkdir -p /mnt
mount -t tmpfs none /mnt
mkdir -p /mnt/{boot,nix,mnt/{persist,home}}

mount /dev/disk/by-label/efi /mnt/boot
mount /dev/disk/by-label/nix /mnt/nix
mount /dev/disk/by-label/persist /mnt/mnt/persist

mkdir -p /mnt/mnt/home/matthew
mount /dev/disk/by-label/home-matthew /mnt/mnt/home/matthew

# Create password file directory

mkdir -p /mnt/mnt/persist/pwd

# Copy this repo to the new installation

cp -r . /mnt/mnt/persist/
