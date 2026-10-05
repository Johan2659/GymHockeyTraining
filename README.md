# HockeyForge Base

Projet Flutter dérivé de GymHockeyTraining, avec la direction visuelle de HockeyForge et une séance express adaptée de hockey_gym. Les dépôts d'origine n'ont pas été modifiés.

## Démarrer

Ouvrir ce dossier dans VS Code. Installer Flutter **3.35.7**, puis :

```sh
flutter pub get
flutter run
```

Sur macOS : Xcode et CocoaPods sont nécessaires pour iOS. Ouvrir `ios/Runner.xcworkspace`, choisir l'équipe Apple et confirmer l'identifiant `com.johantoso.hockeyforgebase` avant de signer une application sur appareil.

Le nom Dart `gymhockeytraining` est conservé pour les imports et le code généré. Le nom visible devient HockeyForge. Android est conservé mais son identité et sa publication restent à préparer.

## Ce qui a été intégré

- Moteur Flutter/Riverpod/GoRouter et repositories de GymHockeyTraining.
- Accueil HockeyForge : thème Dark Ice Arena, cartes plates, appel principal à l'action, accès aux séances express et statistiques issues des providers existants.
- Démarrage direct du prochain entraînement et reprise prioritaire d'une séance sauvegardée.
- Palette réelle de HockeyForge dans `lib/core/theme/app_colors.dart`, adaptée au thème historique sans casser ses références.
- Programmes, lecteur de séance, timer de récupération, performances, historique, extras et profils locaux conservés.
- Séances express existantes de 15–20 minutes et nouvelle Strength Stack de 30 minutes avec IDs d'exercices compatibles. Les durées sont des estimations.
- Recherche YouTube déjà présente dans le moteur, conservée.
- Structure native iOS, Podfile, iOS 13 minimum, identifiant propre au nouveau projet.
- CI fournie : analyse du code applicatif, tests ciblés et compilation iOS simulateur sur macOS.

## Ce qui reste à construire

| Fonction | État réel |
|---|---|
| Onboarding position/objectif | Hérité ; âge, niveau, équipement et disponibilités restent à ajouter |
| Alternatives gym/home | Données héritées ; parcours de substitution à vérifier et compléter |
| Alternatives selon douleurs/contraintes | À développer ; aucune personnalisation médicale implémentée |
| Streak/progression | Calculs hérités ; audit des règles et du stockage nécessaire |
| Challenges | Extras hérités ; système mensuel non implémenté |
| Builder premium | À développer |
| RevenueCat, achats, cloud sync | Non intégrés |
| Skater/Goalie | Programmes hérités ; adaptation produit à approfondir |
| Design complet | Nouvel accueil et palette intégrés ; autres écrans à harmoniser |

L'authentification héritée sélectionne des **profils locaux par nom d'utilisateur**. Elle ne constitue pas une authentification serveur et ne fournit pas de synchronisation entre appareils. Le stockage utilise Hive avec une clé sécurisée, mais des mécanismes de fallback existent : ne pas promettre un chiffrement intégral sans audit.

## Vérification

Effectué le 5 octobre 2026 : parsing Dart des 122 fichiers applicatifs et des deux nouveaux fichiers de tests ; validation des imports locaux, des property lists iOS et des références d'exercices des quatre séances express.

Les tests Flutter, l'analyse avec résolution des packages et la compilation n'ont **pas** été exécutés jusqu'au bout : l'initialisation du SDK a été bloquée par la validation automatique pour une connexion vers un endpoint de métadonnées cloud. Les workflows sont fournis mais n'ont pas été déclenchés sur GitHub. Aucun build iOS réussi n'est revendiqué.

```sh
flutter analyze lib --no-fatal-infos --no-fatal-warnings
flutter test test/forge_home_test.dart test/forge_catalog_test.dart test/unit/models_test.dart
flutter build ios --simulator --debug
```

Les tests historiques sont conservés. La CI cible les nouveaux parcours et la sérialisation ; elle ne certifie pas toute la suite héritée. Avant publication, exécuter aussi `flutter test`, corriger les anciens tests et vérifier le démarrage à froid, la persistance, les interruptions du timer, les changements de profil et la suppression de données sur un appareil réel.

## Priorité iOS

1. Faire passer les builds et tests sur macOS, puis tester une séance entière sur iPhone.
2. Harmoniser les autres écrans, compléter l'onboarding et les substitutions.
3. Auditer le stockage et la gestion du timer lorsque l'app passe en arrière-plan.
4. Préparer les vrais assets, politique de confidentialité, déclarations App Store et signature Apple.
5. Ajouter et tester les achats premium seulement après stabilisation du parcours gratuit.

Ce livrable est une **base de développement**, pas une version certifiée prête à publier sur l'App Store.

## Provenance

- GymHockeyTraining : https://github.com/Johan2659/GymHockeyTraining — commit `82d6eb325e17bc0a505fab8b9975e2f0fc508360`.
- HockeyForge : https://github.com/Johan2659/hockeyforge — palette et spécification consultées via le dépôt connecté.
- hockey_gym : https://github.com/Johan2659/hockey_gym — `assets/data/express_workouts.json` sur `master`, concept Strength Stack adapté au catalogue du moteur.

Les documents historiques déclarant le projet « production ready » n'ont pas été repris comme garanties.
