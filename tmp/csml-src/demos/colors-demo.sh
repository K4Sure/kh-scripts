#!/usr/bin/env bash
set -euo pipefail
if [ -f ./csml.sh ]; then . ./csml.sh; csml::set "demo"; else echo "no csml.sh"; fi
