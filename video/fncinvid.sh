#!/bin/bash -i
unset HISTFILE
printf '\033c'
shopt -s nullglob

readonly BRAND_ARG=${1:-''}
readonly THIS_DIR=${PWD##*/}
readonly FILES_DIR=(*.mp4)
readonly FILE=${FILES_DIR[0]}

# duration
eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=duration,height "$FILE")

readonly HEIGHT=${streams_stream_0_height}
readonly DUT=${streams_stream_0_duration}
readonly WAITT=59

IMG_SRC=$(awk -F/ '{print $6}' <<<"${PWD}")
FNC_PATH='C:\tmp\HLS\'$IMG_SRC'\_fnc'
FNC_DIR=$(cygpath -u "$(cygpath -d $FNC_PATH)")
#IMG_BEGIN=begin720.jpg
IMG_IN='in'$HEIGHT$BRAND_ARG'.jpg'
# IMG_END=end720.jpg
IMG_OUT='out'$HEIGHT$BRAND_ARG'.jpg'
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
  echo $(date -u -d "0 $1 sec" +"%H:%M:%S.%3N")
}
function time_fmt2arg() {
  echo $(date -u -d "0 $1 sec + $2 sec" +"%H:%M:%S.%3N")
}
function pts_time() {
  echo $(grep -oP '(?<=pts_time:)[0-9]+\.[0-9]+' $1)
}

readonly DUI=$(round_dec $DUT)
readonly DUD=$(time_fmt $DUT)
echo "duration [ $DUD ] $DUT"

startt=0
startd=0
nextin=0
lastin=0
between=$WAITT
nextout=0
lastout=0
interval=$WAITT
result=$(($DUI > 0))

sleep 2

while [ $result -eq 1 ]; do

  echo -e "\n\tloop [ ${ncuts} ]"

  startd=$(time_fmt $startt)
  echo "start [ $startd ] $startt"
  sleep 2

  LOG_INF=$LOG_IN$LOG_EXT
  LOG_OUTF=$LOG_OUT$LOG_EXT

  # if test ncuts -eq 1; then
  #   echo "foo and bar are equal"
  # else
  #   echo "foo and bar are not equal"
  # fi

  echo ' last_out '$lastout'  '$(time_fmt $lastout)
  echo ' last_in  '$lastin'  '$(time_fmt $lastin)
  echo ' between  '$between'  '$(time_fmt $between)
  echo ' interval '$interval'  '$(time_fmt $interval)

  #IMAGE_IN
  [ $ncuts -eq 1 ] || {
    # nextin=$(echo "$lastout $between" | awk '{print $1 + $2}')
    nextin=$(echo "$startt $between" | awk '{print $1 + $2}')
    nextind=$(time_fmt $nextin)
    echo " from_in [ ${nextind} ] $(round_dec $nextin)"
    echo 'match_in  '$FNC_DIR/$IMG_IN
    # LOG_INF=$LOG_IN$LOG_EXT
    ffmpeg -y -ss $nextind -copyts -i "$FILE" -i $FNC_DIR/$IMG_IN -filter_complex "[0]extractplanes=y[v];[1]extractplanes=y[i];[v][i]blend=difference,blackframe=0,metadata=select:key=lavfi.blackframe.pblack:value=98:function=greater,trim=duration=0.0001,metadata=print:file=-" -an -v 0 -vsync 0 -f null - >$LOG_INF
    sleep 1
  }

  if [ -s $LOG_INF ]; then
    startt=$(pts_time $LOG_INF)
    # startt=$(grep -oP '(?<=pts_time:)[0-9]+\.[0-9]+' $LOG_INF)
    startd=$(time_fmt2arg $startt '1')
    lastin=$startt
    between=$(round_dec $(echo "$startt $lastout" | awk '{print $1 - $2}'))
    between=$(round_dec $(echo "$between 3" | awk '{print $1 / $2}'))
    between=$(round_dec $(echo "$between 2" | awk '{print $1 * $2}'))
    # startd=$(date -u -d "0 $startt sec + 1.099 sec" +"%H:%M:%S.%3N")
    # echo ' last_in  '$lastin'  '$(time_fmt $lastin)
    # echo ' between  '$between'  '$(time_fmt $between)

    mv $LOG_INF "${LOG_IN}_${ncuts}${LOG_EXT}"

  else
    echo '__not__found '$LOG_INF
    rm -f $LOG_INF
  fi

  #IMAGE_OUT
  if [ $(($(round_dec $lastout) > $(round_dec $startt))) -eq 1 ]; then
    echo ' _startt_ '$startt
    startt=$lastout
    startd=$(time_fmt2arg $(echo "$startt $between" | awk '{print $1 + $2}') '1')
  fi
  nextout=$(echo "$startt $interval" | awk '{print $1 + $2}')
  nextoutd=$(time_fmt $nextout)
  echo " from_out [ ${nextoutd} ] $(round_dec $nextout)"
  echo 'match_out  '$FNC_DIR/$IMG_OUT
  ffmpeg -y -ss $nextoutd -copyts -i "$FILE" -i $FNC_DIR/$IMG_OUT -filter_complex "[0]extractplanes=y[v];[1]extractplanes=y[i];[v][i]blend=difference,blackframe=0,metadata=select:key=lavfi.blackframe.pblack:value=98:function=greater,trim=duration=0.0001,metadata=print:file=-" -an -v 0 -vsync 0 -f null - >$LOG_OUTF
  sleep 1

  if [ -s $LOG_OUTF ]; then
    endt=$(pts_time $LOG_OUTF)
    # endt=$(grep -oP '(?<=pts_time:)[0-9]+\.[0-9]+' $LOG_OUTF)
    endd=$(time_fmt2arg $endt '0.750')

    mv $LOG_OUTF "${LOG_OUT}_${ncuts}${LOG_EXT}"

    if [ $ncuts -eq 1 ]; then
      echo ' cut__'$endd'__0'
      cutvideo $endd 0
    else

      difft=$(round_dec $(echo "$endt $startt" | awk '{print $1 - $2}'))
      diffd=$(time_fmt $difft)
      echo " timediff [ $diffd ] $difft"
      # difft=$(awk -v i=$(echo "$endt $startt" | awk '{print $1 - $2}') 'BEGIN{printf"%0.f\n", i}')
      # result=$(($(round_dec $startt) > 0))
      cuttable=$(($difft > $(($WAITT + 1))))
      # cut
      if [ $cuttable -eq 1 ]; then
        echo 'cut__'$endd'__'$startd
        # if [ $difft -gt $(($WAITT + 1)) ]; then
        cutvideo $endd $startd

      else
        echo "_NOT_CUT [ $endd ] [ $startd ] *"
      fi
      #
      endi=$(round_dec $endt)
      greaterThan=$(($DUI > $endi))
      echo " dut[ ${DUI} ] , endt[ ${endi} ] , gt[ ${greaterThan} ]"

      # if [[ $greaterThan -eq 1 && $(($endi > 0)) -eq 1 ]]; then
      #   # if [ $(awk -v i=${DUT} 'BEGIN{printf"%0.f\n", i}') -gt $(round_dec $endt) ]; then
      #   startt=$(echo "$DUT $endt" | awk '{print $1 - $2}')
      #   # startt=$endt
      # else
      #   startt=0
      #   echo ' _start_time -> '$startt
      # fi

      # startt=$(echo "$DUT $endt" | awk '{print $1 - $2}')

      # echo 'cut_from '$startd
      # cutvideo 0 $startd
    fi

    lastout=$endt
    interval=$(round_dec $(echo "$endt $lastin" | awk '{print $1 - $2}'))
    interval=$(round_dec $(echo "$interval 3" | awk '{print $1 / $2}'))
    interval=$(round_dec $(echo "$interval 1" | awk '{print $1 * $2}'))
    # endd=$(date -u -d "0 $endt sec + 0.750 sec" +"%H:%M:%S.%3N")
    # echo ' last_out '$(time_fmt $lastout)
    # echo ' interval '$(time_fmt $interval)

    startt=$endt
  else

    # if [[ -s $LOG_OUTF && $ncuts -eq 1 ]]; then
    #   echo 'cut_from 0'
    #   cutvideo $startd 0
    #
    # else
    #   echo 'cut_from '$startd
    #   # $SCRIPT/util/cutvideo.sh 0 $startd
    #   cutvideo 0 $startd
    # fi
    #
    # startt=0
    # echo ' start_time -> '$startt

    echo '_not_found '$LOG_OUTF
    rm -f $LOG_OUTF

    echo 'cut__0__'$startd
    cutvideo 0 $startd

    startt=0
    echo ' _start_time -> '$startt

    # lastin=$startt
    between=120
    between=$(round_dec $(echo "$between 3" | awk '{print $1 / $2}'))
    between=$(round_dec $(echo "$between 2" | awk '{print $1 * $2}'))
  fi

  # startt=$endt
  echo 'start_time '$startt
  result=$(($(round_dec $startt) > 0))
  ncuts=$(($ncuts + 1))

done

echo " *  *  *  *  D  O N E !"
