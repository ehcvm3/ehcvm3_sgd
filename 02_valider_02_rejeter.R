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
