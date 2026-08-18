#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

niri msg action toggle-window-floating
niri msg action set-window-width 800
niri msg action set-window-height 600
niri msg action center-window
