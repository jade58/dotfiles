#!/usr/bin/env bash

amixer set Master toggle

state=`amixer get Master\
		| grep Mono:\
		| sed 's/.*\[//g;s/\].*//g'\
		| tr a-z A-Z`

notify-send "Sound: $state"
