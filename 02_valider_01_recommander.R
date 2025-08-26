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

# ------------------------------------------------------------------------------
# charger les programmes
# ------------------------------------------------------------------------------

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# inventorier les programmes
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

programmes_valider <- dirs$valider$r |>
  fs::dir_info() |>
  dplyr::select(path) |>
  dplyr::mutate(file_name = fs::path_file(path))

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# charger les définitions de fonction
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

# ceux dont le nom ne commence pas avec un chiffre
programmes_fonction <- programmes_valider |>
	dplyr::filter(grepl(x = file_name, pattern = "^[^0-9]+")) |>
	dplyr::pull(path)

purrr::walk(
  .x = programmes_fonction,
  .f = ~ source(.x)
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# charger les programmes de flux de travail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

# ceux dont le nom commence avec un chiffre
programmes_flux_travail <- programmes_valider |>
	dplyr::filter(grepl(x = file_name, pattern = "^[0-9]+")) |>
	dplyr::pull(path)

purrr::walk(
  .x = programmes_flux_travail,
  .f = ~ source(.x)
)

# ==============================================================================
# orchestrer les actions
# ==============================================================================

# ------------------------------------------------------------------------------
# purger les anciennes sorties
# ------------------------------------------------------------------------------

dirs_de_sortie <- c(
  dirs$valider$cas,
  dirs$valider$recommandations,
  dirs$valider$decisions
)

cli::cli_alert_info("Supression d'anciennes sorties en cours")
purrr::walk(
  .x = dirs_de_sortie,
  .f = ~ susoflows::delete_in_dir(.x)
)

# ------------------------------------------------------------------------------
# identifier les problèmes
# ------------------------------------------------------------------------------

cli::cli_alert_info("Préparation de données à valider en cours")
source(here::here(dirs$valider$r, "00_preparer_donnees.R"))

cli::cli_alert_info("Création d'attributs en cours")
source(here::here(dirs$valider$r, "01_creer_attributs.R"))

cli_alert_info("Création de problèmes en cours")
source(here::here(dirs$valider$r, "02_creer_problemes.R"))

cli_alert_info("Calcul de recommandations en cours")
source(here::here(dirs$valider$r, "03_recommander_actions.R"))
