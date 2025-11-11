#!/usr/bin/env sh
# manifest-lint v1.1.0 - stricter checks: name, version (vX.Y.Z), type, entry exists
set -eu
FAIL=0
echo "manifest-lint v1.1.0 running..."
for f in $(find manifests -type f -name '*.json' -o -name '*.manifest.json' 2>/dev/null); do
  echo
  echo "Checking: $f"
  # load fields robustly
  name=$(python -c "import json,sys;print(json.load(open('$f')).get('name',''))" 2>/dev/null || echo)
  ver=$(python -c "import json,sys;print(json.load(open('$f')).get('version',''))" 2>/dev/null || echo)
  typ=$(python -c "import json,sys;print(json.load(open('$f')).get('type',''))" 2>/dev/null || echo)
  entry=$(python -c "import json,sys;print(json.load(open('$f')).get('entry',''))" 2>/dev/null || echo)
  ok=1
  if [ -z "$name" ]; then
    echo "ERROR: missing or empty 'name' field in $f"; ok=0
  fi
  if ! echo "$ver" | grep -Eq '^v[0-9]+(\.[0-9]+)*$'; then
    echo "ERROR: 'version' must be semantic token vX.Y.Z in $f (found: '$ver')"; ok=0
  fi
  if [ -z "$typ" ]; then
    echo "ERROR: missing 'type' field in $f"; ok=0
  else
    case "$typ" in
      library|tool|package) : ;; 
      *) echo "ERROR: 'type' must be one of library|tool|package in $f (found: '$typ')"; ok=0 ;;
    esac
  fi
  if [ -z "$entry" ]; then
    echo "ERROR: missing 'entry' field in $f"; ok=0
  else
    # check entry path exists relative to repo root
    if [ ! -f "$entry" ]; then
      echo "ERROR: 'entry' path does not exist: $entry in $f"; ok=0
    fi
  fi
  if [ $ok -ne 1 ]; then
    FAIL=1
  else
    echo "OK: $f"
  fi
done
if [ $FAIL -ne 0 ]; then
  echo; echo "MANIFEST LINT: FAIL"; exit 2
else
  echo; echo "MANIFEST LINT: OK"; exit 0
fi
