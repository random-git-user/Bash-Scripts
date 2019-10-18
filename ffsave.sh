#!/bin/bash
#read -p "Enter the absolute path of streams directory  " cwd
cwd=$(pwd)/cams
i=1
while IFS= read -r line; do
    screen -dmS ffsave$i ffmpeg -i $line -acodec copy -vcodec copy ~/Videos/Cam$i.avi 
    let "i=i+1"
    done < "$cwd"
