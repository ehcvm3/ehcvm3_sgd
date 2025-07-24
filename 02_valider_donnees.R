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
  dirs$valider$recommendations,
  dirs$valider$decisions,
)

cat("Supression d'anciennes sorties en cours")
purrr::walk(
  .x = dirs_de_sortie,
  .f = ~ susoflows::delete_in_dir(.x)
)

# ------------------------------------------------------------------------------
# identifier les problèmes
# ------------------------------------------------------------------------------

cat("Création d'attributs en cours")
source(here::here(dirs$valider$r, "01_creer_attributs.R"))

cat("Création de problèmes en cours")
source(here::here(dirs$valider$r, "01_creer_problemes.R"))

cat("Calcul de recommandations en cours")
source(here::here(dirs$valider$r, "03_recommander_actions.R"))
