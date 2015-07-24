##
## set brightness
## 2343,6 == 30%
##

echo 2344 | sudo tee /sys/class/backlight/intel_backlight/brightness > /dev/null


##
## Connect to the Internet
##

$HOME/bin/diald &


##
## 'X' start
##

# startx
startx
