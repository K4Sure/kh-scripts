#!/usr/bin/env bash
set -euo pipefail

DRY_RUN="${DRY_RUN:-0}"
PKG_CMD="${PKG_CMD:-pkg}"
PACKAGES=(git curl python jq)   # edit: add/remove packages you actually want installed

log() { printf "%s | te-install | %s\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$*" >> "'${LOG:-/dev/null}'"; }
run() {
  if [ "${DRY_RUN:-0}" = "1" ]; then
    printf "DRY RUN: %s\n" "$*"
  else
    eval "$@"
  fi
}

echo "→ te-install: starting"
log "start"

# Ensure pkg exists
if ! command -v "$PKG_CMD" >/dev/null 2>&1; then
  log "error: pkg command not found ($PKG_CMD)"
  echo "error: pkg command not found: $PKG_CMD" >&2
  exit 1
fi

# Update repos (safe)
run "$PKG_CMD" update -y
log "pkg update (DRY_RUN=${DRY_RUN})"

# Install packages listed above
if [ "${#PACKAGES[@]}" -gt 0 ]; then
  cmd="$PKG_CMD install -y ${PACKAGES[*]}"
  run $cmd
  log "pkg install ${PACKAGES[*]} (DRY_RUN=${DRY_RUN})"
else
  log "no packages configured for install"
fi

# Place any extra installer steps here (downloads, unpack, symlinks)
# Example (commented): run "curl -L ... | tar xz -C /some/dir"

log "ok"
echo "→ te-install: completed"
exit 0
