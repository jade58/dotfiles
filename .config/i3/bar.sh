#!/usr/bin/env bash


##
## Generate JSON for i3bar
## kalterfive
##


#	{{{ Colors

color_white='#FFFFFF'

color_std='#CCCCCC'
color_waring='#CCCC00'
color_danger='#CC0000'

icon_color='"icon_color":"'$color_white'"'

#	}}}


iconbyname() {
	echo '"icon":"'$HOME/.config/i3/icons/$1'.xbm"'
}


##
## Kernel version
##

init_kernel() {
	## JSON output
	full_text='"full_text":"'`uname -sr`'"'
	color='"color":"'$color_std'"'
	icon_kernel=`iconbyname arch`
	kernel='{'$full_text','$color','$icon_kernel','$icon_color'},'
}

#get_kernel() {
#}


##
## Keyboard
##

init_language() {
	icon_language=`iconbyname kbd`
}

get_language() {
	lng=`skb noloop\
			| head -c 2\
			| tr a-z A-Z`

	## JSON output
	full_text='"full_text":"'$lng'"'
	color='"color":"'$color_std'"'
	language='{'$full_text','$color','$icon_language','$icon_color'},'
}


##
## Signal Strength
##

init_csq() {
	# csqd, yes...
	sudo killall csqd
	sudo $HOME/bin/csqd "/dev/ttyUSB2" &

	icon_csq=`iconbyname csq`
}

get_csq() {
	csq=`cat /tmp/csq.txt`

	## JSON output
	full_text='"full_text":"CSQ: '$csq'%"'
	color='"color":"'$color_std'"'
	csq='{'$full_text','$color','$icon_csq','$icon_color'},'
}


##
## Num Lock state
##

init_numlock() {
	icon_numlock=`iconbyname numlock`
}

get_numlock() {
	numlock=`xset q\
			| grep "Num Lock:"\
			| awk '{print($8)}'\
			| tr a-z A-Z`

	## JSON output
	full_text='"full_text":"'$numlock'"'
	color='"color":"'$color_std'"'
	numlock='{'$full_text','$color','$icon_numlock','$icon_color'},'
}


##
## Caps Lock state
##

init_capslock() {
	icon_capslock=`iconbyname capslock`
}

get_capslock() {
	capslock=`xset q\
			| grep "Caps Lock:"\
			| awk '{print($4)}'\
			| tr a-z A-Z`

	## JSON output
	full_text='"full_text":"'$capslock'"'

	if [ "$capslock" == "ON" ]; then
		color0=$color_waring
		color1=$color_waring
	else
		color0=$color_std
		color1=$color_white
	fi
	color0='"color":"'$color0'"'
	color1='"icon_color":"'$color1'"'

	capslock='{'$full_text','$color0','$icon_capslock','$color1'},'
}


##
## Heating CPU
##

init_heating_cpu() {
	icon_cpu=`iconbyname cpu`
}

get_heating_cpu() {
	sensors=`sensors\
			| grep Core\
			| sed 's/\..*//g;s/.*+//g'`

	heating_cpu=0
	kernels=0
	for core in $sensors; do
		heating_cpu=$(($heating_cpu + $core))
		kernels=$(($kernels + 1))
	done
	heating_cpu=$(($heating_cpu / $kernels))

	## JSON output
	full_text='"full_text":"'$heating_cpu'°C"'

	cputemp_color0=$color_std   # text
	cputemp_color1=$color_white # icon
	if (( "$heating_cpu" >= "70" )); then
		cputemp_color0=$color_waring
		cputemp_color1=$color_waring
		if (( "$heating_cpu" >= 80 )); then
			cputemp_color0=$color_danger
			cputemp_color1=$color_danger
		fi
	fi
	color0='"color":"'$cputemp_color0'"'
	color1='"icon_color":"'$cputemp_color1'"'

	heating_cpu='{'$full_text','$color0','$icon_cpu','$color1'},'
}


##
## Brightness level
##

init_brightness() {
	icon_brightness=`iconbyname sun`
}

get_brightness() {
	brightness=`cat /sys/class/backlight/intel_backlight/brightness`
	max_brightness=`cat /sys/class/backlight/intel_backlight/max_brightness`
	brightness_level=`echo "scale = 2; $brightness * 100 / $max_brightness"\
			| bc`

	## JSON output
	full_text='"full_text":"'$brightness_level'%"'
	color='"color":"'$color_std'"'
	brightness='{'$full_text','$color','$icon_brightness','$icon_color'},'
}


##
## Sound state (level and mute)
##

init_sound() {
	icon_sound_on=`iconbyname sound_on`
	icon_sound_off=`iconbyname sound_off`
}

get_sound() {
	sound_level=`amixer get Master\
			| grep 'Mono:'\
			| sed 's/\].*$//;s/^.*\[//'`

	sound_state=`amixer get Master\
			| grep 'Mono:'\
			| awk '{print($6);}'`

	## JSON output
	if [ "$sound_state" == "[on]" ]; then
		icon=$icon_sound_on
	elif [ "$sound_state" == "[off]" ]; then
		icon=$icon_sound_off
	fi

	full_text='"full_text":"'$sound_level'"'
	color='"color":"'$color_std'"'
	sound='{'$full_text','$color','$icon','$icon_color'},'
}


##
## Battery level
##

init_battery_level() {
	for icon_battery in 0 10 20 30 40 50 60 70 80 90 100; do
		var="icon_battery_$icon_battery"
		full_path=`iconbyname "battery/battery_$icon_battery"`
		declare -g "$var=$full_path"
	done
}

get_battery_level() {
	battery_level=`cat /sys/class/power_supply/BAT0/capacity`

	## JSON output
	full_text='"full_text":"'$battery_level'%"'

	battery_color0=$color_std   # text
	battery_color1=$color_white # icon
	if (( "$battery_level" <= "25" )); then
		battery_color0=$color_waring
		battery_color1=$color_waring
		if (( "$battery_level" <= "10" )); then
			battery_color0=$color_danger
			battery_color1=$color_danger
		fi
	fi
	color0='"color":"'$battery_color0'"'
	color1='"icon_color":"'$battery_color1'"'

	case "$battery_level" in
		[0-5])           icon_battery=$icon_battery_0   ;;
		[6-9] | 1[0-5])  icon_battery=$icon_battery_10  ;;
		1[6-9] | 2[0-5]) icon_battery=$icon_battery_20  ;;
		2[6-9] | 3[0-5]) icon_battery=$icon_battery_30  ;;
		3[6-9] | 4[0-5]) icon_battery=$icon_battery_40  ;;
		4[6-9] | 5[0-5]) icon_battery=$icon_battery_50  ;;
		5[6-9] | 6[0-5]) icon_battery=$icon_battery_60  ;;
		6[6-9] | 7[0-5]) icon_battery=$icon_battery_70  ;;
		7[6-9] | 8[0-5]) icon_battery=$icon_battery_80  ;;
		8[6-9] | 9[0-5]) icon_battery=$icon_battery_90  ;;
		9[6-9] | 100)    icon_battery=$icon_battery_100 ;;
	esac

	battery_level='{'$full_text','$color0','$icon_battery','$color1'},'
}


##
## Date and time
##

get_date() {
	date=`date +%a\ %d.%m.%Y\
			| tr a-z A-Z`

	## JSON output
	full_text='"full_text":"'$date'"'
	color='"color":"'$color_std'"'
	date='{'$full_text','$color'},'
}

## The last block
get_time() {
	time=`date +%H:%M:%S`

	# JSON output
	full_text='"full_text":"'$time' "'
	color='"color":"'$color_std'"'
	time='{'$full_text','$color'}'
}


blocks=(
	[10]=kernel
	[20]=language
	[30]=numlock
	[40]=capslock
	[50]=csq
	[60]=heating_cpu
	[70]=brightness
	[80]=sound
	[90]=battery_level
	[100]=date
	[110]=time
)

unset func_list
bar='['
for block in ${blocks[@]}; do
	init_$block 2> /dev/null
	func_list+=" get_$block"
	bar+='${'$block':-}'
done
bar+="],"

echo '{"version":1}['
while [ 1 ]; do
	for func in $func_list; do
		$func 2> /dev/null
	done
	eval echo -e \"${bar//\\/\\\\}\" || exit 3

	sleep 0.5
done
