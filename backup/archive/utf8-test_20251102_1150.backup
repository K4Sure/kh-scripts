#!/bin/bash
# UTF-8 sanity check

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "=== UTF-8 Box Drawing Test ==="
printf 'Single: %s\n' "┌─┐ │ │ └─┘"
printf 'Double: %s\n' "╔═╗ ║ ║ ╚═╝"
printf 'Rounded: %s\n' "╭─╮ │ │ ╰─╯"

echo
echo "=== UTF-8 Horizontal Lines Test ==="
printf '%10s\n' "" | tr " " "─"
printf '%10s\n' "" | tr " " "═"
