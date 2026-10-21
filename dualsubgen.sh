#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <video url>" >&2
    exit 1
}

url="${1:-}"
[ -z "$url" ] && usage

# Check that required commands are available
for cmd in yt-dlp ffmpeg python3; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "ERROR: '$cmd' not found in PATH." >&2
        exit 1
    }
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
output_template='%(title)s/%(title)s.%(ext)s'

# Get the expected output filename in advance
# (--no-playlist restricts processing to a single video)
video_file="$(yt-dlp --ignore-config --no-playlist \
    --get-filename --output "$output_template" --simulate "$url")"
echo "Target file: ${video_file}"

# Download the video (overwrite existing files when re-running)
yt-dlp --ignore-config --no-playlist \
    --force-overwrites --output "$output_template" "$url" \
    || { echo "ERROR: yt-dlp download error!" >&2; exit 1; }

# Verify the file actually exists (guards against extension mismatches)
if [ ! -f "$video_file" ]; then
    echo "ERROR: downloaded file not found: $video_file" >&2
    exit 1
fi

# Extract audio from the video file with ffmpeg
audio_file="${video_file%.*}.mp3"
ffmpeg -hide_banner -loglevel error -y -i "$video_file" -vn "$audio_file" \
    || { echo "ERROR: ffmpeg mp3 extraction error!" >&2; exit 1; }

# Generate subtitles
python3 "${SCRIPT_DIR}/dualsubgen.py" "$audio_file" \
    || { echo "ERROR: subtitle generation failed!" >&2; exit 1; }
