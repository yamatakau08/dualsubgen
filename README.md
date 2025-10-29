# DualSubGen

**DualSubGen** is a lightweight Python and Shell-based tool designed to **generate and synchronize dual-language subtitle files** for videos.
It is primarily aimed at **language learners or bilingual viewers** who wish to combine two separate subtitle tracks (e.g., English and Japanese) into a single unified **`.srt`** file.

## Features

* **Merged Subtitle Output:** Generates a single `.srt` file containing both subtitle tracks merged together.
* **Simple Command-Line Interface (CLI):** Easy-to-use interface for quick subtitle generation.

## Requirements

- Python
- Python Package
  - [openai-whisper](https://pypi.org/project/openai-whisper/)
  - [googletrans](https://pypi.org/project/googletrans/)
- Nix (optional, for reproducible environments)

## Usage

Execute the shell script with the video URL as an argument:

```bash
./dualsubgen.sh <url_movie>
```

This command will:

1. Download the video and create a dedicated download directory named after the movie title.

2. Generate a new dual-language subtitle file named title.srt within that directory.

![demo](./demo.gif)

## Enjoy bilingual subtitles

To view the merged subtitles, load the downloaded movie and the generated subtitle file (title.srt) into a compatible video player,
such as:
- VLC Media Player
- mpv

You will then be able to enjoy the dual-language subtitles!
