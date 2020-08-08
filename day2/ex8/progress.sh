#!/bin/bash
max=60
dot="."
for number in $(seq 0 $max); do
    for port in $(seq 9880 9881); do
        # echo curl -XPOST -d "json={\"hello\":\"$number\"}" http://localhost:$port/test
        curl -XPOST -d "json={\"hello\":\"$number\"}" http://localhost:$port/test
    done
    echo -ne "[$number/$max] $dot\r"
    sleep 1
    dot="$dot."
done
tree
