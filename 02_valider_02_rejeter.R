# ==============================================================================
# mise en place
# ==============================================================================

# ------------------------------------------------------------------------------
# activer l'environnement du projet
# ------------------------------------------------------------------------------

renv::restore(prompt = FALSE)

# ------------------------------------------------------------------------------
# définir les répertoires
# ------------------------------------------------------------------------------

source(here::here("R", "02_definir_repertoires.R"))

# ------------------------------------------------------------------------------
# charger et valider les paramètres du projet
# ------------------------------------------------------------------------------

source(here::here("_parametres.R"))
source(here::here("R", "03_valider_parametres.R"))

# ==============================================================================
# orchestrer les actions
# ==============================================================================

chemin_fichier_rejet <- fs::path(dirs$valider$decisions, "to_reject_api.xlsx")

# ------------------------------------------------------------------------------
# confirmer l'existence de fichier d'entretiens à rejeter
# ------------------------------------------------------------------------------

fichier_rejet_existe <- fs::file_exists(path = chemin_fichier_rejet)
if (fichier_rejet_existe == FALSE) {

  cli::cli_abort(
    message = c(
      "x" = "Le fichier d'entretiens à rejeter est introuvable.",
      "i" = paste(
        "Le programme s'attend à retrouver le fichier `to_reject_api.xlsx`",
        "dans `02_valider/sortie/03_decisions`.",
        "Or, ce fichier n'y est pas.",
        "Soit vous n'avez pas encore lancé `02_valider_01_recommander.R`",
        "soit vous avez modifié le nom du fichier."
      ),
      "Veuillez corriger avant de relancer ce script"
    )
  )

}

# ------------------------------------------------------------------------------
# confirmer qu'il y a des entretiens à rejeter
# ------------------------------------------------------------------------------

# charger les entretiens à rejeter
entretiens_a_rejeter <- readxl::read_xls(path = chemin_fichier_rejet)

if (nrow(entretiens_a_rejeter) == 0) {

  cli::cli_abort(
    message = c(
      "x" = "Aucun entretien à rejeter",
      "i" = paste(
        "Le fichier",
        "{.file 02_valider/sortie/03_decisions/to_reject_api.xlsx}",
        "ne contient aucun entretien à rejeter."
      )
    )
  )

}

# ------------------------------------------------------------------------------
# confirmer les colonnes du fichier
# ------------------------------------------------------------------------------

colonnes_retrouvees_rejeter <- names(entretiens_a_rejeter)

colonnes_attendues_rejeter <- c(
  "interview__id",
  "reject_comment",
  "interview__status"
)

# toutes les colonnes y sont
if (any(!colonnes_attendues_rejeter %in% colonnes_retrouvees_rejeter)) {

  cli::cli_abort(
    message = c(
      "x" = "Colonne(s) absente(s) du fichier des entretiens à rejeter.",
      "i" = "Attendues : {glue::glue_collapse(colonnes_attendues_rejeter, sep = '')}",
      "i" = "Retrouvées : {glue::glue_collapse(colonnes_retrouvees_rejeter, sep = '')}"
    )
  )

}

# les colonnes sont dans l'ordre attendu
# sinon, la fonction `pwalk()` ne marchera pas,
# comme elle désigne les indices de colonne
if (!identical(colonnes_attendues_rejeter, colonnes_retrouvees_rejeter)) {

  cli::cli_abort(
    message = c(
      "x" = "Colonnes dans le mauvais ordre dans le fichier `to_reject_api.xlsx`",
      "i" = "Ordre attendu : {glue::glue_collapse(colonnes_attendues_rejeter, sep = '')}",
      "i" = "Ordre retrouvée : {glue::glue_collapse(colonnes_retrouvees_rejeter, sep = '')}"
    )
  )

}

# ------------------------------------------------------------------------------
# confirmer le contenu des colonnes
# ------------------------------------------------------------------------------

# charger les entretiens à rejeter
entretiens_a_rejeter <- readxl::read_xls(
  path = chemin_fichier_rejet,
  col_types = c(
    "text", # interview__id
    "text", # reject_comment
    "numeric" # interview__status
  )
)

# interview__id
if(!all(susoapi:::is_guid(entretiens_a_rejeter$interview__id))) {

  cli::cli_abort(
    message = c(
      "x" = "Mauvais contenu de la colonne {.var interview__id}.",
      "i" = paste(
        "Le programme s'attend à une valeur de {.var interview__id}",
        "telle que retrouvée dans les données exportée.",
        "Par exemple : ",
        "{.val 1e8ac70dfbe045f9946d20b8b0591878}"
      )
    )
  )

}

# interview__status

# énumérer les valeurs de statut valides selon {susoreview}
statuts_valides <- c(
  100, # Completed
  120, # ApprovedBySupervisor
  130 # ApprovedByHeadquarters
)

if (any(!entretiens_a_rejeter$interview__status %in% statuts_valides)) {

  cli::cli_abort(
    message = c(
      "x" = "Mauvais contenu de la colonne {.var interview__status}.",
      "i" = paste(
        "Le programme n'admet que les valeurs suivantes : ",
        "{glue::glue_collapse(statuts_valides, sep = ', ', last = ', et ')}"
      )
    )
  )

}

# ------------------------------------------------------------------------------
# effectuer le rejet sur le serveur
# ------------------------------------------------------------------------------

# effecter le rejet pour les cas dans le fichier
purrr::pwalk(
  .l = entretiens_a_rejeter,
  .f = ~ susoreview::reject_interview(
    interview__id = ..1,
    interview__status = ..3,
    reject_comment = ..2,
    statuses_to_reject = statuts_a_rejeter,
    server = serveur,
    workspace = espace_travail,
    user = utilisateur,
    password = mot_de_passe
  )
)
