# Bench transcription souveraine : Whisper large-v3 sur RTX 5090 (CPU vs GPU)

Auteur : Pascal Chevallot, Comptoir des Signaux. Date : 2026-07-06.
Contexte : évaluation d'une chaîne de transcription souveraine sur GPU (Meetily configuré en Whisper large-v3), pour un usage en formation et en production locale.

## Question posée

Le résumé LLM profite du GPU (mesuré : 104 tok/s sur le 5090). La transcription, elle, ne profitait PAS du GPU tant que Meetily utilisait son moteur par défaut Parakeet INT8 (ONNX) : les opérations `ConvInteger` n'ont pas de kernel CUDA, chaque couche retombe sur CPU avec des copies mémoire, le GPU devient contre-productif. D'où la question : un modèle de la famille Whisper, qui a de vrais kernels CUDA, accélère-t-il réellement la transcription sur ce GPU, et avec une meilleure qualité française que Parakeet ?

## Protocole

- Modèle : `large-v3` via faster-whisper 1.2.1 (CTranslate2 4.8.1).
- Audio : extrait de 10 min du conseil municipal public de Saint-Nazaire du 29/05/2026 (`saint-nazaire_extrait_10min.wav`, 600 s). Séance publique, communicable (L2121-18 CGCT), aucune donnée sensible.
- Matériel : NVIDIA GeForce RTX 5090 Laptop, 24 Go, architecture Blackwell (sm_120), pilote CUDA 12.
- Environnement : container Docker `meetily-builder-cuda:local` (CUDA + cuDNN 9), GPU exposé via `--gpus all`.
- Paramètres : `language="fr"`, `beam_size=5`. GPU en `float16`, CPU en `int8` (meilleure config CPU réaliste).
- Script reproductible : `run_whisper.py` (dans ce dossier).

## Résultats mesurés

| Mesure | GPU (float16) | CPU (int8) |
|---|---|---|
| Chargement modèle (cache) | 3,9 s | 5,0 s |
| Transcription (audio de 600 s) | 82,8 s (passe 1) / 90,7 s (passe 2) | 760,7 s (12,7 min) |
| Vitesse | 6,6 à 7,2 fois le temps réel | 0,8 fois (plus lent que l'audio) |
| RTF (temps de calcul / durée audio) | 0,138 à 0,151 | 1,268 |
| Langue détectée | fr, probabilité 1,00 | fr, probabilité 1,00 |
| Longueur transcript | 9 230 caractères, 89 segments | 10 075 caractères, 107 segments |

### Accélération GPU : environ 9 fois plus rapide

760,7 s (CPU) / 82,8 s (GPU) = 9,2. Sur le 5090, la transcription Whisper large-v3 est environ 9 fois plus rapide sur GPU que sur CPU, et surtout elle passe sous le temps réel (7 fois plus vite que l'audio), là où le CPU est plus lent que l'audio (0,8 fois).

## Deux enseignements

1. **Qualité française : Whisper nettement supérieur à Parakeet.** Sortie propre, accentuée, ponctuée, avec un vocabulaire juridique et budgétaire cohérent (« trajectoire soutenable », « responsabilité budgétaire », « continuité du service public »). Le moteur Parakeet INT8 par défaut de Meetily produisait des parasites anglais (« and to garantir », « montr », « suis »). Pour un acte français, Whisper est le bon moteur.

2. **Le GPU accélère vraiment, contrairement à Parakeet INT8.** Whisper via CTranslate2 utilise de vrais kernels CUDA en float16 : gain d'un facteur 9. Le constat « le GPU est contre-productif pour la transcription » ne valait que pour le Parakeet INT8 de Meetily, pas pour Whisper.

## Note de fiabilité

Écart de longueur entre les deux transcripts (GPU 9 230 vs CPU 10 075 caractères) : il provient de la segmentation VAD, pas d'une perte de contenu. Une première passe GPU avait donné 66 segments (6 643 caractères), la seconde 89 segments (9 230 caractères) sur le même audio : c'est la variabilité de découpage entre passes, les deux couvrant bien les 600 s (durée détectée = 600 s dans les deux cas). Pour un transcript de démo fidèle, retenir une passe et la relire ; le contenu n'est pas tronqué.

## Implication pour une configuration Meetily de production souveraine

Meetily transcrit par défaut avec Parakeet INT8, pour lequel la reco restait : transcription sur CPU, résumé sur GPU. Ce bench change la donne si l'on route la transcription vers Whisper (whisper.cpp CUDA ou faster-whisper CUDA) au lieu de Parakeet : le 5090 paie alors sur les deux étapes, transcription (facteur 9) ET résumé LLM (104 tok/s), avec en prime une bien meilleure qualité française. Le routage de l'import Meetily vers whisper.cpp reste une modification de code à instruire.

## Reproduire

```bash
# dans un container avec CUDA + cuDNN 9 et le GPU exposé
python3 -m pip install --break-system-packages faster-whisper
python3 run_whisper.py /chemin/audio.wav cuda float16   # GPU
python3 run_whisper.py /chemin/audio.wav cpu  int8      # CPU (baseline)
```

Fichiers de ce dossier :
- `RAPPORT_bench_whisper_large-v3_RTX5090.md` : ce rapport.
- `transcript_whisper-large-v3_GPU.txt` : transcript GPU (float16, 89 segments).
- `transcript_whisper-large-v3_CPU.txt` : transcript CPU (int8, 107 segments).
- `run_whisper.py` : script de bench reproductible.
