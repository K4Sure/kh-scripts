#!/bin/bash
# Dynamic Box Master Library (DBML)
# Version: v4.2.2
# Location: ~/kh-scripts/library/dynamic_box/dynamic_box.sh
# Dependency: CSML (for UTF-8 symbols)

# Backup previous version
cp -f ~/kh-scripts/library/dynamic_box/dynamic_box.sh ~/kh-scripts/backup/dynamic_box.sh 2>/dev/null

dbml_version() {
  echo "DBML v4.2.2"
}

# Borders map
declare -A BOX_BORDERS=(
  [single_tl]="┌" [single_tr]="┐" [single_bl]="└" [single_br]="┘" [single_h]="─" [single_v]="│"
  [double_tl]="╔" [double_tr]="╗" [double_bl]="╚" [double_br]="╝" [double_h]="═" [double_v]="║"
  [rounded_tl]="╭" [rounded_tr]="╮" [rounded_bl]="╰" [rounded_br]="╯" [rounded_h]="─" [rounded_v]="│"
)

# Draw a box given type/width/height/content (| separates lines)
draw_box() {
  local type="$1" width="$2" height="$3" content="$4"
  local tl="${BOX_BORDERS[${type}_tl]}"
  local tr="${BOX_BORDERS[${type}_tr]}"
  local bl="${BOX_BORDERS[${type}_bl]}"
  local br="${BOX_BORDERS[${type}_br]}"
  local h="${BOX_BORDERS[${type}_h]}"
  local v="${BOX_BORDERS[${type}_v]}"

  # Top border
  printf "%s" "$tl"
  for ((i=0; i<width; i++)); do printf "%s" "$h"; done
  printf "%s\n" "$tr"

  # Content
  IFS='|' read -r -a lines <<< "$content"
  for line in "${lines[@]}"; do
    local pad=$((width - ${#line}))
    printf "%s%s%*s%s\n" "$v" "$line" "$pad" "" "$v"
  done

  # Bottom border
  printf "%s" "$bl"
  for ((i=0; i<width; i++)); do printf "%s" "$h"; done
  printf "%s\n" "$br"
}

# Auto-size a box around text
box_auto() {
  local type="${1:-single}"
  local content="$2"
  IFS='|' read -r -a lines <<< "$content"
  local maxlen=0
  for l in "${lines[@]}"; do
    (( ${#l} > maxlen )) && maxlen=${#l}
  done
  draw_box "$type" "$maxlen" "${#lines[@]}" "$content"
}

# Word-wrapping box
box_wrap() {
  local type="${1:-single}"
  local width="${2:-16}"
  local content="$3"
  local -a pieces=()

  IFS=$'|' read -r -a segs <<< "$content"

  local seg words cur maxlen
  maxlen=$width

  for seg in "${segs[@]}"; do
    read -r -a words <<< "$seg"
    cur=""
    for w in "${words[@]}"; do
      (( ${#w} > maxlen )) && maxlen=${#w}
      if [[ -z "$cur" ]]; then
        cur="$w"
      elif (( ${#cur} + 1 + ${#w} <= width )); then
        cur="$cur $w"
      else
        pieces+=("$cur")
        cur="$w"
      fi
    done
    [[ -n "$cur" ]] && pieces+=("$cur")
  done

  width=$maxlen
  local result=""
  for i in "${!pieces[@]}"; do
    result+="${pieces[i]}"
    (( i < ${#pieces[@]}-1 )) && result+="|"
  done
  draw_box "$type" "$width" "${#pieces[@]}" "$result"
}
