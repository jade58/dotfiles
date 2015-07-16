#!/usr/bin/env bash


color_std="#cccccc"
color_waring="#cc0000"


get_brg() {
	brg=`cat /sys/class/backlight/intel_backlight/brightness`
	brg_max=`cat /sys/class/backlight/intel_backlight/max_brightness`
	brg_lvl=`echo "scale = 2; $brg / $brg_max * 100"\
			| bc\
			| sed -r 's/\..+//'`

	brg="{\"full_text\":\" BRG: $brg_lvl% \",\"color\":\"$color_std\"},"
}


init_csq() {
	/bin/sudo killall csq.sh
	/bin/sudo $HOME/.i3/csq.sh "/dev/ttyUSB2" &
}

get_csq() {
	csq=`cat /tmp/csq.txt`
	csq="{\"full_text\":\" CSQ: $csq% \",\"color\":\"$color_std\"},"
}


get_capslock() {
	capslock=`xset q\
			| grep "Caps Lock:"\
			| awk '{print($4)}'\
			| tr a-z A-Z`

	capslock="{\"full_text\":\" CPS: $capslock \",\"color\":\"$color_std\"},"
}


get_lng() {
	lng=`skb noloop\
			| head -c 2\
			| tr a-z A-Z`

	lng="{\"full_text\":\" $lng \",\"color\":\"$color_std\"},"
}


get_numlock() {
	numlock=`xset q\
			| grep "Num Lock:"\
			| awk '{print($8)}'\
			| tr a-z A-Z`

	numlock="{\"full_text\":\" NUM: $numlock \",\"color\":\"$color_std\"},"
}


get_cputemp() {
	sensors=`sensors\
			| grep Core\
			| sed 's/\..*//g;s/.*+//g'`

	cputemp=0

	for core in $sensors; do
		cputemp=$(($cputemp + $core))
	done

	# у меня 4 ядра
	cputemp=$(($cputemp / 4))

	cputemp_color=$color_std
	if (( "$cputemp" >= "70" )); then
		cputemp_color=$color_waring
	fi

	cputemp="{\"full_text\":\" CPU: $cputemp°C \",\"color\":\"$cputemp_color\"},"
}


get_snd() {
	sndlvl=`amixer get Master\
			| grep 'Mono:'\
			| sed 's/\].*$//;s/^.*\[//'`

	snd_state=`amixer get Master\
			| grep 'Mono:'\
			| awk '{print($6);}'\
			| tr a-z A-Z`

	snd="{\"full_text\":\" SND$snd_state: $sndlvl \",\"color\":\"$color_std\"},"
}


get_battlvl() {
	battlvl=`cat /sys/class/power_supply/BAT0/capacity`

	batt_color=$color_std
	if (( "$battlvl" <= "10" )); then
		batt_color=$color_waring
	fi

	battlvl="{\"full_text\":\" BAT: $battlvl% \",\"color\":\"$batt_color\"},"
}


get_date() {
	date=`date +%d.%m.%Y`
	date="{\"full_text\":\" $date \",\"color\":\"$color_std\"},"
}


get_time() {
	time=`date +%H:%M:%S`
	time="{\"full_text\":\" $time \", \"color\":\"$color_std\"}"
}


blocks=(
	[10]=lng
	[20]=numlock
	[30]=capslock
#	[40]=csq
	[50]=cputemp
#	[60]=brg
	[70]=snd
	[80]=battlvl
	[90]=date
	[100]=time
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
