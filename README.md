# nixos-config

This is the configuration for my machines running NixOS

The main goal is to be fully declarative and reproducible while not compromising usability or security

## Implemented Features

- Secure Boot with custom keys using [lanzaboote](https://github.com/nix-community/lanzaboote)
- Full Disk encryption with key enrolled in TPM2
- Encrypted home directory unlocked automatically on login with pam-mount
- [impermanence](https://github.com/nix-community/impermanence) (/ on a tmpfs) with explicitly persisted paths

## TODO

- Sandboxing applications using something like [bubblewrap](https://github.com/containers/bubblewrap)
- Generate images (ISO, qcow2, ...) using [nixos-generators](https://github.com/nix-community/nixos-generators)

## Updating and Applying Changes

The [flake](flake.nix) contains small scripts to make applying changes and updating the system easier

After modifying the configuration run `nix run .#apply` to apply the changes

To update the flake's inputs and apply the changes run `nix run .#full-upgrade`

Use `nix run .#test` to verify that all systems evaluate successfully before committing

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

The file `systems/buildSystem.nix` is responsible for taking these system declarations and building a complete NixOS system from them, it also calls `home/buildHomeConfigs.nix` to build the home configuration

### Secrets `secrets.nix` and `secrets/`

[ragenix](https://github.com/yaxitech/ragenix) is used to encrypt files specified in `secrets.nix` and store them in `secrets/`, which will be decrypted to `/run/agenix.d/` at runtime

### Nix utility functions `util/`

This directory contains small nix functions that may be useful in evaluating configurations
