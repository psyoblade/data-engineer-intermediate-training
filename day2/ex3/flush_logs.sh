#!/bin/bash
let xfrom=0
let from=0
let to=1000
sleep=1
for x in $(seq 0 9); do
    let from=$(($x*1000))
    let to=$(($from+1000))
    let xfrom=$(($from+1))
    echo "sed -n \"${xfrom},${to}p\" ./apache_logs >> source/accesslogs"
    sed -n "${xfrom},${to}p" ./apache_logs >> source/accesslogs
    echo "sleep $sleep"
    sleep $sleep
    mv source/accesslogs source/accesslogs.$x
done
