#!/bin/bash

# history of dmenu
hist="$HOME/.i3/dmenu.log"

# font
fn="DejaVu Mono:size=8"

# colors
nb="#222222"
nf="#dddddd"
sb="#dddddd"
sf="#222222"

# prompt
p=":"

# run
dmenu_run -hist "$hist" -fn "$fn" -nb $nb -nf $nf -sb $sb -sf $sf -p "$p"
