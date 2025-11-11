#!/usr/bin/env bash
# script: /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/create-structure-1.0.0.sh
# version: 1.0.0
# description: Create the termux-ecosystem folder tree and placeholder files (idempotent).

set -euo pipefail

TE_ROOT="/data/data/com.termux/files/home/kh-scripts/termux-ecosystem"

dirs=(
  "$TE_ROOT/bin"
  "$TE_ROOT/lib/cml/themes"
  "$TE_ROOT/lib/csml"
  "$TE_ROOT/lib/dbml/presets"
  "$TE_ROOT/lib/pml/wrappers"
  "$TE_ROOT/lib/python-helpers"
  "$TE_ROOT/etc"
  "$TE_ROOT/share/exports"
  "$TE_ROOT/share/banners"
  "$TE_ROOT/share/icons"
  "$TE_ROOT/var/logs/app"
  "$TE_ROOT/var/backups/full"
  "$TE_ROOT/var/backups/incremental"
  "$TE_ROOT/var/archives"
  "$TE_ROOT/var/tmp"
  "$TE_ROOT/tests"
  "$TE_ROOT/examples"
  "$TE_ROOT/docs"
)

echo "Creating termux-ecosystem root at: $TE_ROOT"
for d in "${dirs[@]}"; do
  if [ -d "$d" ]; then
    echo " exists: $d"
  else
    mkdir -p "$d" && echo " created: $d"
  fi
done

# Ensure bin scripts are executable
chmod -R 755 "$TE_ROOT/bin" || true

# Helper to write versioned placeholder scripts with header metadata
write_placeholder() {
  local path="$1"; local script_name="$2"; local version="$3"; local desc="$4"
  if [ -f "$path" ]; then
    echo " exists: $path"
    return
  fi
  cat > "$path" <<'FILE_EOF'
#!/usr/bin/env bash
# script: REPLACE_PATH
# version: REPLACE_VERSION
# description: REPLACE_DESC

set -euo pipefail

# placeholder
FILE_EOF
  sed -i "s|REPLACE_PATH|$script_name|g" "$path"
  sed -i "s|REPLACE_VERSION|$version|g" "$path"
  sed -i "s|REPLACE_DESC|$desc|g" "$path"
  chmod 644 "$path"
  echo " created file: $path"
}

write_placeholder "$TE_ROOT/bin/te-run-1.0.0.sh" "/bin/te-run-1.0.0.sh" "1.0.0" "Launcher wrapper to run user scripts with standardized env."
write_placeholder "$TE_ROOT/bin/te-backup-1.0.0.sh" "/bin/te-backup-1.0.0.sh" "1.0.0" "Create device-transfer ZIP (user-triggered)."
write_placeholder "$TE_ROOT/bin/te-restore-1.0.0.sh" "/bin/te-restore-1.0.0.sh" "1.0.0" "Restore from device-transfer ZIP and run preflight."
write_placeholder "$TE_ROOT/bin/te-log-1.0.0.sh" "/bin/te-log-1.0.0.sh" "1.0.0" "Centralized logging helper and rotator."
write_placeholder "$TE_ROOT/bin/te-preflight-1.0.0.sh" "/bin/te-preflight-1.0.0.sh" "1.0.0" "Preflight checks for required binaries and permissions."

write_placeholder "$TE_ROOT/lib/cml/cml_v1.0.0.sh" "/lib/cml/cml_v1.0.0.sh" "1.0.0" "Color Master Library (TrueColor helpers and themes)."
: > "$TE_ROOT/lib/cml/themes/theme-default_v1.0.0.yaml"
: > "$TE_ROOT/lib/cml/themes/theme-dark_v1.0.0.yaml"

write_placeholder "$TE_ROOT/lib/csml/csml_v1.0.0.sh" "/lib/csml/csml_v1.0.0.sh" "1.0.0" "Characters & Symbols Master Library."
: > "$TE_ROOT/lib/csml/symbols.conf"
: > "$TE_ROOT/lib/csml/symbols_local.conf"

write_placeholder "$TE_ROOT/lib/dbml/dbml_v1.0.0.sh" "/lib/dbml/dbml_v1.0.0.sh" "1.0.0" "Dynamic Box Master Library."
: > "$TE_ROOT/lib/dbml/presets/box-thin_v1.0.0.conf"
: > "$TE_ROOT/lib/dbml/presets/box-thick_v1.0.0.conf"

write_placeholder "$TE_ROOT/lib/pml/pml_v1.0.0.sh" "/lib/pml/pml_v1.0.0.sh" "1.0.0" "Parallel Master Library wrappers."
: > "$TE_ROOT/lib/pml/wrappers/dl-wrapper_v1.0.0.sh"
: > "$TE_ROOT/lib/pml/wrappers/job-runner_v1.0.0.sh"

: > "$TE_ROOT/lib/python-helpers/manifest-gen_v1_0_0.py"
: > "$TE_ROOT/lib/python-helpers/json-tool_v1_0_0.py"

echo "Creating etc and manifest/version placeholders"
cat > "$TE_ROOT/etc/termux-ecosystem-bashrc" <<'BRC'
# file: termux-ecosystem-bashrc
# version: 0.1.0
# description: Environment bootstrap fragment for termux-ecosystem (TE_HOME, PATH, source order).
# (This file is meant to be sourced from your ~/.profile manually.)
BRC

cat > "$TE_ROOT/etc/manifest.json" <<'MNF'
{
  "name": "termux-ecosystem",
  "version": "0.1.0",
  "created": ""
}
MNF

echo "0.1.0" > "$TE_ROOT/etc/version"

echo "Creating docs, examples and tests placeholders"
: > "$TE_ROOT/docs/QUICKSTART.md"
: > "$TE_ROOT/docs/API_CML.md"
: > "$TE_ROOT/docs/API_CSML.md"
: > "$TE_ROOT/docs/API_DBML.md"
: > "$TE_ROOT/docs/API_PML.md"
: > "$TE_ROOT/docs/CHANGELOG.md"

: > "$TE_ROOT/examples/example-downloader-1.0.0.sh"
: > "$TE_ROOT/examples/example-deploy-1.0.0.sh"

: > "$TE_ROOT/tests/test_cml-1.0.0.sh"
: > "$TE_ROOT/tests/test_csml-1.0.0.sh"
: > "$TE_ROOT/tests/test_dbml-1.0.0.sh"
: > "$TE_ROOT/tests/test_pml-1.0.0.sh"

# Ensure placeholders are non-executable except bin
chmod 644 "$TE_ROOT"/lib/*/* || true
chmod 644 "$TE_ROOT"/lib/*/*/* || true
chmod -R 755 "$TE_ROOT/bin" || true

echo "Structure creation complete."
ls -R "$TE_ROOT"
