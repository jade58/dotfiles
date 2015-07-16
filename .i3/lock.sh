#!/bin/sh

# костыль, да ещё и работающий на половину
# amixer set Master toggle 

scrot /tmp/screen_locked.png
mogrify -scale 10% -scale 1000% /tmp/screen_locked.png
i3lock -i /tmp/screen_locked.png
