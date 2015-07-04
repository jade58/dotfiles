#!/bin/sh

core='Core'
core=`sensors | grep $core`
core=`echo "$core" | awk '{print($3);}'`
core=`echo "$core" | sed 's/+//g;s/.0°C//g'`

cpu0=`echo $core | awk '{print($1);}'`
cpu1=`echo $core | awk '{print($2);}'`
cpu2=`echo $core | awk '{print($3);}'`
cpu3=`echo $core | awk '{print($4);}'`

temp=`echo "scale = 1; ($cpu0 + $cpu1 + $cpu2 + $cpu3) / 4" | bc`
echo $temp
