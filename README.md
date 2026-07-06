# sas-transcription

Transcription et compte-rendu de réunion **100 % locaux, accélérés sur GPU**, sans aucun envoi vers le cloud. Un actif du Comptoir des Signaux : outil du quotidien pour les besoins de stricte confidentialité, et support de démonstration en formation auprès des collectivités territoriales.

## Ce que c'est

Un empaquetage reproductible de **Meetily** (application de meeting minutes de Zackriya-Solutions, licence MIT), configuré et outillé pour :

- utiliser **Whisper large-v3** comme moteur de transcription par défaut, **sur GPU** (whisper.cpp CUDA) ;
- résumer en local via un LLM embarqué (llama.cpp CUDA, modèle qwen) ;
- tourner nativement dans **WSL2** (poste Windows) comme sur **Kubuntu**, durable au redémarrage, lançable depuis un raccourci bureau.

Ce dépôt n'est pas une application écrite par le Comptoir des Signaux. La valeur apportée est la **maîtrise de la chaîne souveraine** : compilation depuis les sources, accélération GPU, configuration par défaut, vérification de la souveraineté. L'application elle-même est Meetily (voir Attribution).

## Souveraineté

- Transcription (whisper.cpp) et résumé (llama.cpp) s'exécutent **entièrement sur l'appareil**.
- Le réseau n'est requis qu'une seule fois, pour **télécharger les modèles**. Ensuite, tout fonctionne hors ligne : coupe le réseau et transcris, rien ne remonte au cloud.
- Aucune donnée, aucun audio, aucun transcript ne quitte la machine.

C'est la thèse du Comptoir des Signaux sur la souveraineté à deux étages : souveraineté de la technologie (outils ouverts et locaux) et souveraineté des compétences (savoir les déployer et les auditer soi-même).

## Preuve de performance

Bench mesuré sur RTX 5090 (extrait public de conseil municipal, voir `bench/`) :

- Whisper large-v3 **sur GPU : environ 9 fois plus rapide que sur CPU**, 7 fois le temps réel.
- Français propre (accents, ponctuation, vocabulaire métier), nettement supérieur au moteur Parakeet par défaut de Meetily.

## Démarrage

Voir **`TUTORIEL.md`** pour le pas-à-pas complet (WSL2 et Kubuntu), et **`DEMO_FORMATION.md`** pour la mise en scène en séance.

## Attribution

- Application : **Meetily** (Zackriya-Solutions / meeting-minutes), licence MIT. https://github.com/Zackriya-Solutions/meeting-minutes
- Modèle de transcription : Whisper (OpenAI), format ggml via whisper.cpp.
- Ce dépôt : scripts d'installation, configuration par défaut, documentation et matériel de démonstration du Comptoir des Signaux.
