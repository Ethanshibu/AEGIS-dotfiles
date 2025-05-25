#!/bin/bash

# Spinning fan frames
frames=('/' '─' '\' '|')
# CPU usage sampling
read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
cpu_total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
cpu_idle1=$((idle + iowait))
sleep 0.3
read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
cpu_total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
cpu_idle2=$((idle + iowait))

cpu_delta=$((cpu_total2 - cpu_total1))
idle_delta=$((cpu_idle2 - cpu_idle1))
cpu_usage=$(( (100 * (cpu_delta - idle_delta)) / cpu_delta ))

# Fan spin logic
frame_index=$(( ( $(date +%s) + $(date +%N) / 100000000 ) % 4 ))
fan_icon="${frames[$frame_index]}"

# Color based on usage
if (( cpu_usage >= 85 )); then
    color="#FF5555"
elif (( cpu_usage >= 50 )); then
    color="#F1C40F"
else
    color="#50FA7B"
fi

# Output format: spinning fan + percentage
echo "$fan_icon ${cpu_usage}%"
echo "$color"

