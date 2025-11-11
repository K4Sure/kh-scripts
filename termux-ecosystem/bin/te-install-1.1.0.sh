#!/usr/bin/env sh
# te-install v1.1.0 - local-only installer shim with strict validation
set -e
echo "te-install v1.1.0: starting local install checks..."
if ! bin/manifest-lint-1.1.0.sh; then
  echo "te-install: manifest lint failed" >&2
  exit 2
fi
echo "te-install: manifests validated. No network actions performed."
echo "te-install: complete"
