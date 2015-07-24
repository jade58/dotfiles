#!/usr/bin/env bash

case "$1" in
	button/power)
		case "$2" in
			PBTN)
				logger 'power/button PBTN'
				sudo poweroff
			;;

			*)
				logger "power/button $2"
			;;
		esac
	;;

	button/lid)
		case "$3" in
			close)
				logger 'LID closed'
				sudo pm-suspend
			;;

			open)
				logger 'LID opened'
			;;

			*)
				logger "ACPI action undefined: $3"
			;;
		esac
	;;

	button/sleep)
		case "$2" in
			SBTN)
				logger "ACPI button/sleep"
				echo -n mem | sudo tee /sys/power/state > /dev/null
			;;

			*)
				logger "ACPI action undefined: $2"
			;;
		esac
	;;

	video/brightnessdown)
		case "$2" in
			BRTDN)
				logger "ACPI video/brightnessdown"

#				not working
#				xbacklight -d :0 -dec 10

				bl_dev=/sys/class/backlight/intel_backlight
				step=100
				echo $(($(< $bl_dev/brightness) - $step)) >$bl_dev/brightness
			;;

			*)
				logger "ACPI action undefined: $2"
			;;
		esac
	;;

	video/brightnessup)
		case "$2" in
			BRTUP)
				logger "ACPI video/brightnessup"
#				not working
#				xbacklight -d :0 -inc 10

				bl_dev=/sys/class/backlight/intel_backlight
				step=100
				echo $(($(< $bl_dev/brightness) + $step)) >$bl_dev/brightness
			;;

			*)
				logger "ACPI action undefined: $2"
			;;
		esac
	;;

	*)
		logger "ACPI group/action undefined: $1 / $2"
	;;
esac
