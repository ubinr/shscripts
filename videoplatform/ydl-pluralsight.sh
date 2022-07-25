#!/bin/bash
unset HISTFILE

originDir=${PWD##*/}
originDir="${originDir,,}"
originDir=${originDir// /-}
archiveDownload="./archive_${originDir}.log"
batchDownload='batchcourse.txt'

echo $batchDownload
echo $archiveDownload

#exit 1
$OPT_HOME/bin/youtube-dl_v2021.06.06 \
--add-header Referer:'https://app.pluralsight.com/library/courses' \
--user-agent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36' \
--limit-rate 0.5M \
--cookies "${HOME}/Pluralsight/cookies.txt" \
--batch-file ${batchDownload} \
--download-archive ${archiveDownload} \
--sleep-interval 120 \
--min-sleep-interval 119 --max-sleep-interval 160 \
--hls-prefer-native \
--newline --verbose \
--rm-cache-dir \
--no-warnings \
--no-check-certificate \
--write-info-json --write-thumbnail --write-description \
--write-sub --write-auto-sub --all-subs \
--no-overwrites --no-post-overwrites \
--sub-lang 'es,en' \
--sub-format srt \
--convert-subs 'srt' \
--format mp4 \
--output '${PWD}/%(playlist_title)s/%(chapter_number)02d - %(chapter)s/%(playlist_index)02d - %(title)s.%(ext)s' $1 --playlist-start 1
#--hls-prefer-native \
#--embed-subs \
#--embed-thumbnail \

#--output '${PWD}/%(playlist_title)s/%(chapter_number)s - %(chapter)s/%(playlist_index)s-%(title)s.%(ext)s' $1 --playlist-start 1
#--add-header Referer:'https://app.pluralsight.com/library/courses/' \
#--add-header Origin:'https://app.pluralsight.com' \
#--ignore-config \
#--ignore-errors \
#--skip-download $1 \
#--list-subs \
#--sleep-interval 150 \
#--max-sleep-interval 60 \
#--min-sleep-interval 30 \
#https://gist.github.com/ivanskodje/5bd8697a64e9879f397f7ef161cf0956
#https://gist.github.com/edgardo001/76a3c286e727374b9df128dcad1a46fb
#--username 'moises.villa@improving.com' \
#--username 'exitmuxic@gmail.com' \
# snmarcosa@gmail.com
#--username 'azmarcoz@gmail.com' \
#--username 'sernandovilla@gmail.com' \
#--username 'godtlazo@gmail.com' \
#--username 'ubinr0@gmail.com' \
#--username 'villa2mendoza@gmail.com' \
#--username 'ubinr@outlook.com' \
#--username 'ubinraws@gmail.com' \
#--username 'binrscala@gmail.com' \
#'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.128 Safari/537.36'
