#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash util-linux coreutils nixos-install mkpasswd

username="$1"

# Mount filesystems

mkdir -p /installroot
mount -t tmpfs none /installroot
mkdir -p /installroot/{boot,nix,mnt/{persist,home}}

mount /dev/disk/by-partlabel/disk-main-efi /installroot/boot
mount /dev/main/nix /installroot/nix
mount /dev/main/persist /installroot/mnt/persist

mkdir -p "/installroot/mnt/home/$username"
mount "/dev/disk/by-label/home-$username" "/installroot/mnt/home/$username"

# Create password file directory

mkdir -p /installroot/mnt/persist/pwd

mkpasswd -m sha-512 > "/installroot/mnt/persist/pwd/$username"

# Copy this repo to the new installation

cp -r . "/installroot/mnt/persist/$(basename $(pwd))"

# Install NixOS

nixos-install --no-root-passwd --root /installroot --flake path:.

nixos-enter --root /installroot -c "chown $username:users /mnt/home/$username"

systemd-cryptenroll --tpm2-pcrs="0+2+7+15:sha256=0000000000000000000000000000000000000000000000000000000000000000" --tpm2-device=auto /dev/disk/by-label/crypt-main --wipe-slot=tpm2
