#!/bin/bash

case "$1" in
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

	*)
		logger "ACPI group/action undefined: $1 / $2"
	;;
esac
