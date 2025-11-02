BEGIN { done=0 }
{
  # If we find a line that mentions ACTIVE THEME and CURRENT_THEME, replace it with robust block
  if (!done && $0 ~ /ACTIVE THEME/ && $0 ~ /CURRENT_THEME/) {
    print "  # --- robust ACTIVE THEME read + print (inserted by patch) ---"
    print "  if [ -f \"$THEME_FILE\" ]; then"
    print "    CURRENT_THEME=$(awk '\\''NF{print; exit}'\\'' \"$THEME_FILE\" 2>/dev/null || printf '\\''CLASSIC'\\'')"
    print "    CURRENT_THEME=\"${CURRENT_THEME//[$'\\r\\n']/}\""
    print "    CURRENT_THEME=\"${CURRENT_THEME^^}\""
    print "  else"
    print "    CURRENT_THEME=\"CLASSIC\""
    print "    printf \"%s\" \"$CURRENT_THEME\" > \"$THEME_FILE\""
    print "  fi"
    print "  # print with theme accent so color follows the active theme"
    print "  theme_accent_print \"✔ ACTIVE THEME: ${CURRENT_THEME}\""
    done = 1
    next
  }
  print
}
END {
  if (!done) {
    # fallback: append the robust block at EOF if insertion point not found
    print ""
    print "# --- appended robust ACTIVE THEME read+print block (patch fallback) ---"
    print "if [ -f \"$THEME_FILE\" ]; then"
    print "  CURRENT_THEME=$(awk '\\''NF{print; exit}'\\'' \"$THEME_FILE\" 2>/dev/null || printf '\\''CLASSIC'\\'')"
    print "  CURRENT_THEME=\"${CURRENT_THEME//[$'\\r\\n']/}\""
    print "  CURRENT_THEME=\"${CURRENT_THEME^^}\""
    print "else"
    print "  CURRENT_THEME=\"CLASSIC\""
    print "  printf \"%s\" \"$CURRENT_THEME\" > \"$THEME_FILE\""
    print "fi"
    print "theme_accent_print \"✔ ACTIVE THEME: ${CURRENT_THEME}\""
  }
}
