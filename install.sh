#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash util-linux coreutils nixos-install mkpasswd

# Mount filesystems

mkdir -p /installroot
mount -t tmpfs none /installroot
mkdir -p /installroot/{boot,nix,mnt/{persist,home}}

mount /dev/disk/by-partlabel/disk-main-efi /installroot/boot
mount /dev/main/nix /installroot/nix
mount /dev/main/persist /installroot/mnt/persist

mkdir -p /installroot/mnt/home/matthew
mount /dev/mapper/home-matthew /installroot/mnt/home/matthew

# Create password file directory

mkdir -p /installroot/mnt/persist/pwd

mkpasswd -m sha-512 > /installroot/mnt/persist/pwd/matthew

# Copy this repo to the new installation

cp -r . /installroot/mnt/persist/$(basename $(pwd))

# Install NixOS

nixos-install --no-root-passwd --root /installroot --flake path:.

nixos-enter --root /installroot -c 'chown matthew:users /mnt/home/matthew'
