#!/usr/bin/env bash
# scripts/lib/common.sh - helpers partagés sas-transcription (WSL2 + Kubuntu)
set -euo pipefail

export MEETILY_IDENTIFIER="com.meetily.ai"
export MEETILY_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/${MEETILY_IDENTIFIER}"

log() { printf '\033[1;36m[sas-transcription]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[sas-transcription] ERREUR:\033[0m %s\n' "$*" >&2; exit 1; }

detect_platform() {
  if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then echo "wsl2"; else echo "native"; fi
}

# Base applicative Meetily (verifie sur v0.4.0 : meeting_minutes.sqlite, mode WAL).
# On cible ce nom precis pour ignorer le leurre hsts-storage.sqlite.
resolve_db() {
  local db="$MEETILY_DATA_DIR/meeting_minutes.sqlite"
  [ -f "$db" ] && echo "$db"
}

# Dossier modeles : whisper_engine::set_models_directory = app_data_dir/models.
# Les ggml-*.bin sont cherches directement la (parakeet est dans models/parakeet).
resolve_models_dir() {
  local d="$MEETILY_DATA_DIR/models"
  mkdir -p "$d"
  echo "$d"
}
