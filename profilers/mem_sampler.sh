#!/bin/bash
PID=$1   # Process ID passed as first argument
OUT=$2   # Output file passed as second argument
# Write header to output file
echo "mem_kb" > $OUT
# Loop while the process is still running
while kill -0 $PID 2>/dev/null; do
    # Get resident set size (RSS) in KB for the process
    MEM=$(ps -o rss= -p $PID)
    # Append memory usage value to the output file
    echo "$MEM" >> $OUT
    # Sleep for 0.01 seconds before next sample
    sleep 0.01
done