#!/usr/bin/env sh
# te-run v1.1.0 - runner that executes full smoke checks, fails fast with codes
set -e
case "$1" in
  --smoke-check)
    echo "te-run: running manifest linter..."
    if ! bin/manifest-lint-1.1.0.sh; then
      echo "te-run: manifest lint failed" >&2
      exit 2
    fi
    echo "te-run: running lib smoke..."
    if ! bin/te-lib-smoke-1.5.0.sh; then
      echo "te-run: lib smoke failed" >&2
      exit 3
    fi
    echo "te-run: full smoke passed"
    exit 0
    ;;
  *)
    echo "Usage: $0 --smoke-check"
    exit 1
    ;;
esac
