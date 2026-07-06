#!/usr/bin/env bash
# sas-transcription - lanceur durable : environnement GPU + exec Meetily.
# Point d'entree unique, reference par le raccourci Windows (WSL2) et utilisable
# tel quel en Kubuntu natif.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/common.sh"

# WSLg fournit l'affichage ; en natif, DISPLAY est deja pose par la session.
if [ "$(detect_platform)" = "wsl2" ]; then
  export DISPLAY="${DISPLAY:-:0}"
  export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
  export LIBGL_ALWAYS_INDIRECT="${LIBGL_ALWAYS_INDIRECT:-0}"
fi
# Le driver WSL et le runtime CUDA (Task 2) sont sur le chemin via ldconfig ;
# on ajoute le path WSL au cas ou.
export LD_LIBRARY_PATH="/usr/lib/wsl/lib:${LD_LIBRARY_PATH:-}"

log "Lancement de Meetily (data dir : $MEETILY_DATA_DIR)"
exec meetily "$@"
