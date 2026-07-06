# Tutoriel : installer sas-transcription (Meetily souverain, GPU)

De zéro à un raccourci bureau qui lance une transcription Whisper large-v3 sur GPU, 100 % locale. Testé sur Windows 11 + WSL2 (Ubuntu) + RTX 5090. La section Kubuntu liste les seules différences.

## Prérequis

- Un GPU NVIDIA et son pilote (sur Windows, le pilote suffit : il est exposé à WSL2 ; sur Kubuntu, le pilote NVIDIA installé nativement).
- **WSL2 avec une distro Ubuntu** (`wsl -l -v` doit montrer `Ubuntu ... 2`), ou **Kubuntu >= 24.04** en natif.
- Le paquet `.deb` CUDA de Meetily, compilé depuis les sources (voir « Obtenir le .deb » plus bas). Place-le dans `artefacts/` du dépôt, ou passe son chemin via la variable `SAS_DEB`. Ce dépôt ne redistribue pas le binaire.
- Environ 7 Go d'espace : binaires (1,2 Go) + modèle large-v3 (2,95 Go) + modèle de résumé (2,6 Go).

## Convention de chemin

Dans ce tutoriel, `/mnt/d/CascadeProjects/sas-transcription` désigne le dossier où **tu** as cloné le dépôt. Remplace-le par ton propre chemin (par exemple `~/sas-transcription`). Le script de raccourci Windows, lui, détecte automatiquement son emplacement, tu n'as rien à adapter.

## Vue d'ensemble

Cinq scripts, dans l'ordre. Les deux premiers demandent `sudo` (à lancer dans un vrai terminal, pas via un outil sans TTY). Les autres n'en demandent pas.

```
scripts/01_install_cuda_runtime.sh   (sudo)  runtime CUDA dans WSL2
scripts/02_install_meetily.sh        (sudo)  installe le .deb
      premier lancement de l'appli            crée la base + télécharge les moteurs
scripts/03_provision_defaults.sh             Whisper large-v3 par défaut
scripts/windows/install-shortcut.ps1 (Windows) raccourci bureau
```

## Obtenir le .deb

Ce dépôt ne redistribue pas le binaire compilé de Meetily (application tierce, MIT). Deux voies :

- **Compiler depuis les sources** : cloner `github.com/Zackriya-Solutions/meeting-minutes` (v0.4.0) et bâtir le paquet avec accélération CUDA. C'est la voie souveraine : tu maîtrises ce que tu exécutes.
- **Récupérer un build existant** : si tu disposes déjà d'un `.deb` CUDA (build interne), place-le dans `artefacts/` du dépôt.

Une fois le `.deb` en place dans `artefacts/` (ou pointé par `SAS_DEB`), continue.

## Étape 1 : runtime CUDA

Dans un terminal Ubuntu (WSL) :

```bash
bash /mnt/d/CascadeProjects/sas-transcription/scripts/01_install_cuda_runtime.sh
```

Il ajoute le dépôt CUDA NVIDIA (`wsl-ubuntu`), installe `cuda-cudart-12` et `libcublas-12`, et les rend visibles par `ldconfig`. Doit finir par `Runtime CUDA pret dans /usr/local/cuda-12.x/...`.

Vérification :

```bash
nvidia-smi --query-gpu=name --format=csv,noheader
ldconfig -p | grep -E 'libcudart\.so\.12|libcublas\.so\.12'
```

## Étape 2 : installer Meetily

```bash
bash /mnt/d/CascadeProjects/sas-transcription/scripts/02_install_meetily.sh
```

Installe `/usr/bin/meetily`, `/usr/bin/llama-helper`, `ffmpeg`, l'entrée de bureau et l'icône. Doit finir par `meetily installe : /usr/bin/meetily`.

Vérification que le binaire trouve bien CUDA :

```bash
ldd /usr/bin/meetily | grep -iE 'cudart|cublas|libcuda'
```

Les trois doivent être résolues (les libs CUDA via `/usr/local/cuda`, le driver `libcuda.so.1` via `/usr/lib/wsl/lib`).

## Étape 3 : premier lancement (crée la base)

```bash
bash /mnt/d/CascadeProjects/sas-transcription/scripts/meetily-launch.sh
```

La fenêtre s'ouvre via WSLg. **Passe l'onboarding** (il télécharge un moteur de transcription et le moteur de résumé). Cela crée la base `~/.local/share/com.meetily.ai/meeting_minutes.sqlite` dont l'étape suivante a besoin.

Piège utile : fermer la fenêtre **ne quitte pas** l'application (elle reste dans la zone de notification). Avant l'étape 4, **quitte-la vraiment** (clic droit sur l'icône de notification puis Quitter, ou `pkill -9 -x meetily` dans le terminal). La base est en mode WAL : on n'y écrit pas pendant que l'appli tourne.

## Étape 4 : Whisper large-v3 par défaut

Application fermée :

```bash
bash /mnt/d/CascadeProjects/sas-transcription/scripts/03_provision_defaults.sh
```

Il télécharge `ggml-large-v3.bin` (2,95 Go) dans `~/.local/share/com.meetily.ai/models/`, puis écrit dans la base : `transcript_settings.provider = localWhisper`, `model = large-v3`. Doit finir par `Defaut pose : provider=localWhisper, model=large-v3`.

Vérification :

```bash
python3 - <<'PY'
import sqlite3, os
db=os.path.expanduser("~/.local/share/com.meetily.ai/meeting_minutes.sqlite")
print(sqlite3.connect(db).execute("SELECT provider,model FROM transcript_settings WHERE id='1'").fetchone())
PY
```

Doit renvoyer `('localWhisper', 'large-v3')`.

## Étape 5 : raccourci bureau Windows

Côté Windows (PowerShell) :

```powershell
powershell -ExecutionPolicy Bypass -File "D:\CascadeProjects\sas-transcription\scripts\windows\install-shortcut.ps1"
```

Crée « Meetily (souverain) » sur le Bureau et dans le menu Démarrer. Le script résout le vrai dossier Bureau via l'API Windows : il gère la redirection OneDrive et le nom localisé « Bureau ». Double-clique le raccourci : l'appli s'ouvre.

## Vérifier que le GPU travaille

Lance l'appli, importe un fichier audio, transcris. Dans les logs (lance depuis un terminal pour les voir), tu dois trouver :

```
ggml_cuda_init: found 1 CUDA devices: Device 0: NVIDIA GeForce RTX 5090 ...
whisper_model_load: type = 5 (large v3)
Successfully loaded model: large-v3 with CUDA GPU with Flash Attention
whisper_backend_init_gpu: using CUDA backend
```

## Carte d'auto-vérification après un redémarrage

Tout vit sur le disque persistant de WSL2 : un `wsl --shutdown` ou un reboot n'efface rien. Après un redémarrage, pour confirmer en trois gestes :

1. Double-clique « Meetily (souverain) » : la fenêtre s'ouvre.
2. Importe un court extrait audio et transcris : le texte français apparaît.
3. (Optionnel) lance depuis un terminal et vérifie la ligne `using CUDA backend` dans les logs.

Si les trois passent, la persistance est confirmée.

## Fonctionnement hors ligne (souveraineté)

Une fois les modèles téléchargés, coupe le Wi-Fi ou l'Ethernet, lance l'appli et transcris : cela fonctionne sans réseau. Rien ne remonte au cloud.

## Kubuntu natif : les seules différences

Le cœur (étapes 1 à 4) est identique. Différences :

- **Étape 1** : le script détecte le natif et utilise le dépôt CUDA `ubuntu2404` au lieu de `wsl-ubuntu`. Assure-toi d'avoir le pilote NVIDIA installé nativement.
- **Étape 5** : pas de raccourci `wsl.exe`. Le `.deb` a installé `meetily.desktop` : l'application apparaît directement dans le menu de KDE Plasma. `scripts/meetily-launch.sh` reste utilisable comme point d'entrée. Voir `scripts/linux-native/README.md`.
- **Compatibilité** : le `.deb` est bâti sur Ubuntu 24.04 (glibc 2.39). Sur Kubuntu >= 24.04 il s'installe directement ; sinon, reconstruire depuis les sources.
