#!/usr/bin/env sh
# dev-setup - bootstrap local developer conveniences (no network)
set -e
echo "Dev helper - commands available:"
echo " - bin/ci-local.sh        : run full local CI (lint, tests, smoke)"
echo " - bin/te-run-1.1.0.sh --smoke-check : run preflight smoke checks"
echo " - bin/manifest-fix-1.0.0.sh [--apply] : suggest or apply manifest fixes"
echo " - bin/te-lib-smoke-1.5.0.sh : run library smoke tests"
echo
echo "Ensure scripts are executable (they should be). To run CI: bin/ci-local.sh"
exit 0
