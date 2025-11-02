#!/usr/bin/env bash
# manifest_lint.sh — minimal MANIFEST validator (checks files relative to manifest dir)
set -euo pipefail

manifest="${1:-MANIFEST.yml}"
[ -f "$manifest" ] || { echo "ERR: manifest not found: $manifest" >&2; exit 1; }

manifest_dir="$(cd "$(dirname "$manifest")" && pwd -P)"

# required keys
for key in name version files license; do
  if ! grep -qE "^${key}:" "$manifest"; then
    echo "ERR: missing required key: $key" >&2
    exit 2
  fi
done

# gather exports (if any) and validate namespacing
exports=$(awk '/^exports:/{flag=1; next} /^[[:alnum:]_][[:alnum:][:space:]_-]*:/{ if(flag) flag=0 } flag{gsub(/- /,""); print}' "$manifest" | sed '/^\s*$/d' || true)
if [ -z "$exports" ]; then
  echo "WARN: exports empty or not formatted" >&2
else
  while IFS= read -r exp; do
    exp_trimmed=$(echo "$exp" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$exp_trimmed" ] && continue
    if ! printf '%s' "$exp_trimmed" | grep -q '::'; then
      echo "ERR: exported symbol not namespaced: '$exp_trimmed'" >&2
      exit 3
    fi
  done <<< "$exports"
fi

# validate files listed under 'files:' exist relative to manifest_dir
files=$(awk '/^files:/{flag=1; next} /^[[:alnum:]_][[:alnum:][:space:]_-]*:/{ if(flag) flag=0 } flag{gsub(/- /,""); print}' "$manifest" | sed '/^\s*$/d' || true)
if [ -n "$files" ]; then
  missing=0
  while IFS= read -r f; do
    f_trim=$(echo "$f" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$f_trim" ] && continue
    target="$manifest_dir/$f_trim"
    if [ ! -f "$target" ]; then
      echo "ERR: file listed missing (relative to manifest): $f_trim" >&2
      missing=1
    fi
  done <<< "$files"
  [ "$missing" -eq 0 ] || exit 4
fi

echo "OK: manifest $manifest validated"
exit 0
