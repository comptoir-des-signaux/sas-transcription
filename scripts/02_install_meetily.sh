#!/usr/bin/env bash
# sas-transcription - Task 3 : installe le paquet Meetily CUDA (.deb durable).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/common.sh"

# Par defaut on cherche le paquet dans artefacts/ (non versionne). Surcharger via SAS_DEB.
# Ce depot ne redistribue pas le binaire : voir la section "Obtenir le .deb" du TUTORIEL.
DEB="${SAS_DEB:-$DIR/../artefacts/meetily_0.4.0_amd64_CUDA.deb}"
[ -f "$DEB" ] || die "Paquet .deb introuvable : $DEB
  -> place le .deb dans artefacts/ ou passe SAS_DEB=<chemin>.
  -> pour l'obtenir : compile Meetily depuis les sources (voir TUTORIEL, section 'Obtenir le .deb')."

log "Installation du paquet meetily depuis $DEB"
sudo apt-get install -y "$DEB" || { sudo dpkg -i "$DEB"; sudo apt-get -f install -y; }

command -v meetily >/dev/null || die "/usr/bin/meetily absent apres installation."
log "meetily installe : $(command -v meetily)"
