#!/usr/bin/env bash
set -euo pipefail
if [ -f ./dbml.sh ]; then . ./dbml.sh; dbml::connect "demo"; else echo "no dbml.sh"; fi
