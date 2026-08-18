#!/usr/bin/env bash
set -euo pipefail
kdl="${HOME}/.config/niri/theme.kdl"
if [ -f "$kdl" ]; then
    theme=$(grep -oE 'switch_theme\.sh \([^)]+\)' "$kdl" 2>/dev/null \
        | sed -n 's/.*(\(.*\))/\1/p' | head -1)
    theme="${theme% preview}"
fi
echo "${theme:-minimal}"
