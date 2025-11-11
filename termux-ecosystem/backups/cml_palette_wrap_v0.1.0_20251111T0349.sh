#!/usr/bin/env sh
# cml_palette wrapper: enforces "-" when stdin is piped, preserves last-wins
set -e
script="lib/cml/src/cml_palette_v0.3.0.sh"
# If stdin is piped and no explicit "-" is present, append "-"
if [ ! -t 0 ]; then
  case " $* " in
    *" - "*) ;; # already present
    *) exec "$script" "$@" - ;;
  esac
fi
exec "$script" "$@"
