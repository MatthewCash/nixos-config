#!/usr/bin/env bash

exec nixos-rebuild switch --flake path:$(pwd) --use-remote-sudo
