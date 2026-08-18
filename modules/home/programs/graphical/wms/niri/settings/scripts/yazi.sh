#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"
export EDITOR=nvim
export VISUAL=nvim
exec "$SCRIPT_DIR/run.sh" foot -e yazi
