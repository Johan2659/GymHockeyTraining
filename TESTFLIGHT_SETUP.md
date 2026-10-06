# HockeyForge → TestFlight, sans Mac

Le workflow `.github/workflows/flutter.yml` reprend le pipeline de Speaking Reflexes : GitHub Actions macOS, outils CLI Codemagic 0.69.0, récupération automatique du certificat/profil, IPA signé puis App Store Connect. Aucun abonnement Codemagic nécessaire.

## À faire une seule fois

1. **Créer l'identifiant Apple.** [Apple Developer → Identifiers](https://developer.apple.com/account/resources/identifiers/list) → `+` → App IDs → App → description `HockeyForge` → Explicit Bundle ID `com.johantoso.hockeyforgebase` → Register. Conserver exactement cet identifiant pour les futures mises à jour. Ne pas activer de capabilities inutiles.

2. **Créer la fiche de l'app.** [App Store Connect → Apps](https://appstoreconnect.apple.com/apps) → `+` → New App : iOS, nom `HockeyForge` (si disponible), langue English, Bundle ID ci-dessus, SKU `HOCKEYFORGE-IOS-001`. Le SKU est ton identifiant interne. Accepter tout accord Apple en attente.

3. **Récupérer tes identifiants CI.** Réutiliser les fichiers et valeurs d'origine de Speaking Reflexes : Issuer ID, Key ID, contenu complet du `.p8`, clé privée du certificat de distribution. GitHub ne permet pas de relire les valeurs déjà enregistrées dans ses secrets. Utiliser tes sauvegardes, pas les noms de fichiers. Si le `.p8` est perdu, créer une nouvelle Team API Key dans [Users and Access → Integrations](https://appstoreconnect.apple.com/access/integrations/api). Le téléchargement est unique. Pour reprendre la création automatique des certificats/profils, utiliser une clé autorisée à ces opérations (Admin pour ce pipeline).

4. **Ajouter les secrets au bon repo.** [GymHockeyTraining → Actions secrets](https://github.com/Johan2659/GymHockeyTraining/settings/secrets/actions) → New repository secret, quatre fois :

| Nom exact | Valeur |
|---|---|
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID Apple |
| `APP_STORE_CONNECT_KEY_ID` | Key ID de la clé API |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Tout le contenu du `.p8`, BEGIN/END inclus |
| `IOS_CERTIFICATE_PRIVATE_KEY` | Clé privée correspondant au certificat Apple Distribution, BEGIN/END inclus |

Un fichier `.cer` n'est pas la clé privée ; une clé API `.p8` n'est pas la clé privée du certificat. Le certificat de distribution peut servir à plusieurs apps de la même équipe. Le profil de provisioning est propre à l'app et sera récupéré/créé par le pipeline. Ne rien coller dans le code, les issues ou le chat.

5. **Activer l'envoi.** [GitHub → Actions variables](https://github.com/Johan2659/GymHockeyTraining/settings/variables/actions) → New repository variable → nom `TESTFLIGHT_ENABLED`, valeur `true`.

6. **Lancer le premier envoi.** [Actions](https://github.com/Johan2659/GymHockeyTraining/actions) → dernière exécution `HockeyForge CI + TestFlight` → Re-run all jobs, ou faire un nouveau commit sur `hockeyforge-base`. Le workflow doit contenir les jobs `foundation`, `ios-simulator` et `release`. Si `release` est skipped, vérifier la variable, la branche et les jobs de validation. Le bouton Run workflow peut ne pas apparaître tant que le workflow n'est pas présent sur la branche par défaut ; commit ou relance fonctionnent depuis le navigateur.

7. **Installer sur iPhone.** [App Store Connect](https://appstoreconnect.apple.com/apps) → HockeyForge → TestFlight. Attendre le traitement du build ; compléter les questions de chiffrement selon le code réel (Hive chiffré est utilisé, ne pas répondre automatiquement « aucun chiffrement »). Créer un groupe Internal Testing, ajouter ton utilisateur App Store Connect et le build, activer Automatic Distribution si proposé. Installer [TestFlight](https://apps.apple.com/app/testflight/id899247664), ouvrir l'invitation et installer l'app. Pour des amis sans accès App Store Connect : External Testing, informations de test et éventuelle Beta App Review.

## Ensuite, même depuis le mobile

- Modifier un fichier sur [la branche hockeyforge-base](https://github.com/Johan2659/GymHockeyTraining/tree/hockeyforge-base), puis Commit changes sur cette branche.
- GitHub lance automatiquement tests → build signé → upload. Pas de Mac, de certificat manuel ou d'IPA à envoyer à chaque fois.
- Après traitement/distribution Apple : ouvrir TestFlight → Update, ou activer les mises à jour automatiques.
- Le numéro de build augmente automatiquement, y compris lors des relances. Modifier `pubspec.yaml` quand tu souhaites changer la version visible.
- Aucun envoi vers TestFlight depuis les pull requests. Aucune publication App Store automatique.

## Plusieurs apps

- Une app = un repo, un Bundle ID et une fiche App Store Connect. Utiliser le même compte GitHub et la même équipe Apple Developer.
- Chaque repo possède les quatre secrets aux mêmes noms. Les secrets de `flutter_projects` ne sont pas automatiquement disponibles dans GymHockeyTraining.
- Sauvegarder les clés d'origine dans un coffre de mots de passe. Réutiliser le certificat/la clé de distribution de l'équipe lorsque possible.
- Une Team API Key peut servir à plusieurs apps. Une clé dédiée par pipeline permet une révocation indépendante, mais une Team Key ne limite pas les permissions à une seule app.
- Ne pas révoquer les clés de Speaking Reflexes lors de la configuration de HockeyForge.

## Validation

La CI précédente a réussi : 27 tests, analyse du code et build iOS simulateur. Le nouveau workflow a été contrôlé pour la syntaxe YAML et shell. L'IPA signé et l'upload ne peuvent être confirmés qu'après configuration des identifiants Apple, des secrets et de la variable d'activation.
