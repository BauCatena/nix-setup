#!/usr/bin/env bash
# Prints "mic camera" (0/1 each) — only when an app is actively using them
set -u
export PATH="/run/current-system/sw/bin:/run/wrappers/bin:$HOME/.local/bin:$PATH"

ignored_apps='^(pipewire|WirePlumber|wireplumber|xdg-desktop-portal|Quickshell|quickshell|Electron)$'
ignored_procs='^(pipewire|wireplumber|pw-)$'

mic_in_use() {
    command -v pactl >/dev/null 2>&1 || return 1
    while IFS= read -r app; do
        [ -n "$app" ] || continue
        [[ "$app" =~ $ignored_apps ]] && continue
        return 0
    done < <(pactl list source-outputs 2>/dev/null | awk '
        /^Source Output #/ {
            if (state == "RUNNING" && app != "") print app
            state=""; app=""
        }
        /^[[:space:]]State:/ { state=$2 }
        /application.name = "/ {
            gsub(/^.*application.name = "|"$/, "", $0)
            app=$0
        }
        END {
            if (state == "RUNNING" && app != "") print app
        }
    ')
    return 1
}

camera_in_use() {
    for dev in /dev/video*; do
        [ -e "$dev" ] || continue
        for pid in $(fuser "$dev" 2>/dev/null || true); do
            [ -n "$pid" ] || continue
            comm=$(ps -p "$pid" -o comm= 2>/dev/null || true)
            [ -n "$comm" ] || continue
            [[ "$comm" =~ $ignored_procs ]] && continue
            return 0
        done
    done
    return 1
}

while true; do
    mic=0
    cam=0
    mic_in_use && mic=1
    camera_in_use && cam=1
    echo "$mic $cam"
    sleep 2
done
