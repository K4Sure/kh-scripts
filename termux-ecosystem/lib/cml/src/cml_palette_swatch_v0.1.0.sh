#!/usr/bin/env sh
# TrueColor swatch renderer: reads key:#hex lines from stdin and prints 24-bit swatches
set -e

# Force TrueColor hint in local environment
export COLORTERM=truecolor

# Parse key and hex, then render colored swatch with 24-bit ANSI
awk -F: '
  function trim(s){ gsub(/^[[:space:]]+|[[:space:]]+$/,"",s); return s }
  function hex2rgb(h,    r,g,b){
    # h like #abc or #aabbcc
    if (length(h)==4) {
      r=strtonum("0x" substr(h,2,1) substr(h,2,1))
      g=strtonum("0x" substr(h,3,1) substr(h,3,1))
      b=strtonum("0x" substr(h,4,1) substr(h,4,1))
    } else {
      r=strtonum("0x" substr(h,2,2))
      g=strtonum("0x" substr(h,4,2))
      b=strtonum("0x" substr(h,6,2))
    }
    return r "|" g "|" b
  }
  function swatch(k,h,    rgb,r,g,b,esc,reset,block,label){
    rgb=hex2rgb(h)
    split(rgb,a,"|"); r=a[1]; g=a[2]; b=a[3]
    esc=sprintf("\033[38;2;%d;%d;%dm\033[48;2;%d;%d;%dm", r,g,b, r,g,b)
    reset="\033[0m"
    block="█"
    label=sprintf("%s %-8s %s", k, h, block block block block block block block block)
    printf("%s%s%s\n", esc, label, reset)
  }
  {
    key=tolower(trim($1))
    val=trim(substr($0, index($0,":")+1))
    # basic validation
    if (val ~ /^#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?$/) {
      swatch(key, val)
    } else {
      printf("WARNING: invalid hex for %s: %s\n", key, val) > "/dev/stderr"
      # still print a neutral line
      printf("%s %s\n", key, val)
    }
  }
'
