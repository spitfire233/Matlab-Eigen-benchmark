#!/bin/bash

PID=$1
OUT=$2

echo "time,mem_kb" > $OUT

while kill -0 $PID 2>/dev/null; do
    MEM=$(ps -o rss= -p $PID)
    TIME=$(date +%s%N)
    echo "$TIME,$MEM" >> $OUT
    sleep 0.05
done
