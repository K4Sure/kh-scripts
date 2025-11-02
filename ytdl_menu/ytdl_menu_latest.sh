#!/data/data/com.termux/files/usr/bin/bash
# ytdl_menu_v3.5.2.sh — Kelvin's Branded Download Menu (Session-aware Retention, Neon UI)
# Full, copy-pasteable, Termux-ready single file.
set -Eeuo pipefail

# ------------------------------------------------------------------
# VERSION & ROOTS
VERSION="DOWNLOAD MENU v3.5.2"

# Primary download root (Termux-friendly)
HOME_DL="$HOME/Download/Social Media"
LOGS_DIR="$HOME_DL/Logs"
QUEUE_DIR="$LOGS_DIR/Queue Files"
STATE_FILE="$QUEUE_DIR/url_state.txt"
AUDITLOG="$LOGS_DIR/ytdl_menu.log"
RUNLOG="$LOGS_DIR/run.log"

# Profile persistence
PROFILEFILE="$HOME/.currentprofile"

ARCHIVEROOT="$HOME_DL/Archives"
DOWNLOADROOT="$HOME_DL"
COOKIES_ROOT="$HOME_DL/Cookies"

QUEUE_FILE="$QUEUE_DIR/ytdl_queue.txt"
QUEUE_NEXT="$QUEUE_DIR/ytdl_queue.next"

# Limits
LOG_SIZE_LIMIT=$((10 * 1024 * 1024))
ARCHIVE_SIZE_LIMIT=$((5 * 1024 * 1024))

# ------------------------------------------------------------------
# SESSION / STATE (per-URL persistent across runs)
declare -A RUN_COUNT       # number of sessions this URL has been retained (0,1,2)
declare -A PREV_SUCCESS    # cumulative successes counted at end of last session for this URL
declare -A URL_META_TOTAL  # expected total items (Y) from "Downloading item X of Y"
declare -A URL_SUM_SUCCESS # cumulative successes as of end of this run (for summary)

# Per-URL media counters (session-only)
declare -A URL_VID_SUCC URL_AUD_SUCC URL_PHO_SUCC
declare -A URL_VID_FAIL URL_AUD_FAIL URL_PHO_FAIL

# Global media counters (this session)
TOTAL_VIDEOS_SUCCESS=0
TOTAL_VIDEOS_FAIL=0
TOTAL_AUDIOS_SUCCESS=0
TOTAL_AUDIOS_FAIL=0
TOTAL_PHOTOS_SUCCESS=0
TOTAL_PHOTOS_FAIL=0

# ------------------------------------------------------------------
# COLOURS (neon + truecolor snippets where used)
RESET='\e[0m'
FERRARI_RED='\e[38;2;255;0;0m'
NEON_YELLOW='\e[38;5;226m'
NEON_PINK='\e[38;5;213m'
NEON_BLUE='\e[38;5;27m'
NEON_CYAN='\e[38;5;51m'
NEON_GREEN='\e[38;5;46m'
NEON_ORANGE_BRIGHT='\e[38;5;208m'
NEON_ORANGE_DARK='\e[38;5;202m'
BRIGHT_RED='\e[38;5;196m'

NEON_PALETTE=(
  "\e[38;5;196m" "\e[38;5;202m" "\e[38;5;208m" "\e[38;5;214m"
  "\e[38;5;220m" "\e[38;5;190m" "\e[38;5;46m"  "\e[38;5;45m"
  "\e[38;5;51m"  "\e[38;5;99m"  "\e[38;5;201m" "\e[38;5;93m"
)

# yt-dlp global options (tuned)
GLOBAL_OPTS=(
  --format bv*+ba/b
  --merge-output-format mp4
  --min-sleep-interval 0
  --max-sleep-interval 2
  --retries 3
  --fragment-retries 3
  --extractor-retries 3
  --yes-playlist
  --max-downloads 100
  --embed-metadata
  --embed-thumbnail
  --continue
  --concurrent-fragments 10
)

# ------------------------------------------------------------------
# UTILITIES

say(){ printf '%s\n' "$*"; }

# banner: uppercase without using tr (tr is banned per preference)
banner(){
  local text="$1"
  local upper="${text^^}"
  printf '\e[1;31m===[ %s ]===\e[0m\n' "$upper"
}

log(){
  mkdir -p "$LOGS_DIR"
  echo "$(date '+%d-%m-%Y %I:%M %p') [YTDLMENU] $*" >> "$AUDITLOG"
}

ensure_dir(){ mkdir -p "$1"; }

ensure_writable(){
  local d="$1"; mkdir -p "$d"
  local t="$d/.writetest.$$"
  if : >"$t" 2>/dev/null; then rm -f "$t"; echo "$d"; else echo ""; fi
}

rotate_if_needed(){
  local f="$1" lim="$2" max=5
  if [[ -f "$f" ]]; then
    local sz; sz=$(stat -c%s "$f" 2>/dev/null || wc -c < "$f")
    if (( sz > lim )); then
      cp "$f" "$f.$(date +%Y%m%d_%H%M%S).bak"
      : > "$f"
      ls -t "$f".*.bak 2>/dev/null | tail -n +$((max+1)) | xargs -r rm -f
      log "Rotated $(basename "$f") size=$sz"
    fi
  fi
}

get_random_neon(){
  local idx=$(( RANDOM % ${#NEON_PALETTE[@]} ))
  printf '%b' "${NEON_PALETTE[$idx]}"
}

shorten(){
  local p="$1"; p="${p/#$HOME/\~}"; p="${p/#\/storage\/emulated\/0/\~}"
  echo "$p"
}

# ------------------------------------------------------------------
# STATE LOAD / SAVE

load_state(){
  RUN_COUNT=(); PREV_SUCCESS=(); URL_META_TOTAL=()
  [[ -f "$STATE_FILE" ]] || return
  while IFS='|' read -r url run prev tot; do
    [[ -z "$url" ]] && continue
    RUN_COUNT["$url"]="${run:-0}"
    PREV_SUCCESS["$url"]="${prev:-0}"
    URL_META_TOTAL["$url"]="${tot:-0}"
  done < "$STATE_FILE"
}

save_state(){
  ensure_dir "$QUEUE_DIR"
  : > "$STATE_FILE"
  for url in "${!RUN_COUNT[@]}"; do
    printf '%s|%s|%s|%s\n' \
      "$url" "${RUN_COUNT[$url]:-0}" "${PREV_SUCCESS[$url]:-0}" "${URL_META_TOTAL[$url]:-0}" \
      >> "$STATE_FILE"
  done
}

# ------------------------------------------------------------------
# PROFILE SELECTION

choose_profile(){
  banner "$VERSION"
  banner "PROFILE SELECTION"
  echo
  echo -e "\e[1;34m⟨ 1 ⟩  SONIC SOUND\e[0m"
  echo -e "\e[1;35m⟨ 2 ⟩  CINEMAX VISUAL\e[0m"
  echo -e "\e[1;32m⟨ 3 ⟩  ANDROID MATRIX\e[0m"
  echo
  echo -e "${BRIGHT_RED}===[ ❌ PRESS \"ESC\" TO ABORT ALL & EXIT ❌ ]===${RESET}"
  echo
  IFS= read -rsn1 k
  [[ -z "$k" || "$k" == $'\e' ]] && say "[ABORT]" && exit 0
  case "$k" in
    1) PROFILE="SONIC SOUND";    PROFILE_COLOR="\e[1;34m" ;;
    2) PROFILE="CINEMAX VISUAL"; PROFILE_COLOR="\e[1;35m" ;;
    3) PROFILE="ANDROID MATRIX"; PROFILE_COLOR="\e[1;32m" ;;
    *) say "[ERROR] INVALID CHOICE"; exit 1 ;;
  esac
  echo "$PROFILE" > "$PROFILEFILE"
  echo
  echo -e "${NEON_PINK}===[ ${VERSION} |${RESET}${PROFILE_COLOR}| ${PROFILE} ]===${RESET}"
  echo
}

# ------------------------------------------------------------------
# URL ENTRY

get_url(){
  echo -e "${NEON_YELLOW}INSERT URL(s) & PRESS \"ENTER\" TWICE TO START DOWNLOADING${RESET}"
  echo
  echo -e "${BRIGHT_RED}===[ ❌ PRESS \"ESC\" TO ABORT ALL & EXIT ❌ ]===${RESET}"
  echo
  URLS=()
  while true; do
    printf "${NEON_BLUE}URL(s) : ${RESET}"
    read -r raw
    [[ "$raw" == $'\e' ]] && say "[ABORT]" && exit 0
    [[ -z "$raw" ]] && break
    for url in $raw; do
      url=${url//\"/}
      [[ "$url" == http* ]] || { printf "${BRIGHT_RED}[INVALID URL]: %s${RESET}\n" "$url"; continue; }
      grep -qFx "$url" "$QUEUE_FILE" 2>/dev/null && { printf "\e[1;33m[DUPLICATE] : %s${RESET}\n" "$url"; continue; }
      URLS+=("$url")
      printf "${NEON_CYAN}[ADDED] : %s${RESET}\n" "$url"
    done
  done
  [[ ${#URLS[@]} -eq 0 ]] && say "[ABORT] NO URLs" && exit 1
  ensure_dir "$QUEUE_DIR"
  printf "%s\n" "${URLS[@]}" >> "$QUEUE_FILE"
  echo
  printf "\e[1;32mTOTAL URLs ADDED: %d${RESET}\n" "${#URLS[@]}"
  echo
}

# ------------------------------------------------------------------
# SITE DETECTION & PATHS

detect_site(){
  case "$URL" in
    *tiktok.com*)            SITE="tiktok";       SITE_NAME="TikTok" ;;
    *music.youtube.com*)     SITE="youtubemusic"; SITE_NAME="YouTube Music" ;;
    *youtube.com*|*youtu.be*)SITE="youtube";      SITE_NAME="YouTube" ;;
    *instagram.com*)         SITE="instagram";    SITE_NAME="Instagram" ;;
    *facebook.com*)          SITE="facebook";     SITE_NAME="Facebook" ;;
    *)                       SITE="generic";      SITE_NAME="Generic" ;;
  esac
  local aroot droot
  aroot=$(ensure_writable "$ARCHIVEROOT"); [[ -z "$aroot" ]] && aroot=$(ensure_writable "$DOWNLOADROOT/Archives")
  ARCHIVEFILE="$aroot/${SITE}_archive.txt"; ensure_dir "$(dirname "$ARCHIVEFILE")"
  droot=$(ensure_writable "$DOWNLOADROOT"); [[ -z "$droot" ]] && droot=$(ensure_writable "$DOWNLOADROOT") || true
  OUTPUT_DIR="$droot/$SITE_NAME"; ensure_dir "$OUTPUT_DIR"
  COOKIESFILE="$COOKIES_ROOT/${SITE}_cookies.txt"
  if [[ -f "$COOKIESFILE" ]]; then COOKIESOPT=(--cookies "$COOKIESFILE"); else COOKIESOPT=(); fi
}

# ------------------------------------------------------------------
# ADD URL DURING DOWNLOAD

add_url_during_download(){
  printf "\n${NEON_BLUE}URL(s) : ${RESET}"
  read -r raw
  [[ -z "$raw" ]] && return
  for url in $raw; do
    url=${url//\"/}
    [[ "$url" == http* ]] || { printf "${BRIGHT_RED}[INVALID URL]: %s${RESET}\n" "$url"; continue; }
    grep -qFx "$url" "$QUEUE_FILE" 2>/dev/null && { printf "\e[1;33m[DUPLICATE] : %s${RESET}\n" "$url"; continue; }
    echo "$url" >> "$QUEUE_FILE"
    printf "${NEON_CYAN}[ADDED] : %s${RESET}\n" "$url"
  done
  echo
}

# ------------------------------------------------------------------
# CONTROLS TABLE

display_control_table(){
  echo -e "\e[1;36mCONTROLS${RESET}"
  printf "\e[1;33m%-10s${RESET} \e[1;35m%-20s${RESET} \e[1;32m%-10s${RESET}\n" "KEY" "ACTION" "RESUME"
  printf "\e[1;33m%-10s${RESET} \e[1;35m%-20s${RESET} \e[1;32m%-10s${RESET}\n" "Enter" "Execute / Confirm" ""
  printf "\e[1;33m%-10s${RESET} \e[1;35m%-20s${RESET} \e[1;32m%-10s${RESET}\n" "Space" "Add URL" ""
  printf "\e[1;33m%-10s${RESET} \e[1;35m%-20s${RESET} \e[1;32m%-10s${RESET}\n" "S or s" "Skip URL" "No"
  printf "\e[1;33m%-10s${RESET} \e[1;35m%-20s${RESET} \e[1;32m%-10s${RESET}\n" "A or a" "Abort Task" "Yes"
  printf "\e[1;33m%-10s${RESET} \e[1;35m%-20s${RESET} \e[1;32m%-10s${RESET}\n" "P or p" "Pause Task" "Yes"
  printf "\e[1;33m%-10s${RESET} \e[1;35m%-20s${RESET} \e[1;32m%-10s${RESET}\n" "R or r" "Resume Task" "Yes"
  printf "\e[1;33m%-10s${RESET} \e[1;35m%-20s${RESET} \e[1;32m%-10s${RESET}\n" "Esc" "Clear History & Exit" "No"
  echo
}

# ------------------------------------------------------------------
# SPINNER WITH PERCENT-COLOURS

spin_with_status(){
  local pid="$1" status_file="$2" url_color="$3"
  local frames='⠁⠂⠄⡀⡈⡐⡠⣀⣁⣂⣄⣌⣔⣤⣥⣦⣮⣶⣷⣿'
  local i=0 len=${#frames}

  printf "%bCURRENT URL: %s%b\n\n" "$url_color" "$URL" "$RESET"
  command -v tput >/dev/null 2>&1 && tput civis || true

  while kill -0 "$pid" 2>/dev/null; do
    i=$(((i+1)%len))
    local msg; msg=$(cat "$status_file" 2>/dev/null || echo "WORKING...")
    local perc; perc=$(grep -o '[0-9]\+\(\.[0-9]\+\)\?%' <<<"$msg" | tr -d '%' || true)
    perc=${perc:-0}; local ip=${perc%.*}
    local col="$url_color"
    (( ip >= 35 )) && col="$NEON_YELLOW"
    (( ip >= 80 )) && col="$NEON_ORANGE_BRIGHT"
    (( ip >= 99 )) && col="$NEON_ORANGE_DARK"
    (( ip >= 100 )) && col="$NEON_GREEN"
    printf "\r%b[%c]%b %s" "$col" "${frames:i:1}" "$RESET" "$msg"

    if read -t 0.1 -rsn1 key; then
      case "$key" in
        s|S) kill "$pid" 2>/dev/null || true; USER_ACTION=skip; break ;;
        p|P) kill "$pid" 2>/dev/null || true; USER_ACTION=pause; break ;;
        a|A) kill "$pid" 2>/dev/null || true; USER_ACTION=abort; break ;;
        '')  echo; break ;;
        ' ') echo; add_url_during_download ;;
        $'\e')
          echo; printf "\n${BRIGHT_RED}ABORTING & CLEARING...${RESET}\n"
          kill "$pid" 2>/dev/null || true
          USER_ACTION=clear
          rm -f "$QUEUE_FILE" "$QUEUE_NEXT"
          exit 0
          ;;
      esac
    fi
    sleep 0.1
  done

  command -v tput >/dev/null 2>&1 && tput cnorm || true
  echo
}

# ------------------------------------------------------------------
# RUN A SINGLE URL ACTION (DOWNLOAD)

run_action(){
  local url_color="$1"; url_color="${url_color:-$NEON_YELLOW}"
  local STATUS_FILE; STATUS_FILE="$(mktemp)"
  : > "$STATUS_FILE"

  # Reset per-URL counters (this session)
  URL_VID_SUCC["$URL"]=0; URL_AUD_SUCC["$URL"]=0; URL_PHO_SUCC["$URL"]=0
  URL_VID_FAIL["$URL"]=0; URL_AUD_FAIL["$URL"]=0; URL_PHO_FAIL["$URL"]=0

  local TOT_OBS=0

  # Prepare log
  ensure_dir "$LOGS_DIR"
  rotate_if_needed "$RUNLOG" "$LOG_SIZE_LIMIT"
  rotate_if_needed "$ARCHIVEFILE" "$ARCHIVE_SIZE_LIMIT"

  # Launch yt-dlp and tail for status
  (
    yt-dlp -i "${GLOBAL_OPTS[@]}" "${COOKIESOPT[@]}" \
      --download-archive "$ARCHIVEFILE" \
      --progress-template "PRG %(progress.percentstr)s ETA %(progress.etastr)s SPD %(progress.speedstr)s" \
      -o "$OUTPUT_DIR/%(uploader)s/%(uploader)s_%(autonumber)03d.%(ext)s" \
      "$URL"
  ) >> "$RUNLOG" 2>&1 &
  local DL_PID=$!

  # Tail parser
  (
    tail -n0 -F "$RUNLOG" 2>/dev/null | while IFS= read -r line; do
      # Progress to status
      if [[ "$line" == PRG* ]]; then
        printf " %s" "$line" > "$STATUS_FILE"
      fi

      # Total items pattern
      if [[ "$line" =~ Downloading[[:space:]]item[[:space:]]([0-9]+)[[:space:]]of[[:space:]]([0-9]+) ]]; then
        TOT_OBS="${BASH_REMATCH[2]}"
        URL_META_TOTAL["$URL"]="$TOT_OBS"
      fi

      # Success by extension (Destination: ...)
      if [[ "$line" =~ Destination:\ (.*) ]]; then
        file="${BASH_REMATCH[1]}"
        case "$file" in
          *.mp4|*.mkv|*.webm) URL_VID_SUCC["$URL"]=$(( URL_VID_SUCC["$URL"] + 1 )) ;;
          *.mp3|*.m4a|*.aac|*.opus) URL_AUD_SUCC["$URL"]=$(( URL_AUD_SUCC["$URL"] + 1 )) ;;
          *.jpg|*.jpeg|*.png|*.gif|*.webp) URL_PHO_SUCC["$URL"]=$(( URL_PHO_SUCC["$URL"] + 1 )) ;;
        esac
      fi

      # Failures (heuristic)
      if [[ "$line" == *"ERROR"* || "$line" == *"unable to"* || "$line" == *"HTTP Error"* ]]; then
        case "$line" in
          *.mp4*|*.mkv*|*.webm*) URL_VID_FAIL["$URL"]=$(( URL_VID_FAIL["$URL"] + 1 )) ;;
          *.mp3*|*.m4a*|*.aac*|*.opus*) URL_AUD_FAIL["$URL"]=$(( URL_AUD_FAIL["$URL"] + 1 )) ;;
          *.jpg*|*.jpeg*|*.png*|*.gif*|*.webp*) URL_PHO_FAIL["$URL"]=$(( URL_PHO_FAIL["$URL"] + 1 )) ;;
          *) URL_VID_FAIL["$URL"]=$(( URL_VID_FAIL["$URL"] + 1 )) ;; # default
        esac
      fi
    done
  ) &
  local TAIL_PID=$!

  # Show spinner until done or action
  USER_ACTION=""
  spin_with_status "$DL_PID" "$STATUS_FILE" "$url_color"
  wait "$DL_PID" || true
  kill "$TAIL_PID" 2>/dev/null || true
  rm -f "$STATUS_FILE" 2>/dev/null || true

  # Return totals for this URL (session)
  local vids=${URL_VID_SUCC["$URL"]:-0}
  local auds=${URL_AUD_SUCC["$URL"]:-0}
  local phos=${URL_PHO_SUCC["$URL"]:-0}
  local vfail=${URL_VID_FAIL["$URL"]:-0}
  local afail=${URL_AUD_FAIL["$URL"]:-0}
  local pfail=${URL_PHO_FAIL["$URL"]:-0}
  local succ=$(( vids + auds + phos ))

  # Update globals
  TOTAL_VIDEOS_SUCCESS=$(( TOTAL_VIDEOS_SUCCESS + vids ))
  TOTAL_VIDEOS_FAIL=$(( TOTAL_VIDEOS_FAIL + vfail ))
  TOTAL_AUDIOS_SUCCESS=$(( TOTAL_AUDIOS_SUCCESS + auds ))
  TOTAL_AUDIOS_FAIL=$(( TOTAL_AUDIOS_FAIL + afail ))
  TOTAL_PHOTOS_SUCCESS=$(( TOTAL_PHOTOS_SUCCESS + phos ))
  TOTAL_PHOTOS_FAIL=$(( TOTAL_PHOTOS_FAIL + pfail ))

  # Ensure a sensible total if not observed
  if [[ -z "${URL_META_TOTAL["$URL"]:-}" || "${URL_META_TOTAL["$URL"]}" -le 0 ]]; then
    local approx_total=$(( succ + vfail + afail + pfail ))
    URL_META_TOTAL["$URL"]="$approx_total"
  fi

  # Compute cumulative successes (for retention comparison)
  local prev_cum=${PREV_SUCCESS["$URL"]:-0}
  local new_cum=$(( prev_cum + succ ))
  PREV_SUCCESS["$URL"]="$new_cum"
  URL_SUM_SUCCESS["$URL"]="$new_cum"

  # Post-action handling
  case "$USER_ACTION" in
    skip)  return 0 ;;
    pause) return 0 ;;
    abort) return 0 ;;
    clear) return 0 ;;
  esac
}

# ------------------------------------------------------------------
# PROCESS QUEUE (with clear, corrected retention logic)

process_queue(){
  load_state
  display_control_table

  banner "PROCESSING QUEUE"
  local total_at_start
  total_at_start=$(wc -l < "$QUEUE_FILE" 2>/dev/null || echo 0)
  printf "\e[1;33mQUEUE CONTAINS %d URLs${RESET}\n\n" "$total_at_start"

  : > "$QUEUE_NEXT"
  local index=1

  while IFS= read -r URL || [[ -n "$URL" ]]; do
    [[ -z "$URL" ]] && continue

    detect_site

    local url_color; url_color=$(get_random_neon)
    printf "\e[1;33mDOWNLOADING URL %d of %d : %b%s%b\n\n" \
      "$index" "$total_at_start" "$url_color" "$URL" "$RESET"

    # Capture previous cumulative successes before running
    local prev_before=${PREV_SUCCESS["$URL"]:-0}

    run_action "$url_color"

    # After run_action, PREV_SUCCESS["$URL"] holds the updated cumulative successes
    local runs=${RUN_COUNT["$URL"]:-0}
    local cum=${PREV_SUCCESS["$URL"]:-0}
    local tot=${URL_META_TOTAL["$URL"]:-0}
    local inc=$(( cum - prev_before ))

    # Retention decision:
    if (( tot > 0 && cum >= tot )); then
      # Completed — do not retain
      unset RUN_COUNT["$URL"] PREV_SUCCESS["$URL"] URL_META_TOTAL["$URL"]
    else
      # Not complete — retention policy: Allow up to 2 retention runs (runs = 0 -> set 1, runs = 1 -> set 2 if progress)
      if (( runs == 0 )); then
        RUN_COUNT["$URL"]=1
        echo "$URL" >> "$QUEUE_NEXT"
      elif (( runs == 1 )); then
        if (( inc > 0 )); then
          RUN_COUNT["$URL"]=2
          echo "$URL" >> "$QUEUE_NEXT"
        else
          # no progress; drop from retention
          unset RUN_COUNT["$URL"] PREV_SUCCESS["$URL"] URL_META_TOTAL["$URL"]
        fi
      else
        # runs >= 2 -> drop
        unset RUN_COUNT["$URL"] PREV_SUCCESS["$URL"] URL_META_TOTAL["$URL"]
      fi
    fi

    # Branded random delay if more URLs remain
    index=$((index+1))
    if (( index <= total_at_start )); then
      local RAND_SLEEP=$((RANDOM % 10 + 1))
      echo
      printf "${FERRARI_RED}SLEEPING FOR %d SECONDS (PRESS ENTER TO RESUME NOW)...${RESET}\n\n" "$RAND_SLEEP"
      local spin=( "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏" )
      for ((sec=0; sec<RAND_SLEEP; sec++)); do
        for f in "${spin[@]}"; do
          if read -t 0.1 -n1 -r key; then
            if [[ -z "$key" ]]; then
              echo; printf "\e[1;32mRESUMING DOWNLOAD NOW...${RESET}\n\n"
              sec=$RAND_SLEEP
              break
            elif [[ "$key" == " " ]]; then
              add_url_during_download
            elif [[ "$key" == $'\e' ]]; then
              echo; printf "${BRIGHT_RED}ABORTING & CLEARING...${RESET}\n"
              rm -f "$QUEUE_FILE" "$QUEUE_NEXT"
              exit 0
            fi
          fi
          # gradient color for countdown uses truecolor where available
          local r=$((255 - (sec * 10))); local g=$((sec * 10))
          (( r < 200 )) && r=200; (( g > 215 )) && g=215
          printf "\r\e[38;2;%d;%d;0m%s %2d SECONDS REMAINING${RESET}" "$r" "$g" "$f" "$((RAND_SLEEP-sec))"
        done
      done
      echo
    fi
  done < "$QUEUE_FILE"

  # Replace queue with retained URLs
  mv -f "$QUEUE_NEXT" "$QUEUE_FILE" 2>/dev/null || true
  save_state

  # Session summary
  echo
  for url in "${!URL_SUM_SUCCESS[@]}"; do
    local user="${url##*@}"
    local succ="${URL_SUM_SUCCESS[$url]:-0}"
    local tot="${URL_META_TOTAL[$url]:-0}"
    [[ $succ -gt 0 || $tot -gt 0 ]] && printf "\e[1;33m• @%s : %d of %d${RESET}\n" "$user" "$succ" "$tot"
  done
  echo
  printf "${NEON_GREEN}»››››› TOTAL VIDEOS DOWNLOADED : %d${RESET}\n" "$TOTAL_VIDEOS_SUCCESS"
  printf "${BRIGHT_RED}›»›››› TOTAL VIDEOS FAILED     : %d${RESET}\n" "$TOTAL_VIDEOS_FAIL"
  printf "${NEON_GREEN}››»››› TOTAL AUDIOS DOWNLOADED : %d${RESET}\n" "$TOTAL_AUDIOS_SUCCESS"
  printf "${BRIGHT_RED}›››»›› TOTAL AUDIOS FAILED     : %d${RESET}\n" "$TOTAL_AUDIOS_FAIL"
  printf "${NEON_GREEN}››››»› TOTAL PHOTOS DOWNLOADED : %d${RESET}\n" "$TOTAL_PHOTOS_SUCCESS"
  printf "${BRIGHT_RED}›››››» TOTAL PHOTOS FAILED     : %d${RESET}\n" "$TOTAL_PHOTOS_FAIL"

  local retained
  retained=$(wc -l < "$QUEUE_FILE" 2>/dev/null || echo 0)
  local touched="${#URL_SUM_SUCCESS[@]}"
  printf "\e[1;33m»»»» TOTAL URL(s) RETAINED FOR NEXT SESSION : %d of %d${RESET}\n" "$retained" "$touched"

  echo
  printf "${NEON_GREEN}ALL TASKS COMPLETED — RETURNING TO TERMINAL${RESET}\n"
  echo
}

# ------------------------------------------------------------------
# MAIN

ensure_dir "$LOGS_DIR"
ensure_dir "$QUEUE_DIR"
rotate_if_needed "$AUDITLOG" "$LOG_SIZE_LIMIT"

# Load or choose profile
if [[ -f "$PROFILEFILE" ]]; then
  PROFILE=$(<"$PROFILEFILE")
  case "$PROFILE" in
    "SONIC SOUND")    PROFILE_COLOR="\e[1;34m" ;;
    "CINEMAX VISUAL") PROFILE_COLOR="\e[1;35m" ;;
    "ANDROID MATRIX") PROFILE_COLOR="\e[1;32m" ;;
    *) PROFILE_COLOR="\e[1;37m" ;;
  esac
else
  choose_profile
fi

# If queue exists, process it; otherwise, collect URLs then process
if [[ -f "$QUEUE_FILE" && -s "$QUEUE_FILE" ]]; then
  process_queue
else
  choose_profile
  echo
  echo -e "${BRIGHT_RED}===[ ❌ PRESS \"ESC\" TO ABORT ALL & EXIT ❌ ]===${RESET}"
  echo
  echo -e "${NEON_YELLOW}INSERT URL(s) & PRESS \"ENTER\" TWICE TO START DOWNLOADING${RESET}"
  echo
  get_url
  process_queue
fi
