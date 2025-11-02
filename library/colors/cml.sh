#!/usr/bin/env bash
CML_VERSION="v4.0.0"

cml::reset() { printf '\033[0m'; }
CML_RESET="$(cml::reset)"

cml::ansi() { local codes="$*"; printf "\033[%sm" "$codes"; }
cml::fg256() { printf "\033[38;5;%sm" "$1"; }
cml::bg256() { printf "\033[48;5;%sm" "$1"; }
cml::rgb() {
  local mode="$1"; shift
  local r="$1" g="$2" b="$3"
  [ "$mode" = "fg" ] && printf "\033[38;2;%s;%s;%sm" "$r" "$g" "$b" || \
  printf "\033[48;2;%s;%s;%sm" "$r" "$g" "$b"
}

CML_THEME_DIR="${HOME}/kh-scripts/library/colors/themes"
CML_THEME="classic"

cml::load_theme_file() { [ -f "$1" ] && source "$1"; }
cml::set_theme() {
  local theme="$1"; [ -z "$theme" ] && theme="$CML_THEME"
  local tf="$CML_THEME_DIR/${theme}.theme"
  if cml::load_theme_file "$tf"; then CML_THEME="$theme"; else
    echo "CML: theme '$theme' not found" >&2; return 1; fi
}

: ${CML_FG_PRIMARY:="$(cml::ansi 39)"}
: ${CML_BG_PRIMARY:="$(cml::ansi 49)"}
: ${CML_ACCENT:="$(cml::ansi 36)"}
: ${CML_RESET:="$(cml::reset)"}

cml::print() { local text="$1"; shift; printf "%b%s%b\n" "$2" "$text" "$CML_RESET"; }
cml::palette_from_indexes() { local prefix="$1"; shift; local idx=1; for i in "$@"; do eval "CML_${prefix}_IDX_${idx}=$i"; idx=$((idx+1)); done; }
cml::current_version() { printf "%s\n" "$CML_VERSION"; }

export -f cml::ansi cml::fg256 cml::bg256 cml::rgb cml::set_theme cml::print cml::palette_from_indexes cml::current_version

[ -d "$CML_THEME_DIR" ] && cml::set_theme "$CML_THEME" >/dev/null 2>&1 || true
