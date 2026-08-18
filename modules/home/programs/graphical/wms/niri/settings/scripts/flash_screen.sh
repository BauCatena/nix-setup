#!/usr/bin/env bash
# Strong visual pulse for screenshots (niri screen transition).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

for _ in 1 2 3; do
    niri msg action do-screen-transition 2>/dev/null || true
    sleep 0.07
done
