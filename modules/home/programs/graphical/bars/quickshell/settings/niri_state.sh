#!/usr/bin/env bash
# Workspace + tiled window count from a single niri event stream.
set -euo pipefail

emit() {
    local focused_id ws_json tiled
    focused_id="$(niri msg -j workspaces 2>/dev/null | jq '[.[] | select(.is_focused)][0].id // empty')"
    ws_json="$(niri msg -j workspaces 2>/dev/null | jq -c '{
        focused: ([.[] | select(.is_focused)][0].idx // 1),
        active: [.[] | select(.active_window_id != null) | .idx]
    }')"
    tiled="$(niri msg -j windows 2>/dev/null | jq -c --argjson focused "$focused_id" '
        if $focused == "" then 0 else
            [.[] | select(.workspace_id == ($focused | tonumber) and (.is_floating | not))] | length
        end')"
    jq -nc --argjson ws "$ws_json" --argjson tiled "$tiled" \
        '{focused: $ws.focused, active: $ws.active, tiled: $tiled}'
}

emit
niri msg --json event-stream 2>/dev/null | while read -r _; do
    emit
done
