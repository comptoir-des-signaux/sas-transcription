# Lancement sur Kubuntu natif

Sur Kubuntu (ou toute distribution KDE/GNOME native), aucune couche `wsl.exe` n'est nécessaire.

- Le paquet `.deb` installé à l'étape 2 dépose `usr/share/applications/meetily.desktop` et l'icône. **L'application apparaît donc directement dans le menu de KDE Plasma** (ou GNOME) : cherche « meetily » et épingle-la si tu veux.
- `scripts/meetily-launch.sh` reste le point d'entrée durable : il détecte le natif (pas de réglage WSLg à forcer) et exécute simplement l'application. Utile si tu veux poser un lanceur personnalisé.
- Le runtime CUDA s'installe via `scripts/01_install_cuda_runtime.sh`, qui bascule automatiquement sur le dépôt NVIDIA `ubuntu2404` en natif. Le pilote NVIDIA doit être installé nativement (contrairement à WSL2 où il vient de Windows).

En clair : sur Kubuntu, les étapes 1 à 4 du `TUTORIEL.md` sont identiques ; l'étape 5 (raccourci Windows) est remplacée par l'entrée de menu native, déjà posée par le `.deb`.
