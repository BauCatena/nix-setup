#!/bin/bash

emit() {
    niri msg -j windows 2>/dev/null | jq -c --argjson focused "$(niri msg -j workspaces 2>/dev/null | jq '[.[] | select(.is_focused)][0].id // empty')" '
        if $focused == "" then 0 else
            [.[] | select(.workspace_id == ($focused | tonumber) and (.is_floating | not))] | length
        end'
}

emit
niri msg --json event-stream 2>/dev/null | while read -r _; do
    emit
done
