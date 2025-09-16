#!/bin/bash

input="$1"
output="${2:-compressed.mp4}"
target_size_mb=10
target_size_bytes=$((target_size_mb * 1024 * 1024))

if [[ -z "$input" ]]; then
    echo "Usage: $0 input_file [output_file]"
    exit 1
fi

# Get video duration in seconds
duration=$(ffprobe -v error -show_entries format=duration \
          -of default=noprint_wrappers=1:nokey=1 "$input")
duration=${duration%.*}  # Remove decimals

# Calculate target bitrate in kilobits/sec
# Formula: (target size in bits) / duration in seconds
target_bitrate=$(( (target_size_bytes * 8) / duration / 1000 ))

# FFmpeg encode with target bitrate
ffmpeg -i "$input" -b:v "${target_bitrate}k" -bufsize "${target_bitrate}k" \
    -preset slow -c:v libx264 -c:a aac -movflags +faststart "$output"

# Check final size
final_size=$(stat -c%s "$output")
echo "Final size: $((final_size / 1024 / 1024)) MB"
