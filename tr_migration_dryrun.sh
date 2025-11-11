#!/usr/bin/env bash
set -euo pipefail
REPORT_FILE="_tr_migration_report.txt"
if [ -f "$REPORT_FILE" ]; then
  FILES="$(cut -d: -f1 "$REPORT_FILE" | sort -u)"
else
  FILES="$(grep -RIl --exclude-dir=.git --exclude-dir=node_modules -E "\btr\b" . || true)"
fi
[ -n "$FILES" ] || { echo "No candidate files found."; exit 0; }
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
echo "Dry-run: scanning $(echo "$FILES" | wc -l) candidate files..."
transform_file() {
  local f="$1"
  python3 - "$f" <<'PY' || exit $?
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
}
changed=0
while IFS= read -r file; do
  [ -f "$file" ] || continue
  tmp="$TMPDIR/$(echo "$file" | sed 's|/|__|g')"
  transform_file "$file" > "$tmp" || { echo "Transform failed for $file"; continue; }
  if ! diff -u --label "a/$file" --label "b/$file.transformed" "$file" "$tmp" >/dev/null 2>&1; then
    echo
    echo "==== Proposed changes for: $file ===="
    diff -u --label "a/$file" --label "b/$file.transformed" "$file" "$tmp" || true
    changed=$((changed+1))
  fi
done <<< "$FILES"
echo
echo "Dry-run complete. Files with proposed changes: $changed"
if [ "$changed" -gt 0 ]; then
  echo "If you approve, ask: generate apply script"
else
  echo "No proposed changes (no conservative pattern matches)."
fi
exit 0
