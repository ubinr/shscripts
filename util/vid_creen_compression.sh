#!/bin/bash
unset HISTFILE
printf '\033c'

readonly DATE_TIME=$(date +'%Y-%m%d_%H-%M%S')
readonly CURRENT_DIR=${PWD##*/}
readonly OUTPUT_DIR="${CURRENT_DIR,,}"_$DATE_TIME

readonly FILE_EXT='.mp4'

echo -e "\t starting \t __________________________________________________"
echo -e "\t creating directory: \t ${OUTPUT_DIR}"

mkdir $OUTPUT_DIR

echo " ..."
echo " ..."
echo -e " processing: \t $1"

declare FILE_CREATED_STR=$(stat -c %y $1)
declare FILE_NEW_NAME="${CURRENT_DIR,,}"_"$(date -d "$FILE_CREATED_STR" +'%Y%m%d-%H%M')"$FILE_EXT

echo " date: ${FILE_CREATED_STR}"

~/opt/shscripts/util/vid_creen_compression.sh $1 "./${OUTPUT_DIR}/${FILE_NEW_NAME}"

echo " ..."
echo -e "\t completed \t __________________________________________________"
