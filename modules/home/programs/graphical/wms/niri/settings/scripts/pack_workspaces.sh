#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

workspaces_json=$(niri msg -j workspaces)
windows_json=$(niri msg -j windows)

mapfile -t active_indices < <(echo "$workspaces_json" | jq -r '[.[] | select(.active_window_id != null)] | sort_by(.idx) | .[].idx')
current_idx=$(echo "$workspaces_json" | jq -r '.[] | select(.is_focused) | .idx')
new_focus=$current_idx
target=1

for ws_idx in "${active_indices[@]}"; do
    if [ "$ws_idx" -ne "$target" ]; then
        ws_id=$(echo "$workspaces_json" | jq -r --argjson idx "$ws_idx" '.[] | select(.idx == $idx) | .id')
        mapfile -t window_ids < <(echo "$windows_json" | jq -r --arg ws_id "$ws_id" '.[] | select(.workspace_id == ($ws_id | tonumber)) | .id')

        for win_id in "${window_ids[@]}"; do
            [ -n "$win_id" ] && niri msg action move-window-to-workspace --window-id "$win_id" "$target"
        done

        if [ "$ws_idx" -eq "$current_idx" ]; then
            new_focus=$target
        fi
    fi
    target=$((target + 1))
done

niri msg action focus-workspace "$new_focus"
notify-send -a niri -t 1200 "Workspaces" "Packed to the left" 2>/dev/null || true
