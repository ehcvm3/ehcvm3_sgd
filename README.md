## Objectif 🎯

Ce projet cherche à gérer les données de l'enquête NSU en :

1. **Obtenir les données.** Ceci consiste du :
  - Téléchargement des données.
  - Fusionnement de différentes bases.
2. **Valider les données.**
3. **Créer des rapports de suivi.**

## Installation 🔌

### Les pré-requis

- R
- RTools, si l'on utilise Windows comme système d'exploitation
- RStudio

<details>

<summary>
Ouvrir pour voir plus de détails 👁️
</summary>

#### R

- Suivre ce [lien](https://cran.r-project.org/)
- Cliquer sur votre système d'exploitation
- Cliquer sur `base`
- Télécharger and installer (e.g.,
  [this](https://cran.r-project.org/bin/windows/base/R-4.4.2-win.exe)
  pour le compte de Windows)

#### RTools

Nécessaire pour le système d'exploitation Windows

- Suivre ce [lien](https://cran.r-project.org/)
- Cliquer sur `Windows`
- Cliquer sur `RTools`
- Télécharger
  (e.g.,[this](https://cran.r-project.org/bin/windows/Rtools/rtools44/files/rtools44-6335-6327.exe) pour une architecture
  64bit)
- Installer dans le lieu de défaut suggéré par le programme d'installation (e.g., `C:\rtools4'`)

Ce programme permet à R de compiler des scripts écrit en C++ et utilisé par certains packages pour être plus performant (e.g., `{dplyr}`).

#### RStudio

- Suivre ce [lien](https://posit.co/download/rstudio-desktop/)
- Cliquer sur le bouton `DOWNLOAD RSTUDIO`
- Sélectionner le bon fichier d'installation selon votre système d'exploitation
- Télécharger et installer (e.g.,
  [this](https://download1.rstudio.org/electron/windows/RStudio-2024.09.1-394.exe)
  pour le compte de Windows)

RStudio est sollicité pour deux raisons :

1. Il fournit une bonne interface pour utiliser R
2. Il est accompagné par [Quarto](https://quarto.org/), un programme dont nous nous serviront pour créer certains documents.

</details>

## Emploi 👩‍💻

### Paramétrage

Sur votre serveur SuSo, créer un compte API (procédure [ici](https://docs.mysurvey.solutions/headquarters/accounts/teams-and-roles-tab-creating-user-accounts/)) et lui donner accès à l'espace de travail qui héberge le questionnaire NSU (procédure [ici](https://docs.mysurvey.solutions/headquarters/accounts/adding-users-to-workspaces/)).

Avant de lancer le programme, fournir les détails de connexion dans `_details_serveur.R`. Ces informations permettront ces programme d'interagir avec le serveur pour votre compte à travers l'utilisateur API.

### Utilisation régulière

### Ouvrir

Ouvrir le projet en tant que tel. En particulier, double-cliquer sur `ehcvm3_sgd.Rproj`. Ceci aura l'effet de l'ouvrir dans RStudio et d'enclencher l'activation de l'environment du projet (e.g., installer les packages requis au niveau du projet). (Pour en savoir plus, lire [ici](https://rstats.wtf/projects#rstudio-projects) et [ici](https://support.posit.co/hc/en-us/articles/200526207-Using-RStudio-Projects).)

### Lancer

Pour chaque action, exécuter le programme afférant :

- **`01_obtenir_01_donnees.R`**. Télécharger et décomprimer les données brutes des enquêtes ménage et communautaire. Résultats dans : `01_obtenir/donnees`.
- **`02_valider_donnees.R`** Valider les données de l'enquête ménage et créer des recommendations d'action (e.g., à rejeter, à passer en revue, etc.). Résultats dans : `02_valider/sortie`. Dans `01_cas/`, on retrouve les entretiens à valider d'après les paramètres de validation (e.g. statut SuSo, problèmes à rejeter, etc). Dans `02_recommandations`, on retrouve les recommendations d'action sous format Stata et Excel.

### Dépanner

En cas de problème :

- Lire les messages d'erreur. Parfois, ils indiquent le problème et quelques pistes de solution.
- Lire les problèmes fréquemment rencontrés ici-bas.
- Contacter l'équipe de développement, en fournissant les étapes suivies et les messages d'erreur (e.g. captures d'écran)

Voici quelques problèmes fréquemments rencontrés :

- Serveur n'existe pas à l'adresse fourie
- Impossible d'installer les packages
- `curl::curl_fetch_memory()` 

#### Serveur n'existe pas à l'adresse fourie

- **Problème** L'adresse fournie ne permet pas au programme de se connecter au site.
- **Solution.** Vérifier l'adresse et/ ou la connexion. Par exemple:
  - Voir si cette adresse amène au serveur lorsque mise dans un navigateur web
  - Voir si le serveur est en ligne / joignable
  - Confirmer que des règles du pare-feu n'empêche pas l'accès au serveur avec la connexion.

#### Impossible d'installer les packages

- **Problème.** Le programme cherche à installer, au niveau du projet, les packages requis. Or l'installation peut échouer pour plusieurs raisons.
- **Solution.** Confirmer:
  - Installation de pré-requis.
    - Chez le système d'exploitation Windows, l'installation de RTools. Pour certains packages, R se sert de code en d'autres langues (e.g., C++ pour des opérations plus performantes). Pour l'employer dans un package, il faut le "compiler". Pour ce faire, on a besoin de RTools. Dans l'absence de ce programme, impossible d'installer certains packages.
    - Chez le système d'exploitation Linux, l'installation a besoins de certains packages Linux. Si cela s'applique à vous, veuillez contacter l'équipe de développement de ce programme pour une liste des packages Linux requis.
  - Ouverture du projet comme un projet. Pour installer les packages requis dans la manière escomptée, il faut ouvrir ce projet en tant que tel. Voir [ici](#lancer) pour plus de détails.

#### `curl::curl_fetch_memory() 

- **Problème.** Le serveur a trop tardé à répondre au programme (i.e., à l'outil employé par le programme pour communiquer avec le serveur). Le programme échoue en raison de non-réponse du serveur.
- **Solution.** Une recherche de solution est en cours. Ce problème s'applique au téléchargement automatisé des données. En attendant une meilleure solution, si le téléchargement échoue, il est conseillé de télécharger manuellement dans le bon répertoire et de lancer les autre programmes normalement.

Pour les données :

- Télécharger ici :`01_obtenir\donnees`
- Décomprimer dans des sous-dossiers dans ce même dossier
