#!/bin/bash
source ~/kh-scripts/library/symbols/symbols.sh

echo "== Characters & Symbols Master Library Demo =="
csml_version
echo

echo "Arrows:"
echo " Up:    $(csml_symbol arrow_up)"
echo " Down:  $(csml_symbol arrow_down)"
echo " Left:  $(csml_symbol arrow_left)"
echo " Right: $(csml_symbol arrow_right)"
echo " Both:  $(csml_symbol arrow_both), $(csml_symbol arrow_vert)"
echo

echo "Stars:"
echo " Full:  $(csml_symbol star_full)"
echo " Empty: $(csml_symbol star_empty)"
echo " Four:  $(csml_symbol star_four)"
echo " Spark: $(csml_symbol star_spark)"
echo

echo "Blocks:"
echo " Full:  $(csml_symbol block_full)"
echo " Half:  $(csml_symbol block_half)"
echo " Mid:   $(csml_symbol block_mid)"
echo " Light: $(csml_symbol block_light)"
echo

echo "Misc:"
echo " Check: $(csml_symbol check)"
echo " Cross: $(csml_symbol cross)"
echo " Heart: $(csml_symbol heart)"
echo " Music: $(csml_symbol music)"
