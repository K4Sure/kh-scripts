#!/usr/bin/env bash
set -euo pipefail
TS=$(date +%Y%m%dT%H%M%S)
REPORT_FILE="_tr_migration_report.txt"
BACKUP_ROOT="_tr_apply_backups_$TS"
mkdir -p "$BACKUP_ROOT"
if [ -f "$REPORT_FILE" ]; then
  FILES="$(cut -d: -f1 "$REPORT_FILE" | sort -u)"
else
  FILES="$(grep -RIl --exclude-dir=.git --exclude-dir=node_modules -E '\btr\b' . || true)"
fi
[ -n "$FILES" ] || { echo "No candidate files found."; exit 0; }
echo "Apply mode: backing up and patching files. Backups -> $BACKUP_ROOT"
changed=0
transform_and_write() {
  local srcfile="$1"
  local tmp
  tmp="$(mktemp)"
  python3 - "$srcfile" > "$tmp" <<'PY' || { echo "Python transform failed for $srcfile"; rm -f "$tmp"; return 1; }
import sys,re
p = sys.argv[1]
with open(p, "rb") as fh:
    src = fh.read().decode("utf-8", "surrogateescape")
out = src
out = re.sub(r"\|\s*tr\s+-d\s+'\\\\r\\\\n'","| python3 -c \"import sys; sys.stdout.write(sys.stdin.read().replace('\\\\r','').replace('\\\\n',''))\"", out)
out = re.sub(r"\|\s*tr\s+-d\s+'\\\\r'","| python3 -c \"import sys; sys.stdout.write(sys.stdin.read().replace('\\\\r',''))\"", out)
out = re.sub(r"\|\s*tr\s+-d\s+'\\\\n'","| python3 -c \"import sys; sys.stdout.write(sys.stdin.read().replace('\\\\n',''))\"", out)
out = re.sub(r'echo\s+("?\$[A-Za-z0-9_@#\{\}\-\+]+\"?)\s*\|\s*tr\s+\'\[:lower:\]\'\s+\'\[:upper:\]\'',
             lambda m: m.group(1) + " | python3 -c \"import sys; sys.stdout.write(sys.stdin.read().upper())\"",
             out)
out = re.sub(r'echo\s+("?\$[A-Za-z0-9_@#\{\}\-\+]+\"?)\s*\|\s*tr\s+\'\[:upper:\]\'\s+\'\[:lower:\]\'',
             lambda m: m.group(1) + " | python3 -c \"import sys; sys.stdout.write(sys.stdin.read().lower())\"",
             out)
out = re.sub(r"\|\s*tr\s+-d\s+'([^\\'])'", r"| sed -E 's/\\1//g'", out)
out = re.sub(r"\|\s*tr\s+'\\\\n'\s+' '", r"| paste -s -d' ' -", out)
out = re.sub(r"printf\s+%\'?%([0-9]+)s\\n\'?\s+\"\"\s*\|\s*tr\s+\" \"\s+\"([^\"]+)\"",
             lambda m: "python3 - <<PY\nprint('" + m.group(2) + "'*"+m.group(1)+")\nPY",
             out)
sys.stdout.write(out)
PY
  if ! cmp -s "$srcfile" "$tmp"; then
    mkdir -p "$BACKUP_ROOT/$(dirname "$srcfile")"
    cp -a "$srcfile" "$BACKUP_ROOT/$srcfile"
    cp -a "$srcfile" "$srcfile.bak"
    mv "$tmp" "$srcfile"
    echo "patched: $srcfile"
    changed=$((changed+1))
  else
    rm -f "$tmp"
  fi
}
while IFS= read -r f; do
  [ -f "$f" ] || continue
  transform_and_write "$f"
done <<< "$FILES"
echo
echo "Apply complete. Files patched: $changed"
echo "Backups saved under: $BACKUP_ROOT (also .bak copies alongside modified files)"
echo 'When ready: git add -A && git commit -m "local: apply tr -> unicode-safe transformations (dry-run approved)"'
