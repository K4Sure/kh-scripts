#!/bin/bash
# UTF-8 repeat test (no tr)

echo "=== UTF-8 Safe Repeat Test ==="

# Using printf with brace expansion
printf '%.0s─' {1..10}; echo
printf '%.0s═' {1..10}; echo
printf '%.0s*' {1..10}; echo

# Using function with sed (UTF-8 safe)
repeat_char() {
    local char="$1"
    local count="$2"
    printf "%*s" "$count" "" | sed "s/ /$char/g"
    echo
}

echo
echo "Function method:"
repeat_char "─" 12
repeat_char "═" 12
repeat_char "★" 12
