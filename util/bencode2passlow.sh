#!/bin/bash
unset HISTFILE
printf '\033c'

readonly FILES_EXT='.mp4'

readonly DATE_TIME=$(date +'%y%m%d_%H%M%S')
readonly CURRENT_DIR=${PWD##*/}
declare LOWERCASE_DIR=${CURRENT_DIR,,}
LOWERCASE_DIR=${LOWERCASE_DIR// /-}
readonly OUTPUT_DIR="${LOWERCASE_DIR}_${DATE_TIME}"

echo -e "\t _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
echo -e "\t _ _ _  S T A R T I N G"
echo -e "\t _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
mkdir $OUTPUT_DIR
echo -e "\t DIRECTORY: \t ${OUTPUT_DIR}"

# readonly FILE_SH="~/opt/scripts/util/encode${1}p.sh"

find . -maxdepth 1 -type f -name "*${FILES_EXT}" | while read file; do

  sleep 1
  eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height $file)
  declare HEIGHT=${streams_stream_0_height}

  declare CREATED_DATE=$(date -r "${file}" +'%y%m%d')
  declare FILENAME="${file##*/}"
  declare EXTENSION="${FILENAME##*.}"
  FILENAME="${FILENAME%.*}"

  echo " . . ."
  echo "  -->  ...... INPUT file: ${file}"
  echo " . . . . ."
  echo "  EXT[ ${EXTENSION} ]   FILENAME[ ${FILENAME} ]"
  # exit

  sleep 1
  declare NEW_FILENAME="${FILENAME}[${HEIGHT}p].${EXTENSION}"
  #echo "./${OUTPUT_DIR}/${NEW_FILENAME}"
  #exit

  sleep 2
  # if (($1 == '720')); then
  ~/opt/scripts/util/vencode2passlow.sh "$file" "./${OUTPUT_DIR}/${NEW_FILENAME}" $HEIGHT
  # elif (($1 == '480')); then
  #   ~/opt/scripts/util/encode480p.sh $file "./${OUTPUT_DIR}/${NEW_FILENAME}"
  # fi

  sleep 1

  # declare CMD_SH="$FILE_SH \"$file\" \"./${OUTPUT_DIR}/${NEW_FILENAME}\""
  # eval $CMD_SH </dev/null
  # ~/opt/scripts/util/"rz${1}p.sh" $file "./${OUTPUT_DIR}/${NEW_FILENAME}"

  echo "  . . . . . . ."
  echo -e "  <--  .................  $NEW_FILENAME  completed!\n"
  echo -e "  # # # # # # # # #\n"

done

echo -e "\t _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
echo -e "\t _ _ _  C O M P L E T E D"
echo -e "\t _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
