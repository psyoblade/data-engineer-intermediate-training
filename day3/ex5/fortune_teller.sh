#!/bin/bash
sleep 3
for x in $(seq 1 $1); do 
    say=`fortune -s`
    out=`echo ${say@Q} | sed -e "s/'//g" | sed -e 's/"//g' | sed -e 's/\\\\//g'`
    echo "{\"key\":\"$out\"}"
    sleep 1
done

