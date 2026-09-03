# selfsight

## Présentation
selfsight est une application Flutter conçue pour vous aider à visualiser vos objectifs, organiser vos tâches quotidiennes et suivre votre progression personnelle. Elle permet de mettre en place les actions concrètes à effectuer grâce à un tableau de vision interactif, un gestionnaire de tâches et des statistiques détaillées.

## Fonctionnalités principales
- **Vision Board** : Créez un tableau d'inspiration visuel en ajoutant des images et des textes pour matérialiser vos objectifs à long terme.
- **Gestion des tâches** : Décomposez vos visions en tâches claires et réalisables, et suivez leur état d'avancement.

## 🛠️ Stack technique & Architecture
- **Framework** : Flutter (SDK ≥3.0.0) avec Dart.
- **Architecture (Gestion d'état)** : 
  - L'application suit le pattern **MVVM** (Modèle-Vue-Modèle de Vue)
  - Utilisation de `get_it` comme conteneur de services (Service Locator) pour faciliter l'injection de dépendances.
  - `stacked_services` pour la gestion de la navigation

- **Stoackage locale (Persistance)** :
  - **SharedPreferences** : Utilisé en complément pour le stockage local des préférences utilisateur et du cache léger (ex : thème choisi, dernières données consultées).

- **Gestion d'environnement** : Les clés API et URLs sensibles vont être sécurisées et gérées via `flutter_dotenv`.

## 🧪 Tests
- **Tests unitaires** : Validation des modèles de données et des contrôleurs.
- **Tests d'intégration** : Simulation des parcours utilisateurs critiques (création d'une vision, ajout de tâches, mise à jour du statut).

## Aperçu de l'application
<img width="450" height="897" alt="1" src="https://github.com/user-attachments/assets/657bf4be-a30c-4fc0-911c-b61b4471111f" />
<img width="452" height="962" alt="2" src="https://github.com/user-attachments/assets/b4dcd4fb-2700-46ac-a70d-41c5fb1ec6aa" />
<img width="445" height="945" alt="3" src="https://github.com/user-attachments/assets/31fd40b6-f600-49e2-9152-5608288a82cf" />
<img width="457" height="1011" alt="4" src="https://github.com/user-attachments/assets/b3a6007e-c920-4fb4-a810-60c89c15a3ef" />
<img width="446" height="1001" alt="5" src="https://github.com/user-attachments/assets/b824c85c-6427-40e1-8884-6bae6f5c68cb" />
## 🚀 Pistes d'améliorations futures
- Synchronisation Cloud (Supabase)
- Notifications push pour les rappels quotidiens
- Simulation plus immersive de la création de tableau de données
- Statistiques du progrès de l'utilisateur
