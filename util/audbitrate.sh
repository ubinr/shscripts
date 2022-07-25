#!/bin/bash
unset HISTFILE

echo $(ffmpeg -i "${1}" 2>&1 | grep Audio | awk -F", " '{print $5}' | cut -d' ' -f1)
