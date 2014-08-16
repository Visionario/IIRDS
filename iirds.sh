#!/bin/bash
# IIRDS - 0.5.1 beta
# by Agent VisX (E) - Venezuela
# If you like this please say hi!! on intel COMM
#
# NOTES: IIRDS was made initially for use in my Raspberry Pi and it is very optimized for it
# was tested on Ubuntu and Lubuntu running inside a Virtual Box and is really cool!!
#
#
#Parameters
# -w width, default $SCREEN_W
# -h height, default $SCREEN_H
# -l (Map link) default $HOMEPAGE (please use quotes)
# -d delay to capture (segs) 
# -e email to send screenshot, default $SENDTO
# 
#

#LOCK THIS PROCESS
[ -f running ] && exit

# Create lock file
echo $$ > running



#Set default screen values
#WARNING: Raspberry is slow if these values grow, it works fine 1920x1080, faster 1080x800
SCREEN_W=1920
SCREEN_H=1080
SCREEN_D=16

#Default homepage (param -l)
HOMEPAGE="YOUR-DEFAULT-HOMEPAGE"

#Secs to wait before screenshot
DELAYTOCAPTURE=70

#Quality of JPG
JPG_QUALITY=30

#To:, email addres to return the screenshot
SENDTO="YOUREMAIL@YOURDOMAIN.COM"


#Process arguments
while getopts ":w:h:d:l:e:" opt; do
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
      echo "-d $OPTARG" >&2
	  SENDTO=$OPTARG
      ;;
    l)
      echo "-l $OPTARG" >&2
		if [ -z "$OPTARG" ]; then
			echo "Where is Ingress Intel Link to map?"
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


#Prepare Virtual Screen 
echo "Starting Xvfb ${SCREEN_W}x${SCREEN_H}x${SCREEN_D}"
Xvfb :99 -screen 0 ${SCREEN_W}x${SCREEN_H}x${SCREEN_D} -noreset -nolisten tcp & XVFB_PID=$!

echo "."
echo "PID Xvfb:======> $XVFB_PID"
echo "."

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
echo "Screenshot ${SCREEN_W}x${SCREEN_H}"
FILENAME="iirds_${SCREEN_W}x${SCREEN_H}-`date +"%Y%m%d%k%M%S"`".jpg
DISPLAY=:99 import -window root ${FILENAME} -quality ${JPG_QUALITY}

#Kill process
kill $BROWSER_PID
sleep 4
kill $XVFB_PID
sleep 4

# Remove lock file
rm -f running

#Send mail
echo ${HOMEPAGE} >homepage
echo "Sending email to:${SENDTO} Filename:${FILENAME}"
#http://www.cyberciti.biz/faq/email-howto-send-text-file-using-unix-appleosx-bsd/

(cat homepage; uuencode ${FILENAME} ${FILENAME}) | mail -s "${FILENAME}" ${SENDTO} 
