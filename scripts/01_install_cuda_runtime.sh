#!/usr/bin/env bash
# sas-transcription - Task 2 : runtime CUDA pour Meetily (WSL2 ou Kubuntu natif).
# Le .deb Meetily a ete compile contre CUDA 12 ; les sonames sont en majeur seul
# (libcudart.so.12), donc n'importe quelle 12.x convient. Le driver (libcuda.so.1)
# vient de Windows via /usr/lib/wsl/lib en WSL2, ou du paquet driver NVIDIA en natif.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/common.sh"
PLATFORM="$(detect_platform)"
log "Plateforme detectee : $PLATFORM"

# 1. Sanity GPU
command -v nvidia-smi >/dev/null || die "nvidia-smi absent : pilote NVIDIA (Windows en WSL2, ou natif) non expose."
nvidia-smi --query-gpu=name --format=csv,noheader || die "nvidia-smi echoue : GPU non accessible."

# 2. Depot CUDA NVIDIA
if [ "$PLATFORM" = "wsl2" ]; then REPO="wsl-ubuntu"; else REPO="ubuntu2404"; fi
if ! ls /etc/apt/sources.list.d/ 2>/dev/null | grep -qi cuda; then
  log "Ajout du depot CUDA ($REPO)"
  wget -qO /tmp/cuda-keyring.deb "https://developer.download.nvidia.com/compute/cuda/repos/${REPO}/x86_64/cuda-keyring_1.1-1_all.deb"
  sudo dpkg -i /tmp/cuda-keyring.deb
  sudo apt-get update -qq
fi

# 3. Runtime minimal : cudart + cublas (n'importe quelle 12.x) pour la transcription (whisper.cpp)
log "Installation runtime CUDA (cudart + cublas)"
sudo apt-get install -y cuda-cudart-12-6 libcublas-12-6 \
  || sudo apt-get install -y \
       "$(apt-cache pkgnames cuda-cudart-12 | sort | tail -1)" \
       "$(apt-cache pkgnames libcublas-12   | sort | tail -1)"

# 3b. Dependances du sidecar de resume (llama-helper) : OpenMP (libgomp) + NCCL.
# Sans elles, llama-helper crashe au spawn (« error while loading shared libraries:
# libgomp.so.1 ») et le resume echoue avec « Failed to write request to stdin ».
log "Installation des dependances du moteur de resume (libgomp1, libnccl2)"
sudo apt-get install -y libgomp1 libnccl2 \
  || sudo apt-get install -y libgomp1 "$(apt-cache pkgnames libnccl2 | sort | tail -1)"

# 4. Rendre les libs trouvables
CUDA_LIB=$(dirname "$(find /usr/local/cuda-12* /usr/lib/x86_64-linux-gnu -name 'libcudart.so.12' 2>/dev/null | head -1)")
[ -n "$CUDA_LIB" ] || die "libcudart.so.12 introuvable apres installation."
echo "$CUDA_LIB" | sudo tee /etc/ld.so.conf.d/cuda-sas-transcription.conf >/dev/null
sudo ldconfig
log "Runtime CUDA pret dans $CUDA_LIB"
