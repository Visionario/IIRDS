#!/bin/bash
# IIRDS - 0.6.5 beta
# by Ingress Agent VisX (E) - Venezuela
# If you like this please say hi!! on intel COMM
#
# NOTES: IIRDS was made initially for use in my Raspberry Pi and it is very optimized for it
# was tested on Ubuntu and Lubuntu running inside a Virtual Box and is really cool!!
#
#
#Parameters and arguments
# -w width, default $SCREEN_W
# -h height, default $SCREEN_H
# -l (Map link) default $HOMEPAGE (please use quotes)
# -d delay to capture (segs) 
# -e email to send screenshot, empty for NO SEND email
# -t Timelapse, argument is number for minutes. Default $MINUTES=0
# -q Quality of jpg 100 max, recomended for view in smartphone 30, for timelapse >70, best is 100
# 
#

#Set default screen values
#WARNING: Raspberry is slow if these values grow, it works fine 1920x1080, faster 1080x800
SCREEN_W=1920
SCREEN_H=1080
SCREEN_D=16

#Default homepage (param -l)
HOMEPAGE="YOUR-DEFAULT-HOMEPAGE"

#Secs to wait before screenshot
# You must increment this value if SCREEN_W and SCREEN_H grows
DELAYTOCAPTURE=90

#Quality of JPG
JPG_QUALITY=30

#Default minutes for timelapse
MINUTES=0

#Offset to crop (Ninatic and Ingress Intel can change this)
OFFSET_Y=180
OFFSET_X=40



#Process arguments
while getopts ":w:h:d:l:e:t:q:" opt; do
  case $opt in
    w)
      echo "-w $OPTARG" >&2
	  SCREEN_W=$OPTARG
      ;;
    h)
      echo "-h $OPTARG" >&2
	  SCREEN_H=$OPTARG
      ;;
    d)
      echo "-d $OPTARG" >&2
	  DELAYTOCAPTURE=$OPTARG
      ;;
    e)
      echo "-e $OPTARG" >&2
	  SENDTO=$OPTARG
      ;;
    t)
      echo "-t $OPTARG" >&2
	  MINUTES=$OPTARG
      ;;
    q)
      echo "-q $OPTARG" >&2
	  JPG_QUALITY=$OPTARG
      ;;
    l)
      echo "-l $OPTARG" >&2
		if [ -z "$OPTARG" ]; then
			echo "Ingress Intel Link to map?"
			exit 1
		fi
	  HOMEPAGE=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

#Lock this process
[ -f running ] && exit
# Create lock file
echo $$ > running

#Calculate time start
timestart=$(date +"%s")

#Calculate time end
timeend=$((timestart + ($MINUTES*60)))

#Counter for screenshots
SCREENSHOTSCOUNTER=1

#Prepare Virtual Screen 
echo "Starting Xvfb ${SCREEN_W}x${SCREEN_H}x${SCREEN_D}"
Xvfb :99 -screen 0 ${SCREEN_W}x${SCREEN_H}x${SCREEN_D} -noreset -nolisten tcp & XVFB_PID=$!

echo "."
echo "PID Xvfb:======> $XVFB_PID"
echo "."


while true
do

	#Delete all midori config directory with this screen dimensions (if exists)
	rm -rf ${PWD}/midori_config_${SCREEN_W}x${SCREEN_H}

	#Create directory again
	mkdir ${PWD}/midori_config_${SCREEN_W}x${SCREEN_H}/ 

	#Copy original files from base
	cp ${PWD}/midori_config_base/*  ${PWD}/midori_config_${SCREEN_W}x${SCREEN_H}

	#Prepare Midori browser config with this parameters
	CONFIGDATA="[settings]\nlast-window-width=${SCREEN_W}\nlast-window-height=${SCREEN_H}\nhomepage=${HOMEPAGE}\n"
	CONFIGEXTRA=`cat config-extra`
	CONFIGDESTDIR=${PWD}/midori_config_${SCREEN_W}x${SCREEN_H}
	CONFIGDESTFILE=${CONFIGDESTDIR}/config
	printf $CONFIGDATA > $CONFIGDESTFILE
	echo "$CONFIGEXTRA" >> $CONFIGDESTFILE

	#Launch Midori Browser
	echo "Starting Midori Browser... (${SCREEN_W}x${SCREEN_H}x${SCREEN_D})"
	DISPLAY=:99 midori -c "$CONFIGDESTDIR" -e Fullscreen -e Navigationbar -e Statusbar & BROWSER_PID=$!
	echo "."
	echo "PID Browser:=====> $BROWSER_PID"
	echo "."

	#Wait $DELAYTOCAPTURE to screenshot
	echo "Waiting $DELAYTOCAPTURE secs to screenshot..."
	sleep $DELAYTOCAPTURE

	#Capture screen (screenshot)
	echo "Screenshot ${SCREEN_W}x${SCREEN_H} / # $SCREENSHOTSCOUNTER"
	FILENAME="iirds_${SCREEN_W}x${SCREEN_H}_`date +"%Y%m%d_%H%M%S"`".jpg
	
	#Capture and Crop
	DISPLAY=:99 import -window root -crop $(($SCREEN_W - $OFFSET_X))x$(($SCREEN_H - $OFFSET_Y))+0+10 -gravity Center +repage ${FILENAME} -quality ${JPG_QUALITY}
	
	#Increments screenshot counter
	SCREENSHOTSCOUNTER=$((SCREENSHOTSCOUNTER+1))

	#Kill Browser
	kill $BROWSER_PID
	sleep 3

	if [ -z ${SENDTO+x} ]; then 
		echo "Email not found - Do not send by email"; 
	else 
		#Send mail
		echo ${HOMEPAGE} >homepage
		echo "Sending email to:${SENDTO} Filename:${FILENAME}"
		(cat homepage; uuencode ${FILENAME} ${FILENAME}) | mail -s "${FILENAME}" ${SENDTO} 
	fi

	# One Screenshot (No timelapse)
	if [ $MINUTES == 0 ]
	then
		break
	fi 
	
	#Check for end of timelapse
	timenow=$(date +"%s")
	if [ "$timenow" -gt "$timeend" ]
	then
		break
	fi
	
done

#Kill Xvfb
kill $XVFB_PID

# Remove lock file
rm -f running

