#!/bin/bash -i
unset HISTFILE
printf '\033c'
shopt -s nullglob
# shopt -s expand_aliases

readonly BRAND_ARG=${1:-''}
readonly INTVLT=${2:-14}
readonly THIS_DIR=${PWD##*/}
readonly FILES_DIR=(*.mp4)
readonly FILE=${FILES_DIR[0]}

# duration
eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=duration,height "$FILE")
readonly HEIGHT=${streams_stream_0_height}
readonly DUT=${streams_stream_0_duration}
startt=$DUT

IMG_SRC=$(awk -F/ '{print $5}' <<<"${PWD}")
BASE_PATH='C:\tmp\TWITCH\'
FNC_PATH=$BASE_PATH$IMG_SRC'\_fnc'
FNC_DIR=$(cygpath -u "$(cygpath -d $FNC_PATH)")

IMG_END='end'$HEIGHT$BRAND_ARG'.jpg'
IMG_START='start'$HEIGHT$BRAND_ARG'.jpg'
LOG_END='fnc_end'$HEIGHT
LOG_START='fnc_start'$HEIGHT
LOG_EXT=.log

[ -f $FNC_DIR/$IMG_END ] || {
  FNC_PATH=$BASE_PATH'\_fnc'
  FNC_DIR=$(cygpath -u "$(cygpath -d $FNC_PATH)")
}
[ -f $FNC_DIR/$IMG_END ] || {
  echo " does_not_exist "$FNC_DIR/$IMG_END
  exit 3
}

# round decimal to integer
function round_dec() {
  awk -v i=${1} 'BEGIN{printf"%0.f\n", i}'
}
# time format
function time_fmt() {
  echo $(date -u -d "0 $1 sec" +"%H:%M:%S.%3N")
}
function pts_time() {
  echo $(grep -oP '(?<=pts_time:)[0-9]+\.[0-9]+' $1)
}

readonly DUI=$(round_dec $startt)
readonly DUD=$(time_fmt $DUT)
startd=$DUD
result=$(($DUI > 0))
echo "duration [ $startd ] $DUT"

sleep 2

# startd=00:00:00
startt=$(echo "$DUT $startt" | awk '{print $1 - $2}')
startd=$(time_fmt $startt)
echo "start [ $startd ] $startt"
startd=$(date -u -d "0 $startt sec + $INTVLT sec" +"%H:%M:%S.%3N")
echo $startd
sleep 2

LOG_DONE=$LOG_END$BRAND_ARG$LOG_EXT
LOG_BEGIN=$LOG_START$BRAND_ARG$LOG_EXT

if [[ ! -f $LOG_DONE && ! -s $LOG_DONE ]]; then
  echo $FNC_DIR/$IMG_END
  ffmpeg -y -ss $startd -copyts -i "$FILE" -i $FNC_DIR/$IMG_END -filter_complex "[0]extractplanes=y[v];[1]extractplanes=y[i];[v][i]blend=difference,blackframe=0,metadata=select:key=lavfi.blackframe.pblack:value=99:function=greater,trim=duration=0.0001,metadata=print:file=-" -an -v 0 -vsync 0 -f null - >$LOG_DONE
fi

if [[ ! -f $LOG_BEGIN && ! -s $LOG_BEGIN ]]; then
  echo $FNC_DIR/$IMG_START
  endt=$(echo "$DUT 60" | awk '{print $1 - $2}')
  ffmpeg -y -ss $(time_fmt $endt) -copyts -i "$FILE" -i $FNC_DIR/$IMG_START -filter_complex "[0]extractplanes=y[v];[1]extractplanes=y[i];[v][i]blend=difference,blackframe=0,metadata=select:key=lavfi.blackframe.pblack:value=99:function=greater,trim=duration=0.0001,metadata=print:file=-" -an -v 0 -vsync 0 -f null - >$LOG_BEGIN
fi

if [ -s $LOG_DONE ]; then
  startt=$(pts_time $LOG_DONE)
  # startt=$(grep -oP '(?<=pts_time:)[0-9]+\.[0-9]+' $LOG_DONE)
  startd=$(time_fmt $startt)
  # startd=$(date -u -d "0 $startt sec + 1.099 sec" +"%H:%M:%S.%3N")
  echo "wait_to_start [ ${startd} ] ${startt}"

  difft=$(round_dec $(echo "$DUT $startt" | awk '{print $1 - $2}'))
  echo " timediff "$difft
  # difft=$(awk -v i=$(echo "$endt $startt" | awk '{print $1 - $2}') 'BEGIN{printf"%0.f\n", i}')
  # result=$(($(round_dec $startt) > 0))
  cuttable=$(($difft > $(($INTVLT + 1))))
  # cut
  if [ $cuttable -eq 1 ]; then
    endd=0
    if [ -s $LOG_BEGIN ]; then
      endt=$(pts_time $LOG_BEGIN)
      endd=$(date -u -d "0 $endt sec + 1 sec" +"%H:%M:%S.%3N")
      # endd=$(time_fmt $endt)
      echo "wait_to_end [ ${endd} ] ${endt}"
      # endt=$(echo "$DUT $endt" | awk '{print $1 - $2}')
      # endd=$(time_fmt $endt)
    fi

    echo 'cut__'$endd'__'$startd
    cutvideo $endd $startd
  else

    echo " NO Cut [ $DUD ] [ $startd ] *"
  fi

else

  echo "remove "$LOG_DONE
  rm -f $LOG_DONE
fi

echo " *  *  *  *  D  O N E !"
