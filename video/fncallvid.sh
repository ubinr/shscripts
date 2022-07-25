#!/bin/bash -i
unset HISTFILE
printf '\033c'
shopt -s expand_aliases

readonly BRAND_ARG=${1:-''}
readonly THIS_DIR=${PWD##*/}
readonly FILES_DIR=(*.mp4)
readonly FILE=${FILES_DIR[0]}

# duration
eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=duration,height "$FILE")
#eval $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $1)
#ffprobe -y -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input.mp4
readonly HEIGHT=${streams_stream_0_height}
readonly DUT=${streams_stream_0_duration}

# VIDEO_PARAMS=
# IMG_SRC=Sinaloa
IMG_SRC=$(awk -F/ '{print $6}' <<<"${PWD}")
FNC_PATH='C:\tmp\HLS\'$IMG_SRC'\_fnc'
FNC_DIR=$(cygpath -u "$(cygpath -d $FNC_PATH)")

IMG_START='start'$HEIGHT$BRAND_ARG'.jpg'
IMG_END='end'$HEIGHT$BRAND_ARG'.jpg'
LOG_START='fnc_start'$HEIGHT
LOG_END='fnc_end'$HEIGHT
LOG_EXT=.log

LOG_BEGIN=$LOG_START$BRAND_ARG$LOG_EXT
LOG_DONE=$LOG_END$BRAND_ARG$LOG_EXT

# round decimal to integer
function round_dec() {
  awk -v i=${1} 'BEGIN{printf"%0.f\n", i}'
}
function time_fmt() {
  echo $(date -u -d "0 $1 sec" +"%H:%M:%S.%3N")
}
function pts_time() {
  echo $(grep -oP '(?<=pts_time:)[0-9]*\.?[0-9]+' $1)
}

# begind=$(time_fmt $DUT)
readonly DUI=$(round_dec $DUT)
readonly DUD=$(time_fmt $DUT)
echo "duration [ $DUD ] $DUT"

prevresult=0
prevbegt=0
begint=0
donet=0
begind=0

# leverage
readonly LOG_PREV=$(ls $LOG_END*$LOG_EXT)
# readonly LOG_PREV=$(ls $LOG_START*.$LOG_EXT 2>/dev/null | wc -w)
# readonly LOG_PREV=$(ls "${LOG_START}*${LOG_EXT}")
if [[ -f $LOG_PREV && -s $LOG_PREV ]]; then
  prevlogname=${LOG_PREV##*/}
  logname=${LOG_DONE##*/}
  # logname=${LOG_BEGIN##*/}
  echo -e '\tprev_log: '$prevlogname
  echo 'log: '$logname

  if [ $prevlogname != $logname ]; then
    prevbegt=$(pts_time $LOG_PREV)
    echo ' prev done [ '$(time_fmt $prevbegt)' ] '$prevbegt
    prevresult=$(($(round_dec $prevbegt) > 1))
    prevbegt=$(if [ $prevresult -eq 1 ]; then echo $(awk "BEGIN {print ($prevbegt+0.5)}"); else echo 0; fi)
    echo ' prev done [ '$(time_fmt $prevbegt)' ] '$prevbegt
  fi
fi

# notBeginLog=$(! -f $LOG_BEGIN && ! -s $LOG_BEGIN)

# C:\tmp\HLS\Durango\fnc
if [[ ! -f $LOG_BEGIN && ! -s $LOG_BEGIN ]]; then
  # prevresult= $(($DIFFT > 0)) -eq 1
  # DIFFT=$(awk "BEGIN {print ($DUT-$prevbegt)}")
  # $(($DIFFT > 0)) -eq 1
  VPARAM=$(if [ $prevresult -eq 1 ]; then echo "-ss $prevbegt"; else echo ''; fi)
  echo 'begin match '$FNC_DIR/$IMG_START
  echo 'vid_param '$VPARAM
  ffmpeg -y $VPARAM -copyts -i "$FILE" -i $FNC_DIR/$IMG_START -filter_complex "[0]extractplanes=y[v];[1]extractplanes=y[i];[v][i]blend=difference,blackframe=0,metadata=select:key=lavfi.blackframe.pblack:value=98:function=greater,trim=duration=0.0001,metadata=print:file=-" -an -v 0 -vsync 0 -f null - >$LOG_BEGIN
fi

if [ -s $LOG_BEGIN ]; then
  begint=$(pts_time $LOG_BEGIN)
  begind=$(date -u -d "0 $begint sec" +"%H:%M:%S.%3N")
  # begind=$(date -u -d "0 $begint sec - 0.999 sec" +"%H:%M:%S")
  # readonly begind=$(date -u -d "0 $begint sec + 1.750 sec" +"%H:%M:%S")
  echo "begin [ $begind ] $begint"
# else
#     echo $LOG_BEGIN' does not exist or empty'
#     rm -f $LOG_BEGIN
fi

# notDoneLog=$(! -f $LOG_DONE && ! -s $LOG_DONE)

if [[ ! -f $LOG_DONE && ! -s $LOG_DONE ]]; then
  begini=$(round_dec $begint)
  # minSecs=$(if [ $(awk "BEGIN {print ($DUI > 2940)}") -eq 1 ]; then echo $((50 * 60)); else echo $(awk "BEGIN {print ($DUT/2)}"); fi)
  minSecs=$(if [ $(($DUI > 2940)) -eq 1 ]; then echo $((45 * 60)); else echo $(awk "BEGIN {print ($DUT/2)}"); fi)
  # minSecs=$((50 * 60))
  FROMT=$(if [ $(($begini > 0)) -eq 1 ]; then echo $(($begini + $(round_dec $minSecs))); else echo $minSecs; fi)
  # FROMT=$((50 * 60))
  echo 'from_time [ '$(time_fmt $FROMT)' ] '$FROMT
  DIFFT=$(awk "BEGIN {print ($DUT-$FROMT)}")
  DIFFT=$(awk -v i=${DIFFT} 'BEGIN{printf"%0.f\n", i}')
  echo 'diff_time '$DIFFT
  VPARAM=$(if [ $(($DIFFT > 0)) -eq 1 ]; then echo "-ss $FROMT"; else echo ''; fi)
  echo 'vid_param '$VPARAM
  # VPARAM=$(( $(( $(($DUT - $FROMT)) -gt 0 )) ? "-ss $FROMT" : "" ))
  # VPARAM=$([ $(($DUT - $FROMT)) -gt 0 ] && echo "-ss $FROMT" || echo "")
  echo ' match '$FNC_DIR/$IMG_END
  ffmpeg -y $VPARAM -copyts -i "$FILE" -i $FNC_DIR/$IMG_END -filter_complex "[0]extractplanes=y[v];[1]extractplanes=y[i];[v][i]blend=difference,blackframe=0,metadata=select:key=lavfi.blackframe.pblack:value=98:function=greater,trim=duration=0.0001,metadata=print:file=-" -an -v 0 -vsync 0 -f null - >$LOG_DONE
# else
#     echo $LOG_DONE' does not exist or empty'
#     rm -f $LOG_DONE
fi

if [ -s $LOG_DONE ]; then
  donet=$(pts_time $LOG_DONE)
  doned=$(date -u -d "0 $donet sec" +"%H:%M:%S.%3N")
  # doned=$(date -u -d "0 $donet sec - 3 sec" +"%H:%M:%S")
  echo "done [ $doned ] $donet"
  # donet=$(decTimeFmt $donet)
  # echo $donet

  sleep 1
  echo 'cut___'$doned'___'$begind
  # cutvideo $doned $begind
  cutsvid "$FILE" $doned $begind

elif [ -s $LOG_BEGIN ]; then
  sleep 1
  echo ' cut___0___'$begind
  # cutvideo 0 $begind
  cutsvid "$FILE" 0 $begind
fi

if [ ! -s $LOG_BEGIN ]; then
  echo $LOG_BEGIN' does not exist or empty'
  # rm -f $LOG_BEGIN
fi
if [ ! -s $LOG_DONE ]; then
  echo $LOG_DONE' does not exist or empty'
  # rm -f $LOG_DONE
fi
