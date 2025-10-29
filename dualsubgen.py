import sys, os, asyncio, threading, time, whisper
from datetime import timedelta
from googletrans import Translator

translator = Translator()

def fmt_time(s):
    h, m, sec = int(s // 3600), int(s % 3600 // 60), int(s % 60)
    ms = int((s - int(s)) * 1000)
    return f"{h:02}:{m:02}:{sec:02},{ms:03}"

def progress_dots(stop_event):
    """model.transcribe 実行中に '.' を定期的に出す"""
    while not stop_event.is_set():
        print('.', end='', flush=True)
        time.sleep(1)
    print() # 終了時に改行

def main():
    if len(sys.argv) < 2:
        print("Usage: python audio2txtenja.py <audiofile>")
        sys.exit(1)

    audio = sys.argv[1]
    if not os.path.exists(audio):
        print(f"Error: Audio file not found at '{audio}'")
        sys.exit(1)

    model = whisper.load_model("small")

    # 別スレッドで '.' 出力開始
    stop_event = threading.Event()
    t = threading.Thread(target=progress_dots, args=(stop_event,))
    t.start()

    # 時間のかかる処理
    #result = model.transcribe(audio, language="en", fp16=False)
    result = model.transcribe(audio, fp16=False)

    # transcribe が終わったら停止
    stop_event.set()
    t.join()

    print("Transcription done!\n")

    srt = os.path.splitext(audio)[0] + ".srt"

    async def tr(text):
        return (await translator.translate(text, dest="ja")).text

    async def add_text_ja(elem):
        text_ja = await tr(elem['text'])
        return elem | {'text_ja': text_ja}

    async def process_segments():
        tasks = [add_text_ja(elm) for elm in result["segments"]]
        return await asyncio.gather(*tasks)

    with open(srt, "w", encoding="utf-8") as f:
        segments = asyncio.run(process_segments())
        for i, seg in enumerate(segments, 1):
            t1, t2 = fmt_time(seg["start"]), fmt_time(seg["end"])
            orig = seg["text"].lstrip()
            trans = seg['text_ja']
            block = f"{i}\n{t1} --> {t2}\n{orig}\n{trans}\n\n"
            f.write(block)
            print(block, end="")

if __name__ == "__main__":
    main()
