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
echo -e "\t _ _ _  S T A R T I N G            [ ${1} ]"
echo -e "\t _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
# mkdir $OUTPUT_DIR
# echo -e "\t DIRECTORY: \t ${OUTPUT_DIR}"

# readonly FILE_SH="~/opt/scripts/util/rz${1}p.sh"

declare COUNTER=0

find . -maxdepth 1 -type f -name "*${FILES_EXT}" | while read file; do

  declare CREATED_DATE=$(date -r "${file}" +'%y%m%d')
  declare FILENAME="${file##*/}"
  declare EXTENSION="${FILENAME##*.}"
  FILENAME="${FILENAME%.*}"

  echo " . . ."
  echo "  -->  ...... INPUT file: ${file}"
  echo " . . . . ."
  echo "  EXT[ ${EXTENSION} ]   FILENAME[ ${FILENAME} ]"
  # exit

  readonly NEW_FILENAME="${FILENAME}[${1}p].${EXTENSION}"
  #echo "./${OUTPUT_DIR}/${NEW_FILENAME}"
  #exit

  sleep 3
  let COUNTER++
  mkdir "${OUTPUT_DIR}__${COUNTER}"
  echo -e "\t DIRECTORY: \t ${OUTPUT_DIR}__${COUNTER}"

  if (($1 == '1080')); then
    ~/opt/shscripts/util/rz1080p.sh $file "./${OUTPUT_DIR}__${COUNTER}/${NEW_FILENAME}"
  elif (($1 == '720')); then
    ~/opt/shscripts/util/rz720p.sh $file "./${OUTPUT_DIR}__${COUNTER}/${NEW_FILENAME}"
  elif (($1 == '480')); then
    ~/opt/shscripts/util/rz480p.sh $file "./${OUTPUT_DIR}__${COUNTER}/${NEW_FILENAME}"
  elif (($1 == '360')); then
    ~/opt/shscripts/util/rz360p.sh $file "./${OUTPUT_DIR}__${COUNTER}/${NEW_FILENAME}"
  elif (($1 == '240')); then
    ~/opt/shscripts/util/rz360p.sh $file "./${OUTPUT_DIR}__${COUNTER}/${NEW_FILENAME}"
  fi

  sleep 1

  # declare CMD_SH="$FILE_SH \"$file\" \"./${OUTPUT_DIR}/${NEW_FILENAME}\""

  # eval $CMD_SH
  # ~/opt/scripts/util/"rz${1}p.sh" $file "./${OUTPUT_DIR}/${NEW_FILENAME}"

  echo "  . . . . . . ."
  echo -e "  <--  .................  $NEW_FILENAME  completed!\n"
  echo -e "  # # # # # # # # #\n"

done

echo -e "\t _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
echo -e "\t _ _ _  C O M P L E T E D"
echo -e "\t _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
