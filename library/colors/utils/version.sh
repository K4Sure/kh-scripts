#!/usr/bin/env bash
set -e
VERSION_FILE="${HOME}/kh-scripts/library/colors/.cml_version"
[ ! -f "$VERSION_FILE" ] && echo "v4.0.0" > "$VERSION_FILE"
cur="$(tr -d '\n' < "$VERSION_FILE")"
if [ "$1" = "bump" ]; then
  type="$2"; v="${cur#v}"
  IFS=. read -r MA MI PA <<<"$v"
  case "$type" in
    major) MA=$((MA+1)); MI=0; PA=0;; minor) MI=$((MI+1)); PA=0;; patch) PA=$((PA+1));;
    *) echo "usage: $0 bump [major|minor|patch]"; exit 2;;
  esac
  new="v${MA}.${MI}.${PA}"
  echo "$new" > "$VERSION_FILE"; echo "$new"
else cat "$VERSION_FILE"; fi
