start:

#!/bin/bash

sudo /bin/cp -pvr /etc/ffserver.conf /etc/ffserver_bak.conf

cd /home/awiros-tech/Videos/ffserver/
j=$(ls -1 | wc -l)
echo "Number of Streams to add $j"
i=1

for entry in "$vidPath"/*
	do
		echo -e "$entry\n"
		echo "password" | sudo -S echo -e "<Feed feed$i.ffm>\nFile /tmp/feed$i.ffm\nFileMaxSize 2G\nACL allow 127.0.0.1\nACL allow localhost\nACL allow 192.168.0.1 192.168.0.255\n</Feed>\n<Stream test$i.mpj>\nFeed feed$i.ffm\nFormat mpjpeg\nVideoSize hd480\nVideoFrameRate 35\nVideoBitRate 64\nVideoBufferSize 40\nVideoGopSize 12\nNoAudio\n</Stream>\n<Stream live$i.flv>\nFeed feed$i.ffm\nFormat flv\nVideoSize hd480\nVideoFrameRate 35\nVideoCodec libx264\nVideoBitRate 512\nVideoBufferSize 40\nVideoGopSize 12\nNoAudio\n</Stream>\n" >> /etc/ffserver.conf
		let "i=i+1"
	done
gnome-terminal -e "ffserver &"

echo "Number of Streams to add $j"
n=1

for entry in "$vidPath"/*

	do 
		nohup ffmpeg -f lavfi -re -fflags  +genpts -i "movie=$entry:loop=0,setpts=N/(FRAME_RATE*TB)" http://192.168.0.82:8090/feed$n.ffm &>/dev/null &
		let "n=n+1"
	done


stop : 

#!/bin/bash
#/bin/bash /home/awiros-tech/fserv/stop.sh

sudo killall -9 ffserver

sudo /bin/mv /etc/ffserver_bak.conf /etc/ffserver.conf   > /dev/null 2>&1
