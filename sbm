#!/usr/bin/env bash
# sbm_v2.0.2.sh
# SMART BACKUP MANAGER — FINAL: Keep-active-sbm-safe; move-after-backup; strict archive rules
# - Script stays at: /data/data/com.termux/files/home/kh-scripts
# - All backups go to: /data/data/com.termux/files/home/kh-scripts/backup/<library>
# - Archive for older backups: .../backup/<library>/archive   (standalone archive: .../backup/archive)
# - TIMESTAMP: YYYYMMDD_HHMM
# - NO compression (no .tar.gz/.zip)
# - .sh backup name: <filename>_<version>.sh_<YYYYMMDD_HHMM>.backup
# - After successful snapshot: MOVE older files from source to backup, but KEEP the single LATEST file in source per logical base
# - ACTIVE sbm (INSTALL_DIR/sbm) is NEVER moved by normal backup runs; only replaced by explicit 'install' action.
set -euo pipefail

SBM_VERSION="v2.0.2"
INSTALL_DIR="/data/data/com.termux/files/home/kh-scripts"
INSTALLED_BIN="${INSTALL_DIR}/sbm"
BACKUP_DIR="${INSTALL_DIR}/backup"
KEEP_COUNT=10
LOCKDIR="${BACKUP_DIR}/.sbm_lock.$$"

upper_print() { printf "%s\n" "$(printf "%s" "$1" | awk '{print toupper($0)}')"; }
now_ds_minutes() { date +"%Y%m%d_%H%M"; }   # YYYYMMDD_HHMM

# ----------------- basic helpers -----------------
read_first_lines() { sed -n "1,${1:-120}p" -- "$2" 2>/dev/null || true; }

detect_script_version() {
  local file="$1" ver=""
  if [ -f "$file" ]; then
    ver="$(read_first_lines 120 "$file" \
      | sed -n -E 's/^[[:space:]]*SCRIPT_VERSION[[:space:]]*=[[:space:]]*["'\'']?(v[0-9]+(\.[0-9]+){0,}([A-Za-z0-9._-]*)?)["'\'']?[[:space:]]*$/\1/p' \
      | head -n1 || true)"
    if [ -z "$ver" ]; then
      ver="$(grep -m1 -Eo 'v?[0-9]+(\.[0-9]+){1,}([A-Za-z0-9._-]*)' "$file" 2>/dev/null || true)"
      if [ -n "$ver" ] && [[ "$ver" != v* ]]; then ver="v$ver"; fi
    fi
  fi
  printf "%s" "${ver:-}"
}

detect_library_from_path() {
  local path="$1" lib=""
  if echo "$path" | grep -q "/library/"; then
    lib="$(echo "$path" | sed -E 's@.*/library/([^/]+).*@\1@' | sed -E 's/[^A-Za-z0-9._-]/_/g')"
  else
    local parent
    parent="$(basename "$(dirname -- "$path")")"
    case "${parent,,}" in
      cml|dbml|colors|virustotal) lib="${parent,,}" ;;
      *) lib="" ;;
    esac
  fi
  printf "%s" "${lib:-}"
}

# strip trailing version/timestamp tokens to get logical base
logical_base_name() {
  local fname="$1"
  local base ext
  if [[ "$fname" == *.* ]]; then ext=".${fname##*.}"; base="${fname%.*}"; else ext=""; base="$fname"; fi
  base="$(printf "%s" "$base" | sed -E 's/([_-]v[0-9]+(\.[0-9]+)*.*$)//; s/_[0-9]{8}_[0-9]{4,6}$//')"
  printf "%s" "$base"
}

# semver comparison: return 0 if a >= b
semver_gte() {
  local a="${1#v}" b="${2#v}"
  [ -z "$a" ] && a="0"
  [ -z "$b" ] && b="0"
  IFS='.' read -ra A <<< "$a"
  IFS='.' read -ra B <<< "$b"
  local i max iA iB nA nB sA sB
  max=$(( ${#A[@]} > ${#B[@]} ? ${#A[@]} : ${#B[@]} ))
  for ((i=0;i<max;i++)); do
    iA="${A[i]:-0}"; iB="${B[i]:-0}"
    nA="$(printf "%s" "$iA" | sed -E 's/[^0-9].*$//')"
    nB="$(printf "%s" "$iB" | sed -E 's/[^0-9].*$//')"
    sA="$(printf "%s" "$iA" | sed -E 's/^[0-9]+//')"
    sB="$(printf "%s" "$iB" | sed -E 's/^[0-9]+//')"
    if [ -n "$nA" ] && [ -n "$nB" ]; then
      if [ "$nA" -gt "$nB" ]; then return 0; fi
      if [ "$nA" -lt "$nB" ]; then return 1; fi
    else
      if [ "$iA" \> "$iB" ]; then return 0; fi
      if [ "$iA" \< "$iB" ]; then return 1; fi
    fi
    if [ -n "$sA" ] || [ -n "$sB" ]; then
      if [ "$sA" \> "$sB" ]; then return 0; fi
      if [ "$sA" \< "$sB" ]; then return 1; fi
    fi
  done
  return 0
}

# ----------------- filename rules -----------------
make_moved_backup_name() {
  local src="$1" lib_dir="$2"
  local fn base ext ts ver res
  fn="$(basename -- "$src")"
  ts="$(now_ds_minutes)"
  if [[ "$fn" == *.* ]]; then ext=".${fn##*.}"; base="${fn%.*}"; else ext=""; base="$fn"; fi

  if [ "$ext" = ".sh" ]; then
    ver="$(detect_script_version "$src" || true)"
    [ -z "$ver" ] && ver="noversion"
    res="${lib_dir}/${base}_${ver}.sh_${ts}.backup"
  else
    res="${lib_dir}/${base}_${ts}.backup"
  fi
  printf "%s" "$res"
}

# mask to avoid moving active sbm during source scanning
is_active_sbm_path() {
  local path="$1"
  [ "$(realpath -s "$path" 2>/dev/null || printf "%s" "$path")" = "$(realpath -s "$INSTALLED_BIN" 2>/dev/null || printf "%s" "$INSTALLED_BIN")" ]
}

# ----------------- move + keep latest logic -----------------
move_file_to_backup() {
  local src="$1" lib_dir="$2" dry="$3"
  # never move active sbm during routine moves
  if is_active_sbm_path "$src"; then
    upper_print "✔ KEEP ACTIVE SBM IN PLACE: $(basename -- "$src")"
    return 0
  fi
  mkdir -p "$lib_dir"
  local dest
  dest="$(make_moved_backup_name "$src" "$lib_dir")"
  if [ "$dry" -eq 1 ]; then
    upper_print "ℹ DRY-RUN: WOULD MOVE: $src → $(basename -- "$dest")"
    return 0
  fi
  mv -- "$src" "$dest"
  upper_print "✔ MOVED: $(basename -- "$src") → $(basename -- "$dest")"
}

move_older_and_keep_latest() {
  local src_dir="$1" lib_dir="$2" dry="$3"
  [ -d "$src_dir" ] || return 0
  # gather top-level files only
  local -a files
  mapfile -t files < <(find "$src_dir" -maxdepth 1 -type f -printf '%P\n' 2>/dev/null || true)

  declare -A best_file_by_base
  declare -A best_ver_by_base
  declare -A best_mtime_by_base

  local f absf base ver mtime existing best existing_ver

  for f in "${files[@]}"; do
    absf="${src_dir%/}/$f"
    base="$(logical_base_name "$f")"
    # if this file is the active sbm, mark it as best and never move it
    if is_active_sbm_path "$absf"; then
      best_file_by_base["$base"]="$absf"
      best_ver_by_base["$base"]="ACTIVE_SBM"
      best_mtime_by_base["$base"]="9999999999"
      continue
    fi

    ver="$(detect_script_version "$absf" || true)"
    if [ -z "$ver" ]; then
      mtime="$(stat -c %Y -- "$absf" 2>/dev/null || stat -f %m -- "$absf" 2>/dev/null || echo 0)"
    else
      mtime="$(stat -c %Y -- "$absf" 2>/dev/null || stat -f %m -- "$absf" 2>/dev/null || echo 0)"
    fi

    if [ -z "${best_file_by_base[$base]:-}" ]; then
      best_file_by_base["$base"]="$absf"
      best_ver_by_base["$base"]="$ver"
      best_mtime_by_base["$base"]="$mtime"
      continue
    fi

    existing="${best_file_by_base[$base]}"
    existing_ver="${best_ver_by_base[$base]:-}"

    if [ -n "$ver" ] && [ -n "$existing_ver" ] && [ "$existing_ver" != "ACTIVE_SBM" ]; then
      if semver_gte "$ver" "$existing_ver"; then
        best_file_by_base["$base"]="$absf"
        best_ver_by_base["$base"]="$ver"
        best_mtime_by_base["$base"]="$mtime"
      fi
    elif [ -n "$ver" ] && { [ -z "$existing_ver" ] || [ "$existing_ver" = "ACTIVE_SBM" ]; }; then
      best_file_by_base["$base"]="$absf"
      best_ver_by_base["$base"]="$ver"
      best_mtime_by_base["$base"]="$mtime"
    elif [ -z "$ver" ] && [ -n "$existing_ver" ] && [ "$existing_ver" != "ACTIVE_SBM" ]; then
      # keep existing (versioned) as best
      :
    else
      # both non-versioned or other combos: use mtime
      if [ "$mtime" -ge "${best_mtime_by_base[$base]}" ]; then
        best_file_by_base["$base"]="$absf"
        best_ver_by_base["$base"]="$ver"
        best_mtime_by_base["$base"]="$mtime"
      fi
    fi
  done

  for f in "${files[@]}"; do
    absf="${src_dir%/}/$f"
    base="$(logical_base_name "$f")"
    best="${best_file_by_base[$base]:-}"
    if [ -z "$best" ]; then
      # nothing recorded — keep file
      upper_print "✔ NO BEST FOUND FOR: $(basename -- "$absf") — KEEPING"
      continue
    fi
    if [ "$absf" != "$best" ]; then
      move_file_to_backup "$absf" "$lib_dir" "$dry"
    else
      upper_print "✔ KEEP LATEST IN SOURCE: $(basename -- "$absf")"
    fi
  done
}

# ----------------- copy functions (no compression) -----------------
copy_dir_with_progress() {
  local src="$1" dst="$2" dry="$3"
  mapfile -t _files < <(find "$src" -type f -o -type l 2>/dev/null || true)
  local total=${#_files[@]}
  if [ "$total" -eq 0 ]; then
    [ "$dry" -eq 0 ] && mkdir -p "$dst"
    upper_print "✔ BACKUP COMPLETE: $(basename -- "$dst") (EMPTY DIRECTORY)"
    return 0
  fi
  local i=0
  for f in "${_files[@]}"; do
    i=$((i+1))
    local rel="${f#$src/}"
    local dest_file_dir
    dest_file_dir="$(dirname -- "$dst/$rel")"
    local percent=$(( (i * 100) / total ))
    printf "  %d/%d (%3d%%) %s\n" "$i" "$total" "$percent" "$rel"
    if [ "$dry" -eq 0 ]; then
      mkdir -p "$dest_file_dir"
      if command -v rsync >/dev/null 2>&1; then
        rsync -a --no-compress -- "$f" "$dest_file_dir/" >/dev/null 2>&1 || cp -p -- "$f" "$dest_file_dir/" 2>/dev/null || true
      else
        cp -p -- "$f" "$dest_file_dir/" 2>/dev/null || true
      fi
    fi
  done
  [ "$dry" -eq 0 ] && upper_print "✔ BACKUP COMPLETE: $(basename -- "$dst")" || upper_print "ℹ DRY-RUN COMPLETE: $(basename -- "$dst") (NO FILES COPIED)"
}

copy_file_with_progress() {
  local src="$1" dst="$2" dry="$3"
  printf "  %s\n" "$(basename -- "$src")"
  if [ "$dry" -eq 0 ]; then
    mkdir -p "$(dirname -- "$dst")"
    if command -v rsync >/dev/null 2>&1; then
      rsync -a --no-compress -- "$src" "$dst" >/dev/null 2>&1 || cp -p -- "$src" "$dst"
    else
      cp -p -- "$src" "$dst"
    fi
    upper_print "✔ BACKUP COMPLETE: $(basename -- "$dst")"
  else
    upper_print "ℹ DRY-RUN: WOULD COPY FILE: $(basename -- "$src") → $(basename -- "$dst")"
  fi
}

# ----------------- make snapshot destination -----------------
make_backup_path() {
  local src="$1" fn base_noext ext libsub lib_dir ts target result
  fn="$(basename -- "$src")"
  if [[ "$fn" == *.* ]]; then ext=".${fn##*.}"; base_noext="${fn%.*}"; else ext=""; base_noext="$fn"; fi
  libsub="$(detect_library_from_path "$src" || true)"
  if [ -n "$libsub" ]; then lib_dir="${BACKUP_DIR}/${libsub}"; else lib_dir="${BACKUP_DIR}"; fi
  mkdir -p "$lib_dir"
  ts="$(now_ds_minutes)"
  target="${base_noext}_${ts}.backup"
  result="${lib_dir}/${target}"
  printf "%s" "$result"
}

# ----------------- prune per logical base (move older to archive) -----------------
prune_per_logical() {
  local lib_dir="$1"
  [ -d "$lib_dir" ] || return 0
  local -a entries
  mapfile -t entries < <(find "$lib_dir" -maxdepth 1 -mindepth 1 \( -type d -name '*.backup' -o -type f -name '*.backup' \) -printf '%p\n' 2>/dev/null || true)
  declare -A groups
  local e bn base
  for e in "${entries[@]}"; do
    bn="$(basename -- "$e")"
    base="$(printf "%s" "$bn" | sed -E 's/(_v[0-9]+.*$|_[0-9]{8}_[0-9]{4,6}.*$|_[^.]+\.sh_[0-9]{8}_[0-9]{4,6}.*$)//')"
    [ -z "$base" ] && base="$bn"
    groups["$base"]="${groups[$base]}|$e"
  done

  local base_key items_list arr i sorted it archive_dir
  for base_key in "${!groups[@]}"; do
    items_list="${groups[$base_key]}"
    IFS='|' read -r -a arr <<< "${items_list}"
    if [ -z "${arr[0]}" ]; then arr=("${arr[@]:1}"); fi
    IFS=$'\n' sorted=($(for it in "${arr[@]}"; do [ -n "$it" ] && printf "%s\t%s\n" "$(stat -c %Y "$it" 2>/dev/null || stat -f %m "$it" 2>/dev/null || echo 0)" "$it"; done | sort -rn | awk '{print $2}'))
    i=0
    for it in "${sorted[@]}"; do
      i=$((i+1))
      if [ "$i" -gt "$KEEP_COUNT" ]; then
        archive_dir="${lib_dir}/archive"
        mkdir -p "$archive_dir"
        mv -- "$it" "$archive_dir/" 2>/dev/null || true
        upper_print "✔ ARCHIVED OLD BACKUP: $(basename -- "$it")"
      fi
    done
  done
}

# ----------------- core backup operation per source -----------------
backup_one_impl() {
  local src="$1" dry="$2"
  if [ ! -e "$src" ]; then upper_print "❌ SOURCE NOT FOUND: $src"; return 1; fi
  case "$src" in
    "$BACKUP_DIR" | "$BACKUP_DIR"/*) upper_print "❌ REFUSING TO BACKUP THE BACKUP FOLDER OR ITS CONTENTS: $src"; return 1 ;;
  esac

  local dst
  dst="$(make_backup_path "$src")"

  if [ -d "$src" ]; then
    [ "$dry" -eq 0 ] && mkdir -p "$dst"
    upper_print "✔ BACKING UP DIRECTORY: $src → $(basename -- "$dst")"
    copy_dir_with_progress "$src" "$dst" "$dry"
    local lib_dir
    lib_dir="$(dirname -- "$dst")"
    move_older_and_keep_latest "$src" "$lib_dir" "$dry"
    prune_per_logical "$lib_dir"
    return 0
  fi

  if [ -f "$src" ]; then
    local base_lower
    base_lower="$(basename -- "$src" | awk '{print tolower($0)}')"
    case "$base_lower" in
      *bak*|*backup*) upper_print "ℹ SKIPPING FILE (LOOKS LIKE BACKUP): $(basename -- "$src")"; return 0 ;;
    esac
    local dstfile
    dstfile="$(make_backup_path "$src")"
    mkdir -p "$(dirname -- "$dstfile")"
    upper_print "✔ BACKING UP FILE: $src → $(basename -- "$dstfile")"
    copy_file_with_progress "$src" "$dstfile" "$dry"
    local src_parent lib_dir
    src_parent="$(dirname -- "$src")"
    lib_dir="$(dirname -- "$dstfile")"
    move_older_and_keep_latest "$src_parent" "$lib_dir" "$dry"
    prune_per_logical "$lib_dir"
    return 0
  fi

  upper_print "✔ BACKING UP SPECIAL: $src"
  if [ "$dry" -eq 0 ]; then
    local dstfile
    dstfile="$(make_backup_path "$src")"
    mkdir -p "$(dirname -- "$dstfile")"
    cp -p -- "$src" "$dstfile" 2>/dev/null || true
    move_older_and_keep_latest "$(dirname -- "$src")" "$(dirname -- "$dstfile")" "$dry"
    prune_per_logical "$(dirname -- "$dstfile")"
    upper_print "✔ BACKUP COMPLETE: $(basename -- "$dstfile")"
    return 0
  else
    upper_print "ℹ DRY-RUN: WOULD BACKUP SPECIAL: $src → $(basename -- "$(make_backup_path "$src")")"
    return 0
  fi
}

# ----------------- installer (safe replace; previous copy moved into backup area only on install) -----------------
do_install() {
  if [ ! -f "$0" ]; then upper_print "❌ CANNOT LOCATE SELF PATH TO INSTALL"; exit 1; fi
  mkdir -p "$INSTALL_DIR"
  mkdir -p "$BACKUP_DIR"
  if [ -f "$INSTALLED_BIN" ]; then
    # move previous sbm into backup/sbm/archive naming per strict .sh format
    mkdir -p "${BACKUP_DIR}/sbm/archive"
    existing_ver="$(detect_script_version "$INSTALLED_BIN" || true)"
    if [ -n "$existing_ver" ]; then
      bakname="sbm_${existing_ver}.sh_$(now_ds_minutes).backup"
    else
      bakname="sbm_noversion.sh_$(now_ds_minutes).backup"
    fi
    mv -- "$INSTALLED_BIN" "${BACKUP_DIR}/sbm/archive/${bakname}"
    upper_print "✔ BACKED UP EXISTING: sbm → $(basename -- "${bakname}")"
    # after moving previous sbm we may prune if necessary
    prune_per_logical "${BACKUP_DIR}/sbm"
  fi
  cp -- "$0" "$INSTALLED_BIN"
  chmod +x "$INSTALLED_BIN"
  upper_print "✔ INSTALLED: $INSTALLED_BIN"
  upper_print "✔ NOW CALLABLE AS: sbm <file|dir> OR sbm menu"
}

# ----------------- menu & CLI -----------------
show_header() {
  upper_print "================================================================"
  upper_print " SMART BACKUP MANAGER (SBM) — $SBM_VERSION"
  upper_print " CENTRAL BACKUP: $BACKUP_DIR"
  upper_print "================================================================"
}

# parse args
is_dry_run=0; mode_menu=0
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    install) do_install; exit 0 ;;
    --dry-run|-n) is_dry_run=1; shift ;;
    menu) mode_menu=1; shift ;;
    --keep) KEEP_COUNT="${2:-$KEEP_COUNT}"; shift 2 ;;
    --help|-h) upper_print "USAGE: sbm [--dry-run] <path> ...  OR  sbm menu"; exit 0 ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

show_header

menu_run() {
  upper_print "ENTER PATH TO FILE OR FOLDER TO BACKUP (ABSOLUTE OR RELATIVE): "
  read -r userpath
  if [ -z "$userpath" ]; then upper_print "❌ NO PATH ENTERED. ABORTING."; exit 1; fi
  userpath="${userpath/#\~/$HOME}"
  if [ ! -e "$userpath" ]; then upper_print "❌ PATH NOT FOUND: $userpath"; exit 1; fi
  upper_print "SELECT MODE:"
  printf "  1) DRY-RUN (NO FILES WILL BE COPIED/MOVED)\n  2) RUN-FOR-REAL\n"
  printf "CHOOSE <1|2>: "
  read -r choice
  case "$choice" in
    1) is_dry_run=1 ;;
    2) is_dry_run=0 ;;
    *) upper_print "❌ INVALID CHOICE. ABORTING."; exit 1 ;;
  esac
  upper_print "MODE SELECTED: $( [ "$is_dry_run" -eq 1 ] && printf "DRY-RUN" || printf "REAL" )"
  backup_one_impl "$userpath" "$is_dry_run"
  upper_print "✔ ALL TASKS COMPLETED."
  exit 0
}

if [ "${#ARGS[@]}" -eq 0 ] || [ "$mode_menu" -eq 1 ]; then
  menu_run
  exit 0
fi

# non-interactive run
upper_print "✔ SBM STARTING: $SBM_VERSION"
succ=0; fail=0
for p in "${ARGS[@]}"; do
  if [ "$is_dry_run" -eq 1 ]; then upper_print "ℹ DRY-RUN: WOULD PROCESS: $p"; fi
  if backup_one_impl "$p" "$is_dry_run"; then succ=$((succ+1)); else fail=$((fail+1)); fi
done

upper_print "===== SUMMARY ====="
upper_print "BACKED UP: $succ"
upper_print "FAILED: $fail"
upper_print "✔ ALL TASKS COMPLETED."
exit 0
