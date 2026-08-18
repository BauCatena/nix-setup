#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"
exec "$SCRIPT_DIR/switch_theme.sh" "$("$SCRIPT_DIR/current_theme.sh")"
