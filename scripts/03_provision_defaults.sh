#!/usr/bin/env bash
# sas-transcription - Task 5 : Whisper large-v3 par defaut.
# 1) telecharge ggml-large-v3.bin dans le dossier modeles de Meetily
# 2) ecrit le reglage par defaut dans la base SQLite (provider=localWhisper, model=large-v3)
# N'exige aucun sudo (python3 + wget). L'appli DOIT etre fermee (base en mode WAL).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/common.sh"

# 0. Securite : l'appli ne doit pas tourner pendant l'ecriture de la base.
if pgrep -x meetily >/dev/null 2>&1; then
  die "Meetily est ouvert. Ferme la fenetre puis relance ce script (ecriture base en mode WAL)."
fi

# 1. Modele large-v3
MODELS_DIR="$(resolve_models_dir)"
MODEL="$MODELS_DIR/ggml-large-v3.bin"
URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin"
if [ ! -s "$MODEL" ] || [ "$(stat -c%s "$MODEL")" -lt 3000000000 ]; then
  log "Telechargement de ggml-large-v3.bin (~2,95 Go) dans $MODELS_DIR"
  wget -O "$MODEL" "$URL"
else
  log "Modele deja present : $MODEL ($(du -h "$MODEL" | cut -f1))"
fi

# 2. Reglage par defaut en base (source de verite : SQLite)
DB="$(resolve_db)"
[ -n "$DB" ] || die "Base introuvable : lance Meetily une fois pour la creer, puis relance."
log "Ecriture du reglage par defaut dans $DB"
python3 - "$DB" <<'PY'
import sqlite3, sys
db = sys.argv[1]
con = sqlite3.connect(db)
cur = con.cursor()
# Moteur de transcription : Whisper local, modele large-v3
cur.execute("UPDATE transcript_settings SET provider='localWhisper', model='large-v3' WHERE id='1'")
if cur.rowcount == 0:
    cur.execute("INSERT INTO transcript_settings (id, provider, model) VALUES ('1','localWhisper','large-v3')")
# Coherence : le modele whisper choisi cote settings
try:
    cur.execute("UPDATE settings SET whisperModel='large-v3' WHERE id='1'")
except sqlite3.OperationalError:
    pass
con.commit()
row = cur.execute("SELECT provider, model FROM transcript_settings WHERE id='1'").fetchone()
print("transcript_settings =>", row)
con.close()
PY
log "Defaut pose : provider=localWhisper, model=large-v3"
