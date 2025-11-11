#!/usr/bin/env python3
"""
cml_palette_swatch_v0.1.0.py
TrueColor swatches, emoji header, timestamped audit logging.
Reads normalized key:hex lines from stdin and writes colored swatches to stdout.
"""
import sys
import re
import datetime
from pathlib import Path

LOG_PATH = Path("logs/swatches.log")
HEX_RE = re.compile(r'^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})$')

def now_ts():
    return datetime.datetime.now().strftime("%Y%m%dT%H%M%S")

def hex2rgb(h):
    h = h.lstrip('#')
    if len(h) == 3:
        h = ''.join(ch * 2 for ch in h)
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)

def log_line(s):
    try:
        LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
        with LOG_PATH.open("a", encoding="utf-8") as fh:
            fh.write(s + "\n")
    except Exception:
        pass

def emit_swatch(key, hexv):
    r, g, b = hex2rgb(hexv)
    ESC = "\x1b"
    escs = f"{ESC}[38;2;{r};{g};{b}m{ESC}[48;2;{r};{g};{b}m"
    reset = f"{ESC}[0m"
    block = "████████"
    label = f"{key:<3} {hexv:<8} {block}"
    sys.stdout.write(f"{escs}{label}{reset}\n")
    sys.stdout.flush()

def main():
    ts = now_ts()
    log_line(f"[{ts}] cml_palette_swatch run")
    sys.stdout.write("🎨  Palette swatches\n")
    for raw in sys.stdin:
        line = raw.rstrip("\n\r")
        if not line or ":" not in line:
            continue
        key, val = line.split(":", 1)
        key = key.strip().lower()
        val = val.strip()
        if val.startswith('"') and val.endswith('"') and len(val) >= 2:
            val = val[1:-1]
        if HEX_RE.match(val):
            try:
                emit_swatch(key, val)
                log_line(f"[{ts}] {key} {val}")
            except Exception as e:
                sys.stderr.write(f"WARNING: failed to render {key} {val}: {e}\n")
                log_line(f"[{ts}] RENDER_ERR {key} {val}")
        else:
            sys.stderr.write(f"WARNING: invalid hex for {key}: {val}\n")
            log_line(f"[{ts}] INVALID {key} {val}")

if __name__ == "__main__":
    main()
