#!/usr/bin/env bash
set -euo pipefail

emit() {
    niri msg -j workspaces 2>/dev/null | jq -c '{
        focused: ([.[] | select(.is_focused)][0].idx // 1),
        active: [.[] | select(.active_window_id != null) | .idx]
    }'
}

emit
niri msg --json event-stream 2>/dev/null | while read -r _; do
    emit
done
