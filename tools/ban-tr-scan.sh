#!/usr/bin/env bash
set -euo pipefail
echo "Scanning for banned 'tr' usage..."
grep -RIn --exclude-dir=.git '\btr\b' . || echo "No matches found"
