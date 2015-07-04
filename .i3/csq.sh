#!/bin/sh

interface="$1"

while [ 1 ]; do
	if [ -e $interface ]; then
		echo -e "AT+CSQ\r\n" > $interface
		csq=`timeout 1 gawk '/^+CSQ/{print gensub(/,.*/,"","g",$2); exit}' $interface`

		x=$(($csq+0))
		if ! [ "$csq" == "$x" ]; then
			csq=`cat /tmp/csq.txt`
		else
#			csq=$(($csq*100/30))
			csq=$(echo "scale = 1; $csq * 100 / 30" | bc)
		fi
	else
		csq="0"
	fi

	echo $csq > /tmp/csq.txt
	sleep 1
done
