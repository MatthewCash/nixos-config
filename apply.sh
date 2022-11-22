#!/usr/bin/env bash

exec nixos-rebuild switch --flake path:. --use-remote-sudo $@
