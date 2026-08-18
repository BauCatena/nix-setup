#!/usr/bin/env python3
"""Poll inbox for new OTP emails; notify Quickshell."""
import json
import os
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from mail_fetch import fetch_list

STATE_FILE = Path.home() / ".config" / "quickshell" / "mail_seen.json"
CMD_FILE = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "quickshell.cmd"
POLL_INTERVAL = 45


def load_state() -> dict:
    try:
        return json.loads(STATE_FILE.read_text())
    except (OSError, json.JSONDecodeError):
        return {"seen": [], "notified": {}}


def save_state(state: dict) -> None:
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps(state))


def notify_quickshell(code: str, subject: str) -> None:
    line = f"mailOtp\t{code}\t{subject.replace(chr(9), ' ')}\n"
    try:
        with open(CMD_FILE, "a", encoding="utf-8") as handle:
            handle.write(line)
    except OSError:
        pass


def poll_once() -> int:
    result = fetch_list(limit=12, fetch_body=True)
    if not result.get("configured"):
        return 0
    if result.get("error"):
        return 0

    state = load_state()
    seen = set(state.get("seen") or [])
    notified = state.get("notified") or {}
    alerts = 0

    for mail in result.get("emails") or []:
        mid = mail.get("id")
        code = mail.get("bestCode") or ""
        if not mid:
            continue
        seen.add(mid)
        if not code:
            continue
        key = f"{mid}:{code}"
        if key in notified:
            continue
        notify_quickshell(code, mail.get("subject") or "Verification code")
        notified[key] = int(time.time())
        alerts += 1

    state["seen"] = list(seen)[-200:]
    state["notified"] = {k: v for k, v in list(notified.items())[-200:]}
    save_state(state)
    return alerts


def main():
    if "--once" in sys.argv:
        poll_once()
        return
    while True:
        poll_once()
        time.sleep(POLL_INTERVAL)


if __name__ == "__main__":
    main()
