#!/usr/bin/env python3
import json, sys, pathlib

root = pathlib.Path(__file__).resolve().parents[2]
manifest_path = root / "manifest.json"

def die(msg):
    print("error:", msg, file=sys.stderr)
    sys.exit(1)

if not manifest_path.exists():
    die(f"manifest not found: {manifest_path}")

try:
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
except Exception as e:
    die(f"invalid json: {e}")

# Basic validation and defaults
name = data.get("name") or "termux-ecosystem"
version = data.get("version") or "0.0.0"
components = data.get("components") or {}
components.setdefault("bins", [])
components.setdefault("libs", [])
components.setdefault("themes", [])

out = {
    "name": name,
    "version": version,
    "description": data.get("description", ""),
    "components": components
}

# Write normalized manifest
manifest_path.write_text(json.dumps(out, indent=2, sort_keys=True) + "\n", encoding="utf-8")
print("manifest normalized:", manifest_path)
