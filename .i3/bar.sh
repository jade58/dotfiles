#!/bin/bash

color_std="#cccccc"
color_waring="#cc0000"

echo '{"version":1}[[],'

# /bin/sudo killall csq.sh
# /bin/sudo ~/.i3/csq.sh &
 
while [ 1 ]; do

	##
	## brightness
	##
#	brg=$(cat /sys/class/backlight/intel_backlight/brightness)
#	brg_max=$(cat /sys/class/backlight/intel_backlight/max_brightness)
#	brg_lvl=$(echo "scale=2; $brg/$brg_max*100" | bc | sed -r 's/\..+//')

#	capslock=$(xset q | grep "Caps Lock:" | awk '{print($4)}')
	numlock=$(xset q | grep "Num Lock:" | awk '{print($8)}' | tr a-z A-Z)
 
	lng=$(skb noloop | head -c 2 | tr a-z A-Z)
 
	time=$(date +%H:%M:%S)
	date=$(date +%d.%m.%Y)

	battery_level=$(cat /sys/class/power_supply/BAT0/capacity)
	
	if (( "$battery_level" <= "10" )); then
		baterry_color=$color_waring
	else
		baterry_color=$color_std
	fi
 
	snd_level=$(amixer get Master | grep 'Mono:' | sed 's/\].*$//;s/^.*\[//')
	snd_state=$(amixer get Master | grep 'Mono:' | awk '{print($6);}' | tr a-z A-Z) 

#	csq=`cat /tmp/csq.txt`

	cputemp=`$HOME/.i3/cputemp.sh`

	buffer="["
	buffer=$buffer"{ \"full_text\":\" $lng \", \"color\":\"$color_std\"},"
	buffer=$buffer"{ \"full_text\":\" NUM: $numlock \", \"color\":\"$color_std\"},"
	buffer=$buffer"{ \"full_text\":\" $cputemp°C \", \"color\":\"$color_std\"},"
#	buffer=$buffer"{ \"full_text\":\" CSQ: $csq% \", \"color\":\"$color_std\"},"
#	buffer=$buffer"{ \"full_text\":\" BRG: $brg_lvl% \", \"color\":\"$color_std\"},"
	buffer=$buffer"{ \"full_text\":\" SND$snd_state: $snd_level \", \"color\":\"$color_std\"},"
	buffer=$buffer"{ \"full_text\":\" BAT: $battery_level% \", \"color\":\"$baterry_color\"},"
	buffer=$buffer"{ \"full_text\":\" $date \", \"color\":\"$color_std\"},"
	buffer=$buffer"{ \"full_text\":\" $time \", \"color\":\"$color_std\"}"
	buffer=$buffer"],"
 
	echo $buffer
    sleep 0.5
done
