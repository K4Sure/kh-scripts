#!/bin/bash
# Dynamic Box Master Library (DBML)
# Version: v4.2.3-stable

dbml_version="v4.2.3-stable"

# UTF-8 safe character repeater
repeat_char() {
    local char="$1"
    local count="$2"
    printf "%*s" "$count" "" | sed "s/ /$char/g"
}

# Draw a single box around text (single/double/rounded)
box_draw() {
    local style="$1"
    local text="$2"
    local len=${#text}

    case "$style" in
        single) tl="┌"; tr="┐"; bl="└"; br="┘"; h="─"; v="│";;
        double) tl="╔"; tr="╗"; bl="╚"; br="╝"; h="═"; v="║";;
        rounded) tl="╭"; tr="╮"; bl="╰"; br="╯"; h="─"; v="│";;
        *) echo "Unknown style"; return 1;;
    esac

    printf "%s" "$tl"; repeat_char "$h" "$len"; echo "$tr"
    echo "$v$text$v"
    printf "%s" "$bl"; repeat_char "$h" "$len"; echo "$br"
}

# Draw a box around multiple lines (single/double/rounded)
box_auto() {
    local style="$1"
    shift
    local lines=("$@")

    local max=0
    for line in "${lines[@]}"; do
        (( ${#line} > max )) && max=${#line}
    done

    case "$style" in
        single) tl="┌"; tr="┐"; bl="└"; br="┘"; h="─"; v="│";;
        double) tl="╔"; tr="╗"; bl="╚"; br="╝"; h="═"; v="║";;
        rounded) tl="╭"; tr="╮"; bl="╰"; br="╯"; h="─"; v="│";;
        *) echo "Unknown style"; return 1;;
    esac

    printf "%s" "$tl"; repeat_char "$h" "$max"; echo "$tr"
    for line in "${lines[@]}"; do
        printf "%s%-*s%s\n" "$v" "$max" "$line" "$v"
    done
    printf "%s" "$bl"; repeat_char "$h" "$max"; echo "$br"
}

# Version info
dbml_version() {
    echo "DBML $dbml_version"
}
