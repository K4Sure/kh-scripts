#!/usr/bin/env sh
# box_preset v0.3.1 - render multi-line box with align (left|center|right), padding and border styles
preset_name="${1:-box-wide}"
label="${2:-hello}"
width="${3:-40}"
align="${4:-center}"   # left | center | right
pad="${5:-1}"          # vertical padding lines
preset="lib/dbml/presets/${preset_name}_v1.0.0.conf"
border_style="single"
[ -f "$preset" ] && . "$preset" 2>/dev/null || true

# draw horizontal border
inner=$((width-2))
hline() {
  case "$border_style" in
    double) printf '╔'; for i in $(seq 1 $inner); do printf '═'; done; printf '╗\n' ;;
    single) printf '+'; for i in $(seq 1 $inner); do printf '-'; done; printf '+\n' ;;
    thick)  printf '┌'; for i in $(seq 1 $inner); do printf '─'; done; printf '┐\n' ;;
    *) printf '+'; for i in $(seq 1 $inner); do printf '-'; done; printf '+\n' ;;
  esac
}

pad_line() {
  case "$border_style" in
    double) left="║"; right="║" ;;
    single) left="|"; right="|" ;;
    thick) left="│"; right="│" ;;
    *) left="|"; right="|" ;;
  esac
  printf '%s' "$left"
  printf '%*s' "$inner" ''
  printf '%s\n' "$right"
}

# wrap: pass label into awk via -v for correct expansion and robust wrapping
wrap() {
  awk -v w="$inner" -v lbl="$label" '
  {
    # split lbl into words and wrap to width w
    n=split(lbl, a, /[[:space:]]+/)
    line=""
    for(i=1;i<=n;i++){
      word=a[i]
      if(length(line)==0) { line=word }
      else if(length(line)+1+length(word) <= w) { line=line " " word }
      else { print line; line=word }
    }
    if(length(line)) print line
  }
  ' <<'AWK'
placeholder
AWK
}

hline
for i in $(seq 1 $pad); do pad_line; done
wrap_out="$(wrap)"
echo "$wrap_out" | while IFS= read -r l; do
  len=${#l}
  case "$align" in
    left) leftpad=0; rightpad=$((inner-len)) ;;
    right) leftpad=$((inner-len)); rightpad=0 ;;
    *) leftpad=$(( (inner - len) / 2 )); rightpad=$(( inner - len - leftpad )) ;;
  esac
  case "$border_style" in
    double) left="║"; right="║" ;;
    single) left="|"; right="|" ;;
    thick) left="│"; right="│" ;;
    *) left="|"; right="|" ;;
  esac
  printf '%s' "$left"
  printf '%*s' "$leftpad" ''
  printf '%s' "$l"
  printf '%*s' "$rightpad" ''
  printf '%s\n' "$right"
done
for i in $(seq 1 $pad); do pad_line; done
hline
