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
# Données 💾
# ==============================================================================

# ------------------------------------------------------------------------------
# charger les programmes afférants
# ------------------------------------------------------------------------------

dirs$obtenir$r |>
	fs::dir_ls() |>
  purrr::walk(.f = ~ source(.x))

# ------------------------------------------------------------------------------
# ménage
# ------------------------------------------------------------------------------

obtenir_donnees(
  type = "menage",
  qnr_expr = qnr_menage,
  dirs = dirs,
  server = serveur,
  workspace = espace_travail,
  user = utilisateur,
  password = mot_de_passe
)

construire_df_conso_alim(dirs = dirs)

# ------------------------------------------------------------------------------
# communautaire
# ------------------------------------------------------------------------------

obtenir_donnees(
  type = "communautaire",
  qnr_expr = qnr_menage,
  dirs = dirs,
  server = serveur,
  workspace = espace_travail,
  user = utilisateur,
  password = mot_de_passe
)

# ------------------------------------------------------------------------------
# composition des équipes
# ------------------------------------------------------------------------------

cat("Téléchargement de la composition des équipes en cours")

get_team_composition(
  dir = dirs$obtenir$meta$equipes,
  server = serveur,
  workspace = espace_travail,
  user = utilisateur,
  password = mot_de_passe
)
