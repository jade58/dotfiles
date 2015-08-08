#!/usr/bin/env bash

amixer set Master toggle

state=`amixer get Master\
		| grep Mono:\
		| sed 's/.*\[//g;s/\].*//g'`

notify-send "Sound: $state"
