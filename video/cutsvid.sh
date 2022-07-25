#!/bin/bash -i
unset HISTFILE
# shopt -s nullglob
# printf '\033c'

function date_fmt() {
  echo $(date -u -d "0 $1 sec" +"%H-%M-%S")
}

readonly DATE_TIME=$(date +'%y%m%d_%H%M%S')
readonly CURRENT_DIR=${PWD##*/}
# declare LOWERCASE_DIR=${CURRENT_DIR,,}
typeset -l LOWC_DIR
# LOWERCASE_DIR=${LOWERCASE_DIR// /-}
LOWC_DIR=${CURRENT_DIR// /_}
# readonly WORKIN_DIR="${LOWC_DIR}_${DATE_TIME}"

# mkdir $WORKIN_DIR
# echo -e "\t created directory: \t ${WORKIN_DIR}"

# readonly FILES_DIR=(*.mp4)
#echo "${#FILES_DIR[@]}"
readonly FILE="${1}"
# readonly FILE=${FILES_DIR[0]}
readonly CREATED_DATE=$(date -r "${FILE}" +'%y%m%d-%H%M%S')
declare FILENAME="${FILE##*/}"
readonly EXTENSION="${FILENAME##*.}"
FILENAME="${FILENAME%.*}"

echo "  #   #   #   #   #   #   #   #   #   #   #   #   #"
echo "  : ${FILE}"
echo "  #   #   #   #   #   #   #   #   #   #   #   #   #"
echo "  EXT[ ${EXTENSION} ]   FILENAME[ ${FILENAME} ]"
#exit

# -to   End Time    extract seconds of the video starting from second to second
readonly argTo=$2
echo " "
echo -e "\t End Time  $argTo"

# -ss   Input seeking   frame from the beginning of the movie
readonly argSs=$3
echo " "
echo -e "\t Start Time  $argSs"

declare startTime=$(date -u -d "$argSs" +"%s")
declare endTime=$(date -u -d "$argTo" +"%s")
readonly timeDiff=$(awk "BEGIN {print ($endTime-$startTime)}")
# readonly timeDiff=$(date -u -d "0 $endTime sec - $startTime sec" +"%H:%M:%S.%3N")
readonly total=$(date_fmt $timeDiff)
# startTime=$(date_fmt $startTime)
# endTime=$(date_fmt $endTime)

readonly NEW_FILENAME="$(echo $LOWC_DIR | sed -r 's/[_]+/-/g')_${CREATED_DATE}__${total}.${EXTENSION}"
# readonly NEW_FILENAME="$(echo $LOWC_DIR | sed -r 's/[_]+/-/g')_${CREATED_DATE}_${startTime}_${endTime}__${total}.${EXTENSION}"
#echo "./${WORKIN_DIR}/${NEW_FILENAME}"
#exit
ffmpeg -ss "$argSs" -i "$FILE" -to "$timeDiff" -c copy -movflags faststart -avoid_negative_ts 1 -hide_banner "./${NEW_FILENAME}" < /dev/null

echo " "
echo " < <<<  $NEW_FILENAME  completed!"
echo " "
echo -e "\t completed \t __________________________"
