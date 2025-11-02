#!/bin/bash
# DBML Demo v4.2.2

source ~/kh-scripts/library/dynamic_box/dynamic_box.sh

echo "== DBML $DBML_VERSION Demo =="

echo
echo "Single-line (box_draw):"
box_draw single "Hello World"

echo
echo "Double-line (box_draw):"
box_draw double "Hello World"

echo
echo "Rounded (box_draw):"
box_draw round "Hello World"

echo
echo "Multi-line (box_auto single):"
box_auto single "Line One" "Line Two" "Line Three"

echo
echo "Multi-line (box_auto double):"
box_auto double "One" "Two" "Three"

echo
echo "Multi-line (box_auto rounded):"
box_auto round "First" "Second" "Third"
