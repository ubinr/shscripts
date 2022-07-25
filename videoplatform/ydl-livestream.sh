#!/bin/bash
unset HISTFILE

readonly DATE_TIME=$(date +'%Y%m%d_%H%M%S')
readonly CURRENT_DIR=${PWD##*/}
declare LOWERCASE_DIR=${CURRENT_DIR,,}
LOWERCASE_DIR=${LOWERCASE_DIR// /-}
readonly OUTPUT_DIR="${LOWERCASE_DIR}_${DATE_TIME}"
readonly archiveDownload="./archive_youtubelivestream-${LOWERCASE_DIR}.log"

echo " ..."
echo -e "\t begin \t __________________________________________________"
mkdir $OUTPUT_DIR
echo -e "\t created directory: \t ${OUTPUT_DIR}"
cd $OUTPUT_DIR
# Live stream on YouTube
$OPT_HOME/bin/youtube-dl_v2021.04.26 \
--retries '3' \
--limit-rate 1.1M \
--download-archive $archiveDownload \
--sleep-interval 1 \
--newline --verbose \
--ignore-config --ignore-errors \
--no-warnings --rm-cache-dir \
--no-check-certificate \
--no-overwrites --no-post-overwrites \
--call-home \
--write-description \
--write-info-json \
--write-annotations \
--write-all-thumbnails \
--all-subs \
--sub-lang 'en,es' \
--convert-subs 'srt' \
--embed-subs \
--embed-thumbnail \
--add-metadata \
--format 'best' \
--merge-output-format 'mkv' \
--output '${PWD}/%(title)s (%(upload_date)s)-%(id)s.%(ext)s' $1
#--skip-download $1
cd .
echo -e "\t download-archive: \t $archiveDownload"
echo " ..."
echo -e "\t __________________________________________________  finish!"
