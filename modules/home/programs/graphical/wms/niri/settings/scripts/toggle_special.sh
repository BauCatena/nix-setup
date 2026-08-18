#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

workspace="${1:?usage: toggle_special.sh <workspace-name>}"

focused_name=$(niri msg -j workspaces | jq -r '.[] | select(.is_focused) | .name // empty')

if [ "$focused_name" = "$workspace" ]; then
    niri msg action focus-workspace-previous
else
    niri msg action focus-workspace "$workspace"
fi
