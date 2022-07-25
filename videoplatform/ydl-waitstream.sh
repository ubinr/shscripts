#!/bin/bash -i
unset HISTFILE
printf '\033c'
shopt -s nullglob

#1 time
readonly TARGET_TIME=$1
#2 url
readonly URL=$2
