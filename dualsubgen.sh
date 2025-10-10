#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

url=$1
output_file=$(yt-dlp --get-filename --output "%(title)s/%(title)s.%(ext)s" --simulate "$url")

if [ $? -ne 0 ]; then
    echo "status エラー: 動画タイトルの取得に失敗しました。URLを確認してください。" >&2
    exit 1
fi

if [ -z "$output_file" ]; then
    echo "status エラー: 動画タイトルの取得に失敗しました。URLを確認してください。" >&2
    exit 1
fi

echo "$output_file"

#mp3_file=${output_file/.mp4/.mp3}
mp3_file=${output_file%.*}.mp3

#yt-dlp -f 'b[ext=mp4]' --output "%(title)s/%(title)s.%(ext)s" --write-auto-subs --convert-subs srt $url \
yt-dlp -f 'b[ext=mp4]' --output "%(title)s/%(title)s.%(ext)s" $url \
|| {
    echo "ERROR: mp4ダウンロードに失敗しました。URL: $url"
    exit 1;
}

echo "extract the audio mp3 file to generate srt file!"
yt-dlp -t mp3 --output "%(title)s/%(title)s.%(ext)s" $url \
|| {
    echo "ERROR: mp3ダウンロードに失敗しました。URL: $url" >&2
    exit 1;
}

if [ -z "$mp3_file" ]; then
    echo "致命的なエラー: ダウンロード後にMP3ファイルが見つかりません。" >&2
    exit 1
fi

echo "$mp3_file"

python "${SCRIPT_DIR}/dualsubgen.py" "$mp3_file"

