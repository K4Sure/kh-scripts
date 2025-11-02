#!/data/data/com.termux/files/usr/bin/bash
# TERMUX APT & PKG HELPER - STRICT BRAND SPEC
# - Title box: surprise TrueColor RGB each refresh
# - Hot-key menu: instant single-digit, supports two-digit (10–14) with short timeout
# - Global ESC abort: menu and any input prompts
# - Case 9: mini-title with dividers 4 chars longer than text, surprise RGB, blank line before Package Name
# - Maintainer values: TrueColor RGB cyan
# - Homepage/APT-Sources values: light blue
# - ✔ Yes = green, ✘ No = pink, numbers = bright green, other values = surprise RGB
# - Suppress apt CLI WARNING line

ESC="\033"
RESET="${ESC}[0m"

# FIXED COLORS
CREAM="${ESC}[38;2;255;253;208m"
YELLOWCREAM="${ESC}[38;2;255;255;153m"
ORANGE="${ESC}[38;2;255;200;120m"
BRIGHTRED="${ESC}[38;2;255;0;0m"
LIGHTBLUE="${ESC}[38;2;135;206;250m"
YELLOW="${ESC}[38;2;255;255;0m"
GREEN="${ESC}[38;2;0;255;0m"
PINK="${ESC}[38;2;255;105;180m"
BRIGHTGREEN="${ESC}[38;2;0;255;128m"
CYAN="${ESC}[38;2;0;230;255m"

# RANDOM COLOR FUNCTION (bright spectrum)
rand_color() {
  R=$((128 + RANDOM % 128))
  G=$((128 + RANDOM % 128))
  B=$((128 + RANDOM % 128))
  echo "${ESC}[38;2;${R};${G};${B}m"
}

# Safe prompt read that aborts on ESC; captures raw ESC without Enter
safe_read() {
  local prompt="$1"
  local __outvar="$2"
  local key rest

  # Show prompt
  echo -ne "$prompt"

  # First key (raw)
  IFS= read -rsn1 key
  # ESC abort
  if [[ "$key" == $'\e' ]]; then
    echo
    echo -e "\n🚪 Exiting Helper..."
    exit 0
  fi
  # Enter -> empty
  if [[ "$key" == $'\n' ]]; then
    printf -v "$__outvar" "%s" ""
    return 0
  fi

  # Echo the first key so it appears after the prompt
  echo -n "$key"

  # Read the rest of the line until Enter (editable)
  IFS= read -r rest
  printf -v "$__outvar" "%s" "$key$rest"
}

# Hot-key choice: instant first digit; short timeout for optional second digit
read_choice_hotkey() {
  local first second choice timeout=0.6

  echo -ne "${CREAM}                                                                  Choose An Option [ 1 — 14 ]:${RESET} "
  # Read first key instantly
  IFS= read -rsn1 first
  # ESC abort
  if [[ "$first" == $'\e' ]]; then
    echo
    echo -e "\n🚪 Exiting Helper..."
    echo
    exit 0
  fi

  choice="$first"

  # Try capture second digit within timeout for 10–14
  if IFS= read -rsn1 -t "$timeout" second; then
    if [[ "$second" =~ [0-9] ]]; then
      choice="${first}${second}"
      # Echo both digits inline
      printf "%s\n\n" "$choice"
    else
      # Non-digit pressed; echo first and move on
      printf "%s\n\n" "$choice"
    fi
  else
    # No second key in time; echo first and move on
    printf "%s\n\n" "$choice"
  fi

  # Return via global variable
  MENU_CHOICE="$choice"
}

while true; do
    TITLE_COLOR="$(rand_color)"

    clear
    echo -e "${TITLE_COLOR}===============================${RESET}"
    echo -e "${TITLE_COLOR} 📦 TERMUX APT & PKG HELPER 🆘${RESET}"
    echo -e "${TITLE_COLOR}===============================${RESET}"
    echo

    # MENU
    printf "  ${CREAM}%-2s${RESET} 🌀  ${YELLOWCREAM}apt update${RESET}             ${ORANGE}- Refresh Package Index${RESET}\n"  "1"
    printf "  ${CREAM}%-2s${RESET} ⬆️   ${YELLOWCREAM}apt upgrade${RESET}            ${ORANGE}- Upgrade All Packages${RESET}\n"  "2"
    printf "  ${CREAM}%-2s${RESET} 📥  ${YELLOWCREAM}apt / pkg install${RESET}      ${ORANGE}- Install A Package${RESET}\n"  "3"
    printf "  ${CREAM}%-2s${RESET} ❌  ${YELLOWCREAM}apt remove${RESET}             ${ORANGE}- Remove A Package${RESET}\n"  "4"
    printf "  ${CREAM}%-2s${RESET} ❎  ${YELLOWCREAM}pkg uninstall${RESET}          ${ORANGE}- Remove A Package${RESET}\n"  "5"
    printf "  ${CREAM}%-2s${RESET} 🧹  ${YELLOWCREAM}apt purge${RESET}              ${ORANGE}- Remove Package + Configs${RESET}\n"  "6"
    printf "  ${CREAM}%-2s${RESET} 🚮  ${YELLOWCREAM}apt autoremove${RESET}         ${ORANGE}- Clean Unused Dependencies${RESET}\n"  "7"
    printf "  ${CREAM}%-2s${RESET} 🔍  ${YELLOWCREAM}apt search${RESET}             ${ORANGE}- Search For A Package${RESET}\n"  "8"
    printf "  ${CREAM}%-2s${RESET} 📖  ${YELLOWCREAM}apt show${RESET}               ${ORANGE}- Show Package Info${RESET}\n"  "9"
    printf "  ${CREAM}%-2s${RESET} 📋  ${YELLOWCREAM}apt list --installed${RESET}   ${ORANGE}- List Installed Packages${RESET}\n" "10"
    printf "  ${CREAM}%-2s${RESET} 🔄  ${YELLOWCREAM}apt list --upgradable${RESET}  ${ORANGE}- List Upgradable Packages${RESET}\n" "11"
    printf "  ${CREAM}%-2s${RESET} 🧽  ${YELLOWCREAM}apt clean${RESET}              ${ORANGE}- Clear Package Cache${RESET}\n" "12"
    printf "  ${CREAM}%-2s${RESET} 🧲  ${ORANGE}APT Combos${RESET}             ${YELLOWCREAM}- apt update && apt upgrade${RESET}\n" "13"
    printf "  ${CREAM}%-2s${RESET} ⚔️   ${ORANGE}PKG Doubles${RESET}            ${YELLOWCREAM}- pkg update && pkg upgrade${RESET}\n" "14"

    echo
    echo -e "${BRIGHTRED}                                                                  Press ESC To Abort & Exit.....${RESET}"

    # Read choice with hot-key + two-digit timeout
    read_choice_hotkey
    choice="$MENU_CHOICE"

    case "$choice" in
        1) apt update ;;
        2) apt upgrade -y ;;
        3) safe_read "Package Name: " pkg; echo; apt install -y "$pkg" ;;
        4) safe_read "Package Name: " pkg; echo; apt remove -y "$pkg" ;;
        5) safe_read "Package Name: " pkg; echo; pkg uninstall -y "$pkg" ;;
        6) safe_read "Package Name: " pkg; echo; apt purge -y "$pkg" ;;
        7) apt autoremove -y ;;
        8) safe_read "Search Term: " term; echo; apt search "$term" ;;
        9)
           MINI_COLOR="$(rand_color)"
           TITLE_TEXT=" 📦 SHOW PACKAGE INFO ℹ️"
           TITLE_LEN=${#TITLE_TEXT}
           LINE_LEN=$((TITLE_LEN + 4))   # 4 chars longer than text line
           LINE=$(printf '%.0s–' $(seq 1 $LINE_LEN))

           echo -e "${MINI_COLOR}${LINE}${RESET}"
           echo -e "${MINI_COLOR}${TITLE_TEXT}${RESET}"
           echo -e "${MINI_COLOR}${LINE}${RESET}"
           echo

           safe_read "Package Name: " pkg
           echo
           apt show "$pkg" | while IFS= read -r line; do
               # Suppress apt CLI warning
               if [[ "$line" =~ ^WARNING ]]; then
                   continue
               elif [[ "$line" =~ ^Maintainer: ]]; then
                   key=${line%%:*}
                   val=${line#*: }
                   echo -e "${YELLOW}${key}:${RESET} ${CYAN}${val}${RESET}"
               elif [[ "$line" =~ ^Homepage: ]]; then
                   key=${line%%:*}
                   val=${line#*: }
                   echo -e "${YELLOW}${key}:${RESET} ${LIGHTBLUE}${val}${RESET}"
               elif [[ "$line" =~ ^APT-Sources: ]]; then
                   key=${line%%:*}
                   val=${line#*: }
                   echo -e "${YELLOW}${key}:${RESET} ${LIGHTBLUE}${val}${RESET}"
               elif [[ "$line" =~ ":" ]]; then
                   key=${line%%:*}
                   val=${line#*: }
                   if [[ "$val" =~ [Yy]es ]]; then
                       echo -e "${YELLOW}${key}:${RESET} ${GREEN}✔ Yes${RESET}"
                   elif [[ "$val" =~ [Nn]o ]]; then
                       echo -e "${YELLOW}${key}:${RESET} ${PINK}✘ No${RESET}"
                   elif [[ "$val" =~ [0-9] ]]; then
                       echo -e "${YELLOW}${key}:${RESET} ${BRIGHTGREEN}${val}${RESET}"
                   else
                       echo -e "${YELLOW}${key}:${RESET} $(rand_color)${val}${RESET}"
                   fi
               else
                   echo -e "$(rand_color)${line}${RESET}"
               fi
           done
           ;;
        10) apt list --installed | less ;;
        11) apt list --upgradable ;;
        12) apt clean ;;
        13) apt update && apt upgrade -y ;;
        14) pkg update -y && pkg upgrade -y ;;
        $'\e') echo -e "\n🚪 Exiting Helper..."; exit 0 ;;
        *) echo -e "${YELLOW}⚠️ Invalid Choice${RESET}" ;;
    esac

    echo
    # Continue/ESC at end
    echo -ne "Press Enter To Continue..."
    IFS= read -rsn1 k
    [[ "$k" == $'\e' ]] && echo -e "\n🚪 Exiting Helper..." && exit 0
    # Consume rest if user typed anything else
    if [[ "$k" != $'\n' ]]; then
      IFS= read -r -t 0.1 _rest 2>/dev/null
    fi
done
