#!/bin/bash -i
unset HISTFILE
printf '\033c'
shopt -s nullglob

readonly FILES_EXT='.mp4'
readonly THIS_DIR=${PWD##*/}
typeset -l LOWC_DIR
LOWC_DIR=${THIS_DIR// /_}

declare COUNT=1
declare filename

# find . -maxdepth 1 -type f -name "*${FILES_EXT}" | while read file; do
find . -maxdepth 1 -type f -name "*${FILES_EXT}" -printf '%h\0%d\0%p\n' | sort -t '\0' -n | awk -F '\0' '{print $3}' | while read file; do
  if [ $COUNT -eq 1 ]; then
    # readonly CREATED_DATE=$(date -r "${file}" +'%y%m%d')
    filename="${LOWC_DIR}${filename}_"$(date -r "${file}" +'%y%m%d')
    echo $filename > 2
  fi

  fixname=$(echo "${file//[\']/}")

  if [[ "$file" != "$fixname" ]]; then
    mv "$file" "$fixname"
    file=$fixname
  fi

  printf "file '$file'\n" >> $filename'.txt'

  COUNT=$(($COUNT + 1))

done

read -r filename < 2
rm -f 2
ffmpeg -f concat -safe 0 -i $filename'.txt' -c copy $filename'.mp4'
