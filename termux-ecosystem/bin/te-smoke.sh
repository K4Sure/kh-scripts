# Branded Shim Wrapper
#!/usr/bin/env bash
# te-smoke.sh
# version: 1.0.3
# description: smoke-test runner for generated placeholders only
# notes: no subshell pipelines; stable counters; clear summary

set -euo pipefail
ECOROOT="/data/data/com.termux/files/home/kh-scripts/termux-ecosystem"
PASS=0; FAIL=0
TIMEOUT="${TIMEOUT:-15}"

tmpout="$(mktemp -t te-smoke.XXXXXX)" || tmpout="/tmp/te-smoke.$$"
trap 'rm -f "$tmpout"' EXIT

info() { printf "  %s\n" "$*"; }
ok()   { printf "✅ %s\n" "$*"; ((PASS++)); }
err()  { printf "❌ %s\n" "$*"; ((FAIL++)); }

trim() { sed 's/^[[:space:]]*//;s/[[:space:]]*$//' <<<"$1"; }

run_exec_placeholder() {
  local path="$1" name="$2"
  if [ ! -x "$path" ]; then err "Not executable: $path"; return 1; fi
  if timeout "$TIMEOUT" "$path" >"$tmpout" 2>&1; then
    local out; out="$(sed -n '1p' "$tmpout" || true)"
    out="$(trim "$out")"
    if [ "$out" = "${name} placeholder executed" ]; then
      ok "$path -> ok"
      return 0
    else
      err "$path -> unexpected output: ${out:-<empty>}"
      return 1
    fi
  else
    err "$path -> execution failed"
    return 1
  fi
}

run_python_placeholder() {
  local path="$1" name="$2"
  if [ -x "$path" ]; then
    run_exec_placeholder "$path" "$name"
    return $?
  fi
  if timeout "$TIMEOUT" python3 "$path" >"$tmpout" 2>&1; then
    local out; out="$(sed -n '1p' "$tmpout" || true)"
    out="$(trim "$out")"
    if [ "$out" = "${name} placeholder executed" ]; then
      ok "$path -> ok"
    else
      err "$path -> unexpected output: ${out:-<empty>}"
    fi
  else
    err "$path -> execution failed"
    return 1
  fi
}

check_text_placeholder() {
  local path="$1"
  if [ ! -f "$path" ]; then err "Missing file: $path"; return 1; fi
  if grep -qE '^# version: [0-9]+\.[0-9]+\.[0-9]+$' "$path"; then
    local v; v="$(sed -n 's/^# version: //p' "$path" | sed -n '1p')"
    v="$(trim "$v")"
    ok "$path -> version ${v}"
    return 0
  else
    err "$path -> missing version header"
    return 1
  fi
}

gather_files() {
  # args: find args; outputs paths via echo (one per line)
  find "$@" 2>/dev/null
}

echo "  Running placeholder smoke tests..."

# 1) Bin placeholders
info "Checking bin placeholders..."
mapfile -t bin_files < <(gather_files "${ECOROOT}/bin" -maxdepth 1 -type f -name '*-[0-9].[0-9].[0-9].sh')
for f in "${bin_files[@]}"; do
  [ -n "${f:-}" ] || continue
  if ! grep -q 'placeholder executed' "$f"; then info "Skip non-placeholder: $f"; continue; fi
  base="$(basename "$f" .sh)"; name="${base%-*}"
  run_exec_placeholder "$f" "$name" || true
done

# 2) Python placeholders
info "Checking python placeholders..."
mapfile -t py_files < <(gather_files "${ECOROOT}/lib/python-helpers" -maxdepth 1 -type f -name '*_v[0-9_]*.py')
for f in "${py_files[@]}"; do
  [ -n "${f:-}" ] || continue
  if ! grep -q 'placeholder executed' "$f"; then info "Skip non-placeholder: $f"; continue; fi
  base="$(basename "$f")"
  name="$(echo "$base" | sed -E 's/_v[0-9_]+\.py$//')"
  run_python_placeholder "$f" "$name" || true
done

# 3) Lib shell placeholders
info "Checking lib shell placeholders..."
for lib in cml pml dbml bmc; do
  mapfile -t sh_files < <(gather_files "${ECOROOT}/lib/${lib}" -maxdepth 1 -type f -name '*_[0-9].[0-9].[0-9].sh')
  for f in "${sh_files[@]}"; do
    [ -n "${f:-}" ] || continue
    if ! grep -q 'placeholder executed' "$f"; then info "Skip non-placeholder: $f"; continue; fi
    base="$(basename "$f")"
    name="$(echo "$base" | sed -E 's/_[0-9]\.[0-9]\.[0-9]\.sh$//')"
    run_exec_placeholder "$f" "$name" || true
  done
done

# 4) YAML themes
info "Checking YAML theme placeholders..."
mapfile -t yaml_files < <(gather_files "${ECOROOT}/lib" -type f -path '*/themes/*_v*.yaml')
for f in "${yaml_files[@]}"; do
  [ -n "${f:-}" ] || continue
  check_text_placeholder "$f" || true
done

# 5) CONF presets
info "Checking CONF preset placeholders..."
mapfile -t conf_files < <(gather_files "${ECOROOT}/lib" -type f -path '*/presets/*_v*.conf')
for f in "${conf_files[@]}"; do
  [ -n "${f:-}" ] || continue
  check_text_placeholder "$f" || true
done

echo
printf "Summary: %s passed, %s failed\n" "$PASS" "$FAIL"
if [ "$FAIL" -gt 0 ]; then
  echo "Placeholder smoke tests found failures."
  exit 2
else
  echo "All placeholder smoke tests passed."
  exit 0
fi
