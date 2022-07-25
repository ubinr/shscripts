#!/bin/bash -i
unset HISTFILE
printf '\033c'
shopt -s nullglob

readonly FILES_EXT='.mp4'
declare -A brands=(["adn40"]="adn40" ["aguas"]="ags" ["bajio"]="bjio" ["canal66"]="c66" ["cdjuarez"]="cdj" ["chihuahua"]="chh" ["durango"]="dgo" ["forotv"]="ftv" ["gdl"]="gdl" ["gdlcan6"]="gd6" ["golfo"]="gfo" ["imagentv"]="itv" ["mexicali"]="mxl" ["morelos"]="mos" ["multimedios"]="mme" ["puebla"]="pue" ["queretaro"]="qro" ["quintanaroo"]="qroo" ["saltillo"]="sal" ["sinaloa"]="sin" ["telefe"]="tfe" ["tijuana"]="tij" ["veracruz"]="ver" ["zacatecas"]="zac")
readonly DIR_DATE=$(awk -F/ '{print $5}' <<<"${PWD}")
# readonly DIR_DATE=$(date +'%y%m%d')

typeset -l BRAND
BRAND=$(awk -F/ '{print $6}' <<<"${PWD}")
declare RESDIR="${brands[$BRAND]}"

# $1 files_extension
# $2 resolution_directory
function moveByResolution() {
  echo -e "\t _____move_____by_____resolution_____"
  find . -maxdepth 1 -type f -name "*${1}" | while read file; do

    eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height "$file")
    declare HEIGHT=${streams_stream_0_height}
    declare targetDir="${2}[${HEIGHT}]${3}"

    [ -d "$targetDir" ] || {
      echo "does_not_exist  ${targetDir}"
      mkdir "$targetDir"
    }

    mv -i "$file" "$targetDir"
    echo -e " $file ->\t$targetDir"

  done
}

function fixPartVids() {
  echo -e "\t _____fix_____part_____videos_____"
  readonly trashDir='TRASH'
  [ -d "$trashDir" ] || {
    echo "does_not_exist  $trashDir"
    mkdir "$trashDir"
  }

  find . -maxdepth 1 -type f -name "*.mp4.part" | while read partFile; do
    declare FILENAME="${partFile##*/}"
    declare EXTENSION="${FILENAME##*.}"
    FILENAME="${FILENAME%.*}"
    declare file="${FILENAME}"

    mv "$partFile" "$file"
    echo -e " $partFile ->\t$file"

    sleep 1
    eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=duration "$file")
    declare DUT=${streams_stream_0_duration}
    declare endd=$(time_fmtopr $DUT '+' 1)

    echo "duration [ $endd ] $DUT"
    echo 'cut___'$endd'___0'
    cutsvid "$file" $endd 0

    sleep 1
    mv -i "$file" "$trashDir"
    echo -e " $file ->\t$trashDir"

  done
}

moveByResolution $FILES_EXT $RESDIR $DIR_DATE
fixPartVids
moveByResolution $FILES_EXT $RESDIR $DIR_DATE
