#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

if ! pgrep -f '[f]oot --server' >/dev/null 2>&1; then
    foot --server &
    sleep 0.35
fi

if [ "$#" -eq 0 ]; then
    exec foot
fi

exec foot "$@"
