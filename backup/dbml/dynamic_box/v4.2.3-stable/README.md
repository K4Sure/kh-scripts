# Dynamic Box Master Library (DBML)

A pure box drawing and layout library for Termux scripts featuring multiple box styles, dynamic sizing, and terminal-aware positioning.

## Features

- 🎯 **5 Box Styles**: Single, Double, Round, Bold, Dotted borders
- 📏 **Dynamic Sizing**: Automatic or custom width calculation  
- 🎨 **Color-Agnostic**: Works with any color system (ANSI, 256-color, True Color)
- 📱 **Terminal-Aware**: Adapts to terminal dimensions
- 📍 **Smart Positioning**: Centered, left, right alignment options
- 🎮 **Interactive Menus**: Arrow-key navigable menu system

## Quick Start

```bash
# Auto-load the library
source "$HOME/kh-scripts/library/dynamic_box/dbml_loader"

# Basic box
dbml_draw_box "Hello World" "double" "Title" "$COLOR" "$TITLE_COLOR" "$TEXT_COLOR"

# Centered menu
options=("Start" "Settings" "Exit")
selection=$(dbml_draw_menu "Main Menu" "$BORDER_COLOR" "$TITLE_COLOR" "$TEXT_COLOR" "$HIGHLIGHT_COLOR" "$RESET_CODE" "${options[@]}")

