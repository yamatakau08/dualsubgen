#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

url=$1

if [ -z $url ]; then
    echo "Usage: $0 <video url>" >&2
    exit 1
fi

outputtemplate='%(title)s/%(title)s.%(ext)s'
output_file=$(yt-dlp --get-filename --output ${outputtemplate} --simulate "$url")

if [ $? -ne 0 ]; then
    echo "status エラー: 動画タイトルの取得に失敗しました。URLを確認してください。" >&2
    exit 1
fi

if [ -f "${output_file}" ]; then
    echo "status エラー: 動画タイトルの取得に失敗しました。URLを確認してください。" >&2
    exit 1
fi

yt-dlp -f 'b[ext=mp4]' --output ${outputtemplate} $url \
|| {
    echo "ERROR: mp4ダウンロードに失敗しました。URL: $url"
    exit 1;
}

echo "extract the audio mp3 file to generate srt file!"
yt-dlp -t mp3 --output ${outputtemplate} $url \
|| {
    echo "ERROR: mp3ダウンロードに失敗しました。URL: $url" >&2
    exit 1;
}

mp3_file=${output_file%.*}.mp3

if [ ! -f "${mp3_file}" ]; then
    echo "致命的なエラー: ダウンロード後にMP3ファイルが見つかりません。" >&2
    exit 1
fi

python "${SCRIPT_DIR}/dualsubgen.py" "${mp3_file}"

