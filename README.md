# nixos-config

This is the configuration for my machines running NixOS

The main goal is to be fully declarative and reproducible while not compromising usability or security

## Implemented Features

- Secure Boot with custom keys using [lanzaboote](https://github.com/nix-community/lanzaboote)
- Full Disk encryption with key enrolled in TPM2
- Encrypted home directory unlocked automatically on login with pam-mount
- [impermanence](https://github.com/nix-community/impermanence) (/ on a tmpfs) with explicitly persisted paths
- Standalone [home-manager](https://github.com/nix-community/home-manager) activation script generation
- Image generation using [nixos-generators](https://github.com/nix-community/nixos-generators) to simplify installation and deployment

## TODO

- Sandboxing applications using something like [bubblewrap](https://github.com/containers/bubblewrap)
- Setup disks during installation using [disko](https://github.com/nix-community/disko)

## Installation

There is no easy way to install this configuration yet, you are expected to be very famililar with NixOS, flakes, and disk partitioning

Your nix installation should have `nix-command` and `flakes` features set to enabled, [nix-installer](https://github.com/DeterminateSystems/nix-installer) will do this automatically

[Images](#image-generation) can be built that contain a copy of this repository to make installation simpler

A basic [install script](install.sh) exists to somewhat automate installation but must be modified for each system

## Updating and Applying Changes

The [flake](flake.nix) contains small scripts to make applying changes and updating the system easier

After modifying the configuration run `nix run .#apply` to apply the changes

To update the flake's inputs and apply the changes run `nix run .#full-upgrade`

Use `nix run .#test` to verify that all systems evaluate successfully before committing

## Standalone Home Manager Configurations

Home Manager configurations can be applied without applying the entire system configuration

Impermanence is disabled when using a standalone configuration

To apply the configuration run `nix run .#homeConfigurations.<system>.<name>` replacing `<system>` with the appropriate system in `systems/` and `<name>` with a username listed in that system's home config

## Image Generation

Images can be easily generated using [nixos-generators](https://github.com/nix-community/nixos-generators)

Run `nix build .#generators.<format>.<system>`, replacing `<format>` with an image format (e.g. `qcow`, `iso`) and `<system>` with the appropriate system in `systems/`

An installation image for this configuration can be generated with `nix build.#generators.install-iso.installer`

> **Note**
> Generating images requires a large $TMPDIR, consider running `nix build` with `NIX_REMOTE=local TMPDIR=/mnt/persist/tmp` to ensure adequate space is available

## Directory Structure

### System Configurations `config/`

This directory contains configuration files that modify the system state

### Home Configurations `home/`

This directory contains configuration files that modify the user's home directory using [home-manager](https://github.com/nix-community/home-manager)

If the configuration would affect a home directory, or the option could be user-specific, it should go here

- Applications (web browser, file browser, shell, development utils) and their configurations
- Themes (shell, applications)
- Desktop configuration

### System Declarations `systems/`

This directory contains the declarations for individual systems, config imports, and system-specific configurations

The individual system declarations `systems/systemname/default.nix` contain basic information that imported configs would need, such as

- System Name
- Architecture
- Kernel packages set
- nixpkgs Channel

The declarations also have fields used to specify config imports (for the system or home)

Files are usually imported from `config/` and `home/`, but systems often specify their own individual configs that should not be shared in `systems/systemname/config/`

The file `systems/buildSystem.nix` is responsible for taking these system declarations and building a complete NixOS system from them, it also calls `systems/buildHomeConfigs.nix` to build the home configuration

### Secrets `secrets.nix` and `secrets/`

[ragenix](https://github.com/yaxitech/ragenix) is used to encrypt files specified in `secrets.nix` and store them in `secrets/`, which will be decrypted to `/run/agenix.d/` at runtime

### Custom library `lib/`

This directory contains nix functions that may be useful in creating configurations

Functions are exposed to configurations in the `customLib` argument
