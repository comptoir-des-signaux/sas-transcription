import sys, time, ctranslate2
from faster_whisper import WhisperModel

audio = sys.argv[1]
device = sys.argv[2] if len(sys.argv) > 2 else "cuda"
compute = sys.argv[3] if len(sys.argv) > 3 else ("float16" if device == "cuda" else "int8")

print(f"[info] ctranslate2 CUDA devices: {ctranslate2.get_cuda_device_count()}", flush=True)
print(f"[info] device={device} compute_type={compute} audio={audio}", flush=True)

t0 = time.time()
model = WhisperModel("large-v3", device=device, compute_type=compute)
t_load = time.time() - t0
print(f"[timing] model load: {t_load:.1f}s", flush=True)

t1 = time.time()
segments, info = model.transcribe(audio, language="fr", beam_size=5)
segs = list(segments)
t_trans = time.time() - t1

audio_dur = info.duration
text = " ".join(s.text.strip() for s in segs)
print(f"[timing] transcription: {t_trans:.1f}s for {audio_dur:.1f}s audio  => RTF={t_trans/audio_dur:.3f}  speed={audio_dur/t_trans:.1f}x realtime", flush=True)
print(f"[info] language={info.language} prob={info.language_probability:.2f} segments={len(segs)}", flush=True)
out = f"/out/transcription_{device}_{compute}.txt"
with open(out, "w") as f:
    f.write(text)
print(f"[info] saved {out} ({len(text)} chars)", flush=True)
print("\n===== PREMIERS 1200 CARACTERES =====\n" + text[:1200], flush=True)
