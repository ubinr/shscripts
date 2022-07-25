#!/bin/bash
unset HISTFILE
printf '\033c'

echo "[  BATCH  ]  ${PWD}"
echo -e " _user_:\t" $1
echo -e " _videoformat_:\t" $2

readonly batchFile="./batch_${1}.txt"
[ ! -f $batchFile ] && touch $batchFile
readonly archiveFile="./archive_${1}.txt"
[ ! -f $archiveFile ] && touch $archiveFile
readonly DATE_TIME=$(date +'%Y%m%d-%H%M%S')

youtube-dl \
-f $2 \
--limit-rate 2M \
--sleep-interval 15 \
--batch-file $batchFile \
--download-archive $archiveFile \
--hls-use-mpegts --no-part \
--write-info-json --write-thumbnail --write-description \
--no-overwrites --no-post-overwrites --newline --verbose \
--output '${PWD}/%(id)s_%(upload_date)s/%(id)s[%(format_id)s]_%(title)s.%(ext)s' 2> >(tee ./"batch_${1}_${DATE_TIME}.log" >&2)
#--postprocessor-args "-vf scale=1280x720 fps=fps=24" \
# -f '$2'
#--recode-video mp4
