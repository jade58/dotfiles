##
## set brightness
##

echo 3000 | sudo tee /sys/class/backlight/intel_backlight/brightness > /dev/null


##
## Connect to the Internet
##

if [ -e "/dev/ttyUSB0" ]; then
#	/bin/sudo usb_modeswitch -v 0x12d1 -p 0x1446 -J
	/bin/sudo pppd call ${@:-provider}
fi


##
## 'X' start
##

startx
