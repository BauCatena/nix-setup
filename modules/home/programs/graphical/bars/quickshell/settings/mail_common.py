#!/usr/bin/env python3
"""Shared env for Himalaya subprocesses (Quickshell has a minimal PATH)."""
import os
from pathlib import Path

HOME = Path.home()
CONFIG = HOME / ".config" / "himalaya" / "config.toml"

PATH_PREFIX = (
    "/run/wrappers/bin",
    "/run/current-system/sw/bin",
    str(HOME / ".local/bin"),
    str(HOME / ".nix-profile/bin"),
    "/nix/var/nix/profiles/default/bin",
)


def subprocess_env() -> dict[str, str]:
    env = {**os.environ}
    env["PATH"] = os.pathsep.join(PATH_PREFIX + (env.get("PATH", "").split(os.pathsep) if env.get("PATH") else ()))
    if not env.get("DBUS_SESSION_BUS_ADDRESS"):
        runtime = env.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}"
        bus = Path(runtime) / "bus"
        if bus.is_socket() or bus.exists():
            env["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path={bus}"
    if not env.get("XDG_RUNTIME_DIR"):
        env["XDG_RUNTIME_DIR"] = f"/run/user/{os.getuid()}"
    return env
