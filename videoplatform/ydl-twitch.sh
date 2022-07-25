#!/bin/bash
unset HISTFILE
printf '\033c'

echo "[  L I V E  ]  ${PWD}"
echo $(basename $BASH_SOURCE)
echo " _user_: " $1
echo " _videoformat_: " $2
readonly TODAY=$(date +'%Y%m%d')
readonly DATE_TIME=$(date +'%Y%m%d-%H%M%S')
readonly FORMAT_FILE="./format_${1}_${TODAY}.out"
[ ! -f $FORMAT_FILE ] && youtube-dl -F "https://www.twitch.tv/${1}" >$FORMAT_FILE
#$OPT_HOME/bin/youtube-dl_v2021.05.16 -f $2 \
youtube-dl -f $2 \
--limit-rate 1.1M \
--hls-use-mpegts --no-part \
--write-info-json --write-thumbnail --write-description \
--no-overwrites --no-post-overwrites --newline --verbose \
"https://www.twitch.tv/${1}" -o '${PWD}/%(uploader_id)s_liv%(upload_date)s/%(title)s-%(id)s.%(ext)s' \
2> >(tee ./"${1}_${DATE_TIME}.log" >&2)
