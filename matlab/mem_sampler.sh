#!/bin/bash

PID=$1
OUT=$2

echo "mem_kb" > $OUT

while kill -0 $PID 2>/dev/null; do
    MEM=$(ps -o rss= -p $PID)
    echo "$MEM" >> $OUT
    sleep 0.05
done
