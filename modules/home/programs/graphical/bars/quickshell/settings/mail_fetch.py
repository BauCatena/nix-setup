#!/usr/bin/env python3
"""List recent mail via Himalaya and detect verification codes."""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from mail_common import CONFIG, subprocess_env
from mail_otp import best_code, extract_codes


def run_himalaya(args: list[str], timeout: float = 45.0):
    env = subprocess_env()
    base = ["himalaya", "--output", "json", *args]
    try:
        import subprocess

        result = subprocess.run(
            base,
            capture_output=True,
            text=True,
            timeout=timeout,
            env=env,
        )
        raw = (result.stdout or "").strip()
        if not raw and result.stderr:
            raw = result.stderr.strip()
        if result.returncode != 0:
            err = (result.stderr or result.stdout or "").strip()
            return None, err or f"himalaya exited {result.returncode}"
        if not raw:
            return None, "empty response"
        return json.loads(raw), ""
    except subprocess.TimeoutExpired:
        return None, "timeout"
    except (json.JSONDecodeError, OSError) as exc:
        return None, str(exc)
    except Exception as exc:
        return None, str(exc)


def _normalize_envelopes(data) -> list:
    if isinstance(data, list):
        return data
    if not isinstance(data, dict):
        return []
    for key in ("envelopes", "data", "results", "items"):
        val = data.get(key)
        if isinstance(val, list):
            return val
    return []


def _sender_name(sender) -> str:
    if isinstance(sender, list):
        return _sender_name(sender[0]) if sender else "?"
    if isinstance(sender, dict):
        return sender.get("name") or sender.get("address") or "?"
    return str(sender) if sender else "?"


def _flag_seen(flags) -> bool:
    if not flags:
        return False
    for flag in flags:
        name = (flag if isinstance(flag, str) else str(flag)).lower()
        if name in ("seen", "\\seen"):
            return True
    return False


def envelope_fields(env: dict):
    eid = env.get("id") or env.get("hash") or env.get("envelope_id")
    subject = env.get("subject") or ""
    from_str = _sender_name(env.get("from") or env.get("sender"))
    date = env.get("date") or env.get("received_at") or ""
    unseen = not _flag_seen(env.get("flags"))
    return eid, from_str, subject, date, unseen


def read_body(eid) -> str:
    data, _ = run_himalaya(["message", "read", str(eid)], timeout=60.0)
    if not data:
        return ""
    if isinstance(data, str):
        return data
    if isinstance(data, dict):
        for key in ("text", "body", "content", "plain"):
            if data.get(key):
                return str(data[key])
        parts = data.get("parts") or data.get("messages")
        if isinstance(parts, list):
            chunks = []
            for part in parts:
                if isinstance(part, dict):
                    for key in ("text", "body", "content"):
                        if part.get(key):
                            chunks.append(str(part[key]))
            return "\n".join(chunks)
        return json.dumps(data)
    if isinstance(data, list):
        chunks = []
        for part in data:
            if isinstance(part, dict):
                for key in ("text", "body", "content"):
                    if part.get(key):
                        chunks.append(str(part[key]))
            elif isinstance(part, str):
                chunks.append(part)
        return "\n".join(chunks)
    return str(data)


def fetch_list(limit: int = 20, fetch_body: bool = True) -> dict:
    if not CONFIG.is_file():
        return {
            "configured": False,
            "error": "Run: himalaya (wizard) or copy config.toml.example to ~/.config/himalaya/config.toml",
            "emails": [],
        }

    data, err = run_himalaya(["envelope", "list", "--page-size", str(limit)])
    if data is None:
        return {"configured": True, "error": err, "emails": []}

    envelopes = _normalize_envelopes(data)

    emails = []
    for env in envelopes:
        if not isinstance(env, dict):
            continue
        eid, from_str, subject, date, unseen = envelope_fields(env)
        if not eid:
            continue
        blob = subject
        codes = extract_codes(subject)
        if fetch_body and not codes:
            body = read_body(eid)
            blob = f"{subject}\n{body[:6000]}"
            codes = extract_codes(blob)
        emails.append({
            "id": str(eid),
            "from": from_str,
            "subject": subject,
            "date": date,
            "unseen": unseen,
            "codes": codes,
            "bestCode": best_code(codes),
            "preview": (subject or blob)[:140],
        })
    return {"configured": True, "error": "", "emails": emails}


def main():
    limit = 20
    if "--limit" in sys.argv:
        limit = int(sys.argv[sys.argv.index("--limit") + 1])
    fetch_body = "--no-body" not in sys.argv
    print(json.dumps(fetch_list(limit=limit, fetch_body=fetch_body)))


if __name__ == "__main__":
    main()
