# ==============================
# Dynamic Box Master Library (DBML)
# Version: v4.2.3
# Location: ~/kh-scripts/library/dynamic_box/dynamic_box.sh
# Backup:   ~/kh-scripts/backup/dynamic_box_v4.2.3.sh
# ==============================

# Backup old version
cp ~/kh-scripts/library/dynamic_box/dynamic_box.sh ~/kh-scripts/backup/dynamic_box_v4.2.3.sh 2>/dev/null

# Draw box (core function)
draw_box() {
    local style="$1" width="$2"; shift 2
    local lines=("$@")
    local tl tr bl br h v

    case "$style" in
        single)  tl="┌"; tr="┐"; bl="└"; br="┘"; h="─"; v="│";;
        double)  tl="╔"; tr="╗"; bl="╚"; br="╝"; h="═"; v="║";;
        rounded) tl="╭"; tr="╮"; bl="╰"; br="╯"; h="─"; v="│";;
        *)       tl="+"; tr="+"; bl="+"; br="+"; h="-"; v="|";;
    esac

    # Top border
    printf "%s" "$tl"
    printf "%${width}s" "" | tr " " "$h"
    printf "%s\n" "$tr"

    # Content
    for line in "${lines[@]}"; do
        printf "%s %-*s %s\n" "$v" "$((width-2))" "$line" "$v"
    done

    # Bottom border
    printf "%s" "$bl"
    printf "%${width}s" "" | tr " " "$h"
    printf "%s\n" "$br"
}

# Auto-size box
box_auto() {
    local style="$1" text="$2"
    IFS="|" read -r -a parts <<< "$text"
    local maxlen=0
    for part in "${parts[@]}"; do
        (( ${#part} > maxlen )) && maxlen=${#part}
    done
    draw_box "$style" $((maxlen+2)) "${parts[@]}"
}

# Wrap text into a box
box_wrap() {
    local style="$1" width="$2" text="$3"
    local -a lines=()
    local line=""

    for word in $text; do
        if (( ${#line} + ${#word} + 1 > width-2 )); then
            lines+=("$line")
            line="$word"
        else
            line="${line:+$line }$word"
        fi
    done
    [[ -n "$line" ]] && lines+=("$line")

    draw_box "$style" "$width" "${lines[@]}"
}

# Version
dbml_version() {
    echo "DBML v4.2.3"
}
