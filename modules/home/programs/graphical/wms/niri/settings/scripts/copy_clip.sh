#!/usr/bin/env bash
set -euo pipefail
id="${1:?usage: copy_clip.sh <cliphist-id>}"
printf '%s' "$id" | cliphist decode | wl-copy
