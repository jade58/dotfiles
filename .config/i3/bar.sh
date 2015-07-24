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

#	}}}


#	{{{ Icons

iconbyname() {
	echo '"icon":"'$HOME/.config/i3/icons/$1'.xbm"'
}

icon_kernel=`iconbyname arch`
icon_sound_on=`iconbyname sound_on`
icon_sound_off=`iconbyname sound_off`
icon_capslock=`iconbyname capslock`
icon_numlock=`iconbyname numlock`
icon_cpu=`iconbyname cpu`
icon_language=`iconbyname kbd`
icon_brightness=`iconbyname sun`
icon_csq=`iconbyname csq`

for icon_battary in 0 10 20 30 40 50 60 70 80 90 100; do
	var="icon_battary_$icon_battary"
	full_path=`iconbyname "battary/battary_$icon_battary"`
	declare -g "$var=$full_path"
done

icon_color='"icon_color":"'$color_white'"'

#	}}}


init_kernel() {
	## JSON output
	full_text='"full_text":"'`uname -sr`'"'
	color='"color":"'$color_std'"'
	kernel='{'$full_text','$color','$icon_kernel','$icon_color'},'
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


#	{{{ Signal Strength

init_csq() {
	# csqd, yes...
	sudo killall csqd
	sudo $HOME/bin/csqd "/dev/ttyUSB2" &
}

get_csq() {
	csq=`cat /tmp/csq.txt`

	## JSON output
	full_text='"full_text":"CSQ: '$csq'%"'
	color='"color":"'$color_std'"'
	csq='{'$full_text','$color','$icon_csq','$icon_color'},'
}

#	}}}


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

get_capslock() {
	capslock=`xset q\
			| grep "Caps Lock:"\
			| awk '{print($4)}'\
			| tr a-z A-Z`

	## JSON output
	full_text='"full_text":"'$capslock'"'

	color0='"color":"'$color_std'"'
	if [ "$capslock" == "ON" ]; then
		color1=$color_waring
	else
		color1=$color_white
	fi
	color1='"icon_color":"'$color1'"'

	capslock='{'$full_text','$color0','$icon_capslock','$color1'},'
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

get_battary_level() {
	battary_level=`cat /sys/class/power_supply/BAT0/capacity`

	## JSON output
	full_text='"full_text":"'$battary_level'%"'

	battary_color0=$color_std   # text
	battary_color1=$color_white # icon
	if (( "$battary_level" <= "25" )); then
		battary_color0=$color_waring
		battary_color1=$color_waring
		if (( "$battary_level" <= "10" )); then
			battary_color0=$color_danger
			battary_color1=$color_danger
		fi
	fi
	color0='"color":"'$battary_color0'"'
	color1='"icon_color":"'$battary_color1'"'

	case "$battary_level" in
		[0-5])           icon_battary=$icon_battary_0   ;;
		[6-9] | 1[0-5])  icon_battary=$icon_battary_10  ;;
		1[6-9] | 2[0-5]) icon_battary=$icon_battary_20  ;;
		2[6-9] | 3[0-5]) icon_battary=$icon_battary_30  ;;
		3[6-9] | 4[0-5]) icon_battary=$icon_battary_40  ;;
		4[6-9] | 5[0-5]) icon_battary=$icon_battary_50  ;;
		5[6-9] | 6[0-5]) icon_battary=$icon_battary_60  ;;
		6[6-9] | 7[0-5]) icon_battary=$icon_battary_70  ;;
		7[6-9] | 8[0-5]) icon_battary=$icon_battary_80  ;;
		8[6-9] | 9[0-5]) icon_battary=$icon_battary_90  ;;
		9[6-9] | 100)    icon_battary=$icon_battary_100 ;;
	esac

	battary_level='{'$full_text','$color0','$icon_battary','$color1'},'
}

get_date() {
	date=`date +%a\ %d.%m.%Y\
			| tr a-z A-Z`

	## JSON output
	full_text='"full_text":"'$date'"'
	color='"color":"'$color_std'"'
	date='{'$full_text','$color'},'
}


#	{{{ The last block

get_time() {
	time=`date +%H:%M:%S`

	# JSON output
	full_text='"full_text":"'$time' "'
	color='"color":"'$color_std'"'
	time='{'$full_text','$color'}'
}

#	}}}


blocks=(
	[10]=kernel
	[20]=language
	[30]=numlock
#	[40]=capslock
#	[50]=csq
	[60]=heating_cpu
#	[70]=brightness
	[80]=sound
	[90]=battary_level
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