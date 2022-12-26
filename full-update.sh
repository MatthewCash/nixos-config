#!/usr/bin/env bash

nix flake update path:.
./apply.sh
