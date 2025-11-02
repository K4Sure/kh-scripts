#!/data/data/com.termux/files/usr/bin/bash
# truecolor-spectrum.sh
# Visualize the TrueColor RGB gradient safely in Termux.

clear
echo "TRUECOLOR RGB SPECTRUM DEMO"
echo "============================"
echo

# Check TrueColor support
if [ "$COLORTERM" != "truecolor" ] && [ "$COLORTERM" != "24bit" ]; then
  echo "⚠ WARNING: TRUECOLOR NOT REPORTED BY TERMINAL."
  echo "Some colors may appear distorted or fallback to 256-color mode."
  echo
fi

# Reduced sampling for performance
for r in $(seq 0 32 255); do
  for g in $(seq 0 32 255); do
    for b in $(seq 0 32 255); do
      printf "\e[48;2;%d;%d;%dm " "$r" "$g" "$b"
    done
    printf "\e[0m\n"
  done
  echo
done

printf "\e[0m\n✔ TRUECOLOR SPECTRUM RENDER COMPLETE.\n"
