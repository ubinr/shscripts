#!/bin/bash -i
unset HISTFILE
printf '\033c'
shopt -s nullglob

readonly BRAND_ARG=${1:-''}
readonly THIS_DIR=${PWD##*/}
readonly FILES_DIR=(*.mp4)
readonly FILE=${FILES_DIR[0]}

# duration
eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=duration,height $FILE)
#eval $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $1)
#ffprobe -y -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input.mp4
readonly HEIGHT=${streams_stream_0_height}
readonly DUT=${streams_stream_0_duration}
readonly WAITT=14
startt=$DUT

# VIDEO_PARAMS=
#FROM=melina
FNC_PATH='C:\tmp\TWITCH\_fnc'
# FNC_PATH='C:\tmp\TWITCH\'$FROM'\fnc'
FNC_DIR=$(cygpath -u "$(cygpath -d $FNC_PATH)")
#IMG_BEGIN=begin720.jpg
IMG_IN='in'$HEIGHT$BRAND_ARG
# IMG_END=end720.jpg
IMG_OUT='out'$HEIGHT$BRAND_ARG
LOG_IN='fnc_in'$HEIGHT
LOG_OUT='fnc_out'$HEIGHT
LOG_EXT=.log

ncuts=1

# round decimal to integer
function round_dec() {
  awk -v i=${1} 'BEGIN{printf"%0.f\n", i}'
}
# time format
function time_fmt() {
  echo $(date -u -d "0 $1 sec" +"%H:%M:%S")
}

readonly DUI=$(round_dec $startt)
startd=$(time_fmt $DUT)
result=$(($DUI > 0))
echo "duration [ $startd ] $DUT"

sleep 2

while [ $result -eq 1 ]; do
  # while [ $(($(round_dec $startt) > 0)) ]; do
  # while [ $(round_dec $startt) -ge 0 ]; do

  echo -e "\n\tloop [ ${ncuts} ]"

  # startd=00:00:00
  startt=$(echo "$DUT $startt" | awk '{print $1 - $2}')
  startd=$(time_fmt $startt)
  # startd=$(date -u -d "0 $startt sec" +"%H:%M:%S")
  # TSS=$(($DUT - $startt))
  echo "start [ $startd ] $startt"
  startd=$(date -u -d "0 $startt sec + $WAITT sec" +"%H:%M:%S")
  echo $startd
  sleep 2

  LOG_INF=$LOG_IN$LOG_EXT
  LOG_OUTF=$LOG_OUT$LOG_EXT

  echo $FNC_DIR/$IMG_OUT
  ffmpeg -y -ss $startd -copyts -i "$FILE" -i $FNC_DIR/$IMG_OUT -filter_complex "[0]extractplanes=y[v];[1]extractplanes=y[i];[v][i]blend=difference,blackframe=0,metadata=select:key=lavfi.blackframe.pblack:value=99:function=greater,trim=duration=0.0001,metadata=print:file=-" -an -v 0 -vsync 0 -f null - >$LOG_OUTF

  if [ -s $LOG_OUTF ]; then
    startt=$(grep -oP '(?<=pts_time:)[0-9]+\.[0-9]+' $LOG_OUTF)
    startd=$(date -u -d "0 $startt sec + 1.099 sec" +"%H:%M:%S")
    echo "out [ ${startd} ] ${startt}"
    mv $LOG_OUTF "${LOG_OUT}_${ncuts}${LOG_EXT}"

    echo $FNC_DIR/$IMG_IN
    # LOG_INF=$LOG_IN$LOG_EXT
    ffmpeg -y -ss $startd -copyts -i "$FILE" -i $FNC_DIR/$IMG_IN -filter_complex "[0]extractplanes=y[v];[1]extractplanes=y[i];[v][i]blend=difference,blackframe=0,metadata=select:key=lavfi.blackframe.pblack:value=99:function=greater,trim=duration=0.0001,metadata=print:file=-" -an -v 0 -vsync 0 -f null - >$LOG_INF

  else
    echo $LOG_OUTF
    rm -f $LOG_OUTF

  fi

  if [ -s $LOG_INF ]; then
    endt=$(grep -oP '(?<=pts_time:)[0-9]+\.[0-9]+' $LOG_INF)
    endd=$(date -u -d "0 $endt sec + 0.750 sec" +"%H:%M:%S")
    echo "next IN [ ${endd} ] ${endt}"
    mv $LOG_INF "${LOG_IN}_${ncuts}${LOG_EXT}"

    difft=$(round_dec $(echo "$endt $startt" | awk '{print $1 - $2}'))
    echo " timediff "$difft
    # difft=$(awk -v i=$(echo "$endt $startt" | awk '{print $1 - $2}') 'BEGIN{printf"%0.f\n", i}')
    # result=$(($(round_dec $startt) > 0))
    cuttable=$(($difft > $(($WAITT + 1))))
    # cut
    if [ $cuttable -eq 1 ]; then
      # if [ $difft -gt $(($WAITT + 1)) ]; then
      cutvideo $endd $startd
    else
      echo " NO Cut [ $endd ] [ $startd ] *"
    fi
    #
    endi=$(round_dec $endt)
    greaterThan=$(($DUI > $endi))
    echo " dut[ ${DUI} ] , endt[ ${endi} ] , gt[ ${greaterThan} ]"

    if [[ $greaterThan -eq 1 && $(($endi > 0)) -eq 1 ]]; then
      # if [ $(awk -v i=${DUT} 'BEGIN{printf"%0.f\n", i}') -gt $(round_dec $endt) ]; then
      startt=$(echo "$DUT $endt" | awk '{print $1 - $2}')
      # startt=$endt
    else
      startt=0
    fi

    # startt=$(echo "$DUT $endt" | awk '{print $1 - $2}')

  else
    cutvideo "00:00:00" $startd
    startt=0
  fi

  # startt=$endt
  echo $startt
  result=$(($(round_dec $startt) > 0))
  ncuts=$(($ncuts + 1))

done

echo " *  *  *  *  D  O N E !"
