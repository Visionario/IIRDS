Ingress Intel Remote Desktop (IIRDS)
====================================
Take an screenshot (JPG) of a Intel Map using a map link like https://www.ingress.com/intel?ll=8.289024,-62.742648&z=14 and send to you.

Useful if you are mobile with your smartphone and not have a PC

IIRDS - 0.5 beta

by Agent VisX (E) - Venezuela

If you like this please say hi!! on intel COMM


NOTES: IIRDS was made initially for use in my 'Raspberry Pi' and it is very optimized for it. Was tested on Ubuntu and Lubuntu running inside a Virtual Box and is really cool!!

# Requirement
Midori Browser

`sudo apt-get install midori`

ImageMagick

`sudo apt-get install imagemagick`


Xvfb

`sudo apt-get install xvfb`

# Installing
1. Install midori browser and run for first time
2. Login to http://ingress.com/intel with your credentials and check if you can open any map
3. Close Midori
4. Copy directory `~/.config/midori` to your directory and rename to `midori_config_base` (its save your credentials and cookies inside)


# Usage

###Config
See `iirds.sh` and change 
```
HOMEPAGE="YOUR-DEFAULT-HOMPAGE"
SENDTO="YOUREMAIL@YOURDOMAIN.COM"
```

If you need other resolution by default please change

```
SCREEN_W=1920
SCREEN_H=1080
```


### Options
```
	-w width, default $SCREEN_W
	-h height, default $SCREEN_H
	-l (Map link) default $HOMEPAGE
	-d delay to capture (segs) 
	-e email to send screenshot, default $SENDTO
```

