DBML CHEATSHEET (short)
-----------------------
File: dynamic_box_master_library.sh  (v4.0.0)

Usage:
  source ~/kh-scripts/library/dynamic_box/dynamic_box_master_library.sh
  draw_box STYLE "Title" "Line1" "Line2" ...
  pulse_box STYLE "Title" "Line1" "Line2" ...

Styles:
  line    - single line box
  double  - double line box
  round   - rounded corners

Examples:
  draw_box line "Hello" "This is a box."
  draw_box double "System" "Status: OK"
  pulse_box round "Neon Pulse" "Boxes with color pulse!"
