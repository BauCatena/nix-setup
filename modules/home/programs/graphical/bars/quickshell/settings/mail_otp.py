#!/usr/bin/env python3
"""OTP / verification code extraction from email text."""
import re

PATTERNS = [
    (0.95, re.compile(
        r"(?i)(?:verification|security|confirm(?:ation)?|auth(?:entication)?|"
        r"login|access|otp|pin|codigo|código|code)[:\s\-–—]+([0-9]{4,8})"
    )),
    (0.92, re.compile(r"(?i)(?:your|el|tu)\s+(?:code|codigo|código)\s+(?:is|es)[:\s]+([0-9]{4,8})")),
    (0.88, re.compile(r"(?i)\b([0-9]{6})\b(?=.*(?:expir|valid|minute|minuto|hour))")),
    (0.65, re.compile(r"(?i)\b([A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4})\b")),
    (0.55, re.compile(r"\b([0-9]{6})\b")),
]


def extract_codes(text: str) -> list[dict]:
    if not text:
        return []
    found: dict[str, float] = {}
    for confidence, pattern in PATTERNS:
        for match in pattern.finditer(text):
            code = match.group(1).strip()
            if len(code) < 4:
                continue
            if code not in found or found[code] < confidence:
                found[code] = confidence
    items = [{"code": code, "confidence": conf} for code, conf in found.items()]
    items.sort(key=lambda item: -item["confidence"])
    return items


def best_code(codes: list[dict]) -> str:
    return codes[0]["code"] if codes else ""
