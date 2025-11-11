#!/usr/bin/env sh
# box_renderer v0.1.0 - render a single-line boxed label using a preset
label="${1:-example}"
preset_file="lib/dbml/presets/box-thin_v1.0.0.conf"
border_char="|"
if [ -f "$preset_file" ]; then
  # shell-source preset if it contains simple VAR=val lines
  . "$preset_file" 2>/dev/null || true
fi
printf '%s\n' "${border_char} ${label} ${border_char}"
