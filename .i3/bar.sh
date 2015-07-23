#!/usr/bin/env bash


##
## Generate JSON for i3bar
## kalterfive
##


#	{{{ Colors

color_std="#cccccc"
color_waring="#ff0000"

#	}}}


get_kernel() {
	## JSON output
	full_text='"full_text":" '`uname -sr`' "'
	color='"color":"'$color_std'"'
	kernel='{'$full_text','$color'},'
}

get_language() {
	lng=`skb noloop\
			| head -c 2\
			| tr a-z A-Z`

	## JSON output
	full_text='"full_text":" '$lng' "'
	color='"color":"'$color_std'"'
	language='{'$full_text','$color'},'
}

get_numlock() {
	numlock=`xset q\
			| grep "Num Lock:"\
			| awk '{print($8)}'\
			| tr a-z A-Z`

	## JSON output
	full_text='"full_text":" NUM: '$numlock' "'
	color='"color":"'$color_std'"'
	numlock='{'$full_text','$color'},'
}


#	{{{ Signal Strength Quality

init_csq() {
	# csqd, yes...
	sudo killall csq.sh
	sudo $HOME/.i3/csq.sh "/dev/ttyUSB2" &
}

get_csq() {
	csq=`cat /tmp/csq.txt`

	## JSON output
	full_text='"full_text":" CSQ: '$csq'% "'
	color='"color":"'$color_std'"'
	csq='{'$full_text','$color'},'
}

#	}}}


get_capslock() {
	capslock=`xset q\
			| grep "Caps Lock:"\
			| awk '{print($4)}'\
			| tr a-z A-Z`

	## JSON output
	full_text='"full_text":" CPS: '$capslock' "'
	color='"color":"'$color_std'"'
	capslock='{'$full_text','$color'},'
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
	full_text='"full_text":" CPU: '$heating_cpu'°C "'

	cputemp_color=$color_std
	if (( "$heating_cpu" >= "70" )); then
		cputemp_color=$color_waring
	fi
	color='"color":"'$cputemp_color'"'

	heating_cpu='{'$full_text','$color'},'
}

get_brightness() {
	brightness=`cat /sys/class/backlight/intel_backlight/brightness`
	max_brightness=`cat /sys/class/backlight/intel_backlight/max_brightness`
	brightness_level=`echo "scale = 2; $brightness * 100 / $max_brightness"\
			| bc`

	## JSON output
	full_text='"full_text":" BRG: '$brightness_level'% "'
	color='"color":"'$color_std'"'
	brightness='{'$full_text','$color'},'
}

get_sound() {
	sound_level=`amixer get Master\
			| grep 'Mono:'\
			| sed 's/\].*$//;s/^.*\[//'`

	sound_state=`amixer get Master\
			| grep 'Mono:'\
			| awk '{print($6);}'\
			| tr a-z A-Z`

	## JSON output
	full_text='"full_text":" SND'$sound_state': '$sound_level' "'
	color='"color":"'$color_std'"'
	sound='{'$full_text','$color'},'
}

get_battary_level() {
	battary_level=`cat /sys/class/power_supply/BAT0/capacity`

	## JSON output
	full_text='"full_text":" BAT: '$battary_level'% "'

	battary_color=$color_std
	if (( "$battary_level" <= "10" )); then
		battary_color=$color_waring
	fi
	color='"color":"'$battary_color'"'

	battary_level='{'$full_text','$color'},'
}

get_date() {
	date=`date +%a\ %d.%m.%Y\
			| tr a-z A-Z`

	## JSON output
	full_text='"full_text":" '$date' "'
	color='"color":"'$color_std'"'
	date='{'$full_text','$color'},'
}


#	{{{ The last block

get_time() {
	time=`date +%H:%M:%S`

	# JSON output
	full_text='"full_text":" '$time' "'
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
		$func
	done
	eval echo -e \"${bar//\\/\\\\}\" || exit 3

	sleep 0.5
done
