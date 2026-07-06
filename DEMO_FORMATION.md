# Démo en formation : la transcription souveraine

Objectif pédagogique : montrer aux collectivités qu'un outil de transcription et de compte-rendu peut être **entièrement local, sans cloud, et performant**, donc utilisable même sur des matières sensibles. Illustre la souveraineté à deux étages : technologie ouverte et locale, plus compétence de déploiement.

## Matériel prêt

- L'application installée et configurée (voir `TUTORIEL.md`), Whisper large-v3 par défaut.
- Un extrait audio **public et communicable** pour la démo (par exemple une séance de conseil municipal, communicable au titre de L2121-18 CGCT). Un clip de 60 s est fourni : `demo/fixtures/saint-nazaire_60s.wav`.
- Le bench chiffré sous la main : `bench/RAPPORT_bench_whisper_large-v3_RTX5090.md`.

## Déroulé (environ 8 minutes)

1. **Poser le problème** (1 min) : le procès-verbal chronophage. Rappeler que la matière d'une réunion peut être sensible, donc qu'un outil cloud n'est pas toujours acceptable.
2. **Lancer depuis le raccourci** (30 s) : montrer que c'est une application comme une autre, un double-clic. Pas de site web, pas de compte.
3. **Importer l'extrait et transcrire** (2 min) : montrer le texte français qui se construit, propre et accentué.
4. **La preuve de souveraineté** (2 min) : couper le Wi-Fi devant la salle, relancer une transcription. Cela fonctionne toujours. Insister : aucune donnée n'est jamais sortie de la machine.
5. **La performance** (1 min) : montrer le bench. Whisper large-v3 sur GPU, environ 9 fois plus rapide que le CPU, 7 fois le temps réel. Le local n'est pas synonyme de lent.
6. **Le compte-rendu** (1 min) : générer le résumé (LLM local) pour montrer la chaîne complète, transcription puis synthèse, sans cloud.
7. **Conclure** (30 s) : ce n'est pas magique, c'est reproductible. C'est la compétence qui compte, et elle se transmet.

## Points de vigilance

- N'utiliser que des matières publiques ou anonymisées pour une démo. Ne jamais projeter de contenu confidentiel réel.
- Attribution honnête : préciser que l'application est Meetily (open source, MIT), que la valeur montrée est la maîtrise de la chaîne, pas l'écriture du logiciel.
- Ne pas promettre que tout métier gagne du temps sans travail : le compte-rendu reste une décision humaine sur ce qu'il faut retenir.
