#!/bin/bash
# DBML Demo
source ~/kh-scripts/library/dynamic_box/dynamic_box.sh

echo "== DBML $dbml_version Demo =="
echo

echo "Single-line (box_draw):"
box_draw single "Hello World"
echo

echo "Double-line (box_draw):"
box_draw double "Hello World"
echo

echo "Rounded (box_draw):"
box_draw rounded "Hello World"
echo

echo "Multi-line (box_auto single):"
box_auto single "Line One" "Line Two" "Line Three"
echo

echo "Multi-line (box_auto double):"
box_auto double "One" "Two" "Three"
echo

echo "Multi-line (box_auto rounded):"
box_auto rounded "First" "Second" "Third"
echo
