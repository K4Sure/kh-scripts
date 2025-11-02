#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
if [ -f "${HOME}/kh-scripts/library/colors/cml.sh" ]; then
  source "${HOME}/kh-scripts/library/colors/cml.sh"
else
  echo "CML not found." >&2; exit 1
fi
cml::set_theme "classic"
echo -e "${CML_FG_PRIMARY}Primary${CML_RESET} and ${CML_ACCENT}Accent${CML_RESET}"
