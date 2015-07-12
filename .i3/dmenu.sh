#!/bin/bash

# history of dmenu
hist="$HOME/.i3/dmenu.log"

# font
fn="Terminus Re33:style=Regular:size=10"

# colors
nb="#222222"
nf="#dddddd"
sb="#dddddd"
sf="#222222"

# prompt
p=":"

# set language
if [ `skb -1` == "Rus" ]; then
	xdotool key Mode_switch
fi

# run
dmenu_run -hist "$hist" -fn "$fn" -nb $nb -nf $nf -sb $sb -sf $sf -p "$p"
