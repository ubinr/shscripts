#!/bin/bash
printf '\033c'

DUT=4311.85
DUI=4312

minSecs=$(if [ $(awk "BEGIN {print ($DUI > 2940)}") -eq 1 ]; then echo $((50 * 60)); else echo $(awk "BEGIN {print ($DUT/2)}"); fi)

echo $minSecs
