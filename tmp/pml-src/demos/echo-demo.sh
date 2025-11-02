#!/usr/bin/env bash
set -euo pipefail
if [ -f ./pml.sh ]; then . ./pml.sh; pml::echo "demo"; else echo "no pml.sh"; fi
