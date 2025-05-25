#!/bin/bash

CACHE_FILE="/tmp/i3blocks_weather_cache"
CACHE_TTL=600  # 10 minutes

# Get cached data if fresh
if [[ -f $CACHE_FILE ]]; then
    age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
    if (( age < CACHE_TTL )); then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Fetch data from wttr.in in JSON format
weather_json=$(curl -s 'https://wttr.in/?format=j1')

if [[ -z "$weather_json" ]]; then
    echo "🌥️ Error fetching weather"
    echo "#FF5555"
    exit 1
fi

# Parse JSON with jq (jq must be installed)
temp_c=$(echo "$weather_json" | jq -r '.current_condition[0].temp_C')
condition=$(echo "$weather_json" | jq -r '.current_condition[0].weatherDesc[0].value')
humidity=$(echo "$weather_json" | jq -r '.current_condition[0].humidity')

# Map some conditions to icons
case "$condition" in
    *Clear* | *Sunny*) icon="☀️" ;;
    *Partly* | *Cloudy*) icon="⛅" ;;
    *Overcast* | *Clouds*) icon="☁️" ;;
    *Rain* | *Showers*) icon="🌧️" ;;
    *Thunderstorm*) icon="⛈️" ;;
    *Snow*) icon="❄️" ;;
    *Fog* | *Mist*) icon="🌫️" ;;
    *) icon="🌡️" ;;
esac

# Color based on temperature
if (( temp_c >= 30 )); then
    color="#FF4500"  # hot - orange red
elif (( temp_c >= 20 )); then
    color="#FFA500"  # warm - orange
elif (( temp_c >= 10 )); then
    color="#FFD700"  # mild - gold
elif (( temp_c >= 0 )); then
    color="#87CEEB"  # cool - sky blue
else
    color="#1E90FF"  # cold - dodger blue
fi

# Separator is just spaces (3 spaces)
sep="   "

# Format output string without wind speed
output="$icon ${temp_c}°C${sep}${condition}${sep}💧 ${humidity}%"

# Cache output for next runs
echo -e "$output\n$color" > "$CACHE_FILE"

# Print for i3blocks
echo "$output"
echo "$color"

