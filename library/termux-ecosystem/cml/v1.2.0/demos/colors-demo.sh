#!/usr/bin/env bash
set -euo pipefail
if [ -r "./cml.sh" ]; then
  . ./cml.sh
  cml::print "colors-demo: red text sample"
else
  echo "colors-demo: no cml.sh found"
fi
