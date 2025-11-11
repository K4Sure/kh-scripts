#!/usr/bin/env sh
set -e
f="$1"
tmp="$f.tmp.$$"
: > "$tmp"
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    *'|'*'lib/cml/src/cml_palette_v0.3.0.sh'*)
      # if line already has a trailing " -" (space dash) after the script args, leave it
      echo "$line" | grep -Eq 'lib/cml/src/cml_palette_v0\.3\.0\.sh.*[[:space:]]-$' && {
        printf '%s\n' "$line" >> "$tmp"
        continue
      }
      # otherwise, append " -" at the end of the line
      printf '%s -\n' "$line" >> "$tmp"
      ;;
    *)
      printf '%s\n' "$line" >> "$tmp"
      ;;
  esac
done < "$f"
mv "$tmp" "$f"
