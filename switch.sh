#!/usr/bin/env bash
# Rebuild hp-nixos bypassing parent ~/dotfiles git filter (use path: flake ref).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec sudo nixos-rebuild switch --flake "path:${DIR}#hp-nixos" "$@"
