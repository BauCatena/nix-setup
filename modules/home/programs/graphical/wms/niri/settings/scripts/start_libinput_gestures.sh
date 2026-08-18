#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

if pgrep -x libinput-gestures >/dev/null 2>&1; then
    exit 0
fi

exec libinput-gestures
