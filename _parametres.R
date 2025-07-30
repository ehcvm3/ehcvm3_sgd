# =============================================================================
# 1. Connexion au serveur
# =============================================================================

# -----------------------------------------------------------------------------
# Fournir les détails du serveur Survey Solutions
# -----------------------------------------------------------------------------

serveur         <- ""
espace_travail  <- ""
utilisateur     <- ""
mot_de_passe    <- ""

# -----------------------------------------------------------------------------
# Questionnaire sur Headquarters dont les données sont à passer en revue
# -----------------------------------------------------------------------------

# fournir un texte qui identifie le(s) questionanire(s). il peut s'agir du:
# - nom/titre complet
# - sous-texte
# - expression régulière

qnr_menage          <- ""
qnr_communautaire   <- ""

# -----------------------------------------------------------------------------
# Questionnaire sur Designer
# -----------------------------------------------------------------------------

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

# =============================================================================
# 2. Comportement de la validation
# =============================================================================

# Fournir un vecteur délimité par virgule des statuts d'entretien
# à passer en revue
# Voir les valeurs ici: https://docs.mysurvey.solutions/headquarters/export/system-generated-export-file-anatomy/#coding_status
# Statuts admis par ce script:
# - Completed: 100
# - ApprovedBySupervisor: 120
# - ApprovedByHeadquarters: 130
statuts_a_rejeter <- c(100, 120)

# Fournir un vecteur délimité par virgule des types de problèmes à rejeter
# {susoreview} utilise les codes suivants:
# - 1 = Rejeter
# - 2 = Commenter une variable
# - 3 = Erreur de validation de Survey Solutions
# - 4 = Passer en revue
problemes_a_rejeter <- c(1)

# Rejeter les entretiens automatiquement
# - Si TRUE, le programme demande au serveur de rejeter ces entretiens.
# - Si FALSE, le programme ne rejette pas.
# - Dans les deux cas, les entretiens à rejeter, ainsi que les motifs de rejet,
#   sont sauvegardés dans `/output/`
devrait_rejeter <- FALSE

# =============================================================================
# 3. Rapport de progrès
# =============================================================================

# =============================================================================
# 4. Rapport de qualité
# =============================================================================

# PÉRIODE DU RAPPORT: DÉBUT ET FIN
# pour les dates,  mettre dans le format ISO 8601: AAAA-MM-JJ
# par exemple "2025-11-25" pour le 25 novembre 2025
rapport_debut <- ""
rapport_fin <- ""
