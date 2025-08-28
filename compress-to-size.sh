#!/bin/bash

# Usage: ./compress-to-size.sh input.mp4 8 output.mp4
# $1 = input file
# $2 = target size in MB (e.g., 8)
# $3 = output file name

# In case script is not run with proper arguments
if [ $# -ne 3 ]; then
    echo "Usage: $0 input_file target_size_in_MB output_file"
    exit 1
fi

# The inputs saved as variables
INPUT="$1"
TARGET_MB="$2"
OUTPUT="$3"

# Convert MB to bits
TARGET_BITS=$((TARGET_MB * 1024 * 1024 * 8))

# Get duration in seconds using ffprobe
DURATION=$(ffprobe -v error -select_streams v:0 -show_entries format=duration \
           -of default=noprint_wrappers=1:nokey=1 "$INPUT")
           
if [ -z "$DURATION" ]; then
    echo "Could not get video duration"
    exit 1
fi

# Calculate total target bitrate in bits per second
BITRATE=$(echo "$TARGET_BITS / $DURATION" | bc)

# Assume audio gets 128k (128000 bps), subtract from total
AUDIO_BITRATE=128000
VIDEO_BITRATE=$((BITRATE - AUDIO_BITRATE))

if [ "$VIDEO_BITRATE" -le 0 ]; then
    echo "Target size too small for the duration. Increase size or lower audio bitrate."
    exit 1
fi

echo "Target bitrate: $BITRATE bps (video: $VIDEO_BITRATE, audio: $AUDIO_BITRATE)"
echo "Compressing to target size..."

# 2-pass compression with libx265
ffmpeg -y -i "$INPUT" -c:v libx265 -b:v "$VIDEO_BITRATE" -x265-params pass=1 -an -f mp4 /dev/null && \
ffmpeg -i "$INPUT" -c:v libx265 -b:v "$VIDEO_BITRATE" -x265-params pass=2 -c:a aac -b:a "$AUDIO_BITRATE" -pix_fmt yuv420p -tag:v hvc1 "$OUTPUT"

echo "Done. Saved to $OUTPUT"
