## Objectif 🎯

Ce projet cherche à gérer la qualité des données des enquêtes ménage et communautaire en automatisant certains flux de travail réalisés régulièrement par l'équipe du quartier général :

1. **Obtenir les données.** Ceci consiste à :
  - Faire exporter les données d'enquête.
  - Télécharger les données exportées.
  - Fusionner les différentes bases (e.g. adjoindre les bases des différentes versions).
  - Constuire certaines bases (e.g. fusionner les rosters de consommation alimentaire, harmoniser les noms de variables, sauvegarder une seule base unique).
2. **Valider les données.**
  - Confirmer le respect de certaines règles (e.g., existence d'un seul chef de ménage, consommation d'alimentation au cours des 7 derniers jours, etc).
  - Contrôler la cohérence d'informations issues éventuellement de différents modules et/ou collectées à de différents niveaux d'observation.
  - Identifier les points aberrants pour bon nombre de variable quantitative et/ou monétaire.
3. **Créer des rapports de suivi.**
  - Calculer des indicateurs par équipe et dans le temps.
  - Composer des tableaux permettant le suivi de ces indicateurs.
  - Créer un rapport qui contient ces informations.

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
  [ceci](https://cran.r-project.org/bin/windows/base/R-4.4.2-win.exe)
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

- [Paramétrage initial](#paramétrage-initial-️)
- [Utilisation régulière](#utilisation-régulière-️)

### Paramétrage initial ⚙️

Avant de lancer le programme, ouvrir le fichier `_parametres.R` et fournir les informations requises.

Les sections qui suivent fournissent les détails techniques pour le remplissage.

#### Détails du serveur

Pour que le programme puisse agir à votre place, il faut :

1. Créer un compte API
2. Fournir les détails de connexion au serveur

##### Créer un compte API

Sur votre serveur SuSo, créer un compte API (procédure [ici](https://docs.mysurvey.solutions/headquarters/accounts/teams-and-roles-tab-creating-user-accounts/)) et lui donner accès à l'espace de travail qui héberge le questionnaire NSU (procédure [ici](https://docs.mysurvey.solutions/headquarters/accounts/adding-users-to-workspaces/)).

##### Fournir les détails de connexion au serveur

Puisque le programme se connectera au serveur en tant que l'agent API, il faut lui donner les informations suivantes entre les guillemetsj

```r
serveur         <- "" # URL du serveur
espace_travail  <- "" # l'attribut `name`. Voir ici: https://docs.mysurvey.solutions/headquarters/accounts/workspaces/#workspace-display-name-attribute
utilisateur     <- "" # nom du compte API
mot_de_passe    <- "" # mot de passe du compte API
```

#### Questionnaires sur Headquarters

Pour chaque enquête, fournir une expression qui identifie les questionnaires dont les données sont à télécharger et traiter. Dans la plupart des cas, il s'agira d'un sous-texte présent dans l'ensemble des questionnaires visés. Dans certains cas, une expression régulière peut mieux faire l'affaire. (Pour en savoir plus, parcourir [ce site](https://regexlearn.com/) pédagogique et interactif)

```r
# fournir un texte qui identifie le(s) questionanire(s). il peut s'agir du:
# - nom/titre complet
# - sous-texte
# - expression régulière

qnr_menage          <- ""
qnr_communautaire   <- ""

```

#### Questionnaire ménage sur Designer

Pour le traitement des données ménage, le programme doit identifier la base "principale". De règle générale, ceci doit être simplement `ménage`. Pour prendre en compte votre cas : 

- Ouvrir les paramètres du questionanire dans Designer.
- Regarder la "variable" du projet.
- Copier la valeur, telle quelle sur Designer, dans ce champs.

```r
# fournir la "variable du questionnaire".
# normalement, ça doit être "menage", comme la valeur de défaut ici-bas
# pour certains, ça a été modifié, parfois pour des raisons d'organisation interne
# pour vérifier ou modifier, voici comment faire:
# - se connecter à Designer
# - ouvrir le questionnaire ménage
# - cliquer sur paramètres
# - copier ce qui figure dans le champs "questionnaire variable" et le coller ici-bas
# pour des informations complémentaires, voir ici: https://docs.mysurvey.solutions/questionnaire-designer/components/questionnaire-variable/
fichier_menage <- ""
```

#### Comportement du programme de rejet

Si souhaité, le programme peut contrôler et rejeter les entretiens dans les statuts suivants :

- Achevé par l'enquêteur mais pas encore contrôlé par le chef d'équipe (100)
- Approuvé par le chef d'équipe mais pas encore validé par le quarter général (120)
- Approuvé par le quartier général (130)

L'utilisateur doit indiquer le(s) statut(s) d'entretien à contrôler.

```r
# Fournir un vecteur délimité par virgule des statuts d'entretien
# à passer en revue
# Voir les valeurs ici: https://docs.mysurvey.solutions/headquarters/export/system-generated-export-file-anatomy/#coding_status
# Statuts admis par ce script:
# - Completed: 100
# - ApprovedBySupervisor: 120
# - ApprovedByHeadquarters: 130
statuts_a_rejeter <- c(100, 120)
```

#### Dates du rapport de qualité

Pour chaque indicateur, le rapport deux informations :

- Statistiques pour la période indiquée
- Tendance pour toute la période de collecte (voire au-delà de la période indiqué)

Pour indiquer une période du rapport, mettre des dates de début et de fin. Si l'on souhaite ne couvrir, par exemple, la semaine passée, il faut indiquer les dates et les tenir au courrant d'une semaine à l'ature. Si l'on souhaite plutôt avoir des statistiques pour toute la collecte, mettre les dates de début et de fin de collecte et re-créer le rapport chaque semaine avec des données plus récentes.

```r
# PÉRIODE DU RAPPORT: DÉBUT ET FIN
# pour les dates,  mettre dans le format ISO 8601: AAAA-MM-JJ
# par exemple "2025-11-25" pour le 25 novembre 2025
rapport_debut <- ""
rapport_fin <- ""
```

### Utilisation régulière ♻️

#### Ouvrir 📂

Ouvrir le projet en tant que tel. En particulier, double-cliquer sur `ehcvm3_sgd.Rproj`. Ceci aura l'effet de l'ouvrir dans RStudio et d'enclencher l'activation de l'environment du projet (e.g., installer les packages requis au niveau du projet). (Pour en savoir plus, lire [ici](https://rstats.wtf/projects#rstudio-projects) et [ici](https://support.posit.co/hc/en-us/articles/200526207-Using-RStudio-Projects).)

#### Lancer 🚀

Pour chaque action, exécuter le programme afférant :

- **`01_obtenir_01_donnees.R`**. Télécharger et décomprimer les données brutes des enquêtes ménage et communautaire. Résultats dans : `01_obtenir/donnees`.
- **`02_valider_01_recommander.R`** Valider les données de l'enquête ménage et créer des recommendations d'action pour chaque entretien (e.g., à rejeter, à passer en revue, etc.). Résultats dans : `02_valider/sortie`. Dans `01_cas/`, on retrouve les entretiens à valider d'après les paramètres de validation (e.g. statut SuSo, problèmes à rejeter, etc). Dans `02_recommandations`, on retrouve les recommendations d'action sous format Stata et Excel. Dans `03_decisions`, on retrouve une copie des recommendations de rejet, qui peut être modifiée à volonté (e.g., modifer le motif de rejet, ajouter des entretiens à rejeter, supprimer des entretiens de la liste à rejeter, etc).
- **`02_valider_02_rejeter.R`** Prendre les décisions de rejet dans `02_valider/sortie/03_decisions` et effectuer le rejet de chaque entrien dans ce fichier.
- **`03_creer_rapport_qualite.R`** Créer un rapport pour suivre les indicateurs de qualité  et d'enquête. Résultat dans `03_suivre/02_qualite`.


### Dépannage 🔨

En cas de problème :

- Lire les messages d'erreur. Parfois, ils indiquent le problème et quelques pistes de solution.
- Lire les problèmes fréquemment rencontrés ici-bas.
- Contacter l'équipe de développement, en fournissant les étapes suivies et les messages d'erreur (e.g. captures d'écran)

Voici quelques problèmes fréquemment rencontrés :

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

- Télécharger ici :`01_obtenir/donnees`
- Décomprimer dans des sous-dossiers dans ce même dossier
