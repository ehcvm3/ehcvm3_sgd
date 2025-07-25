# ==============================================================================
# identifier les cas à passer en revue
# ==============================================================================

entretiens_a_valider <- dirs$obtenir$menage$fusionnees |>
  fs::path(fichier_menage) |>
  # ingérer la base principale
	haven::read_dta() |>
  # trier les entretiens
  # par statut d'entretien chez Survey Solutions
  dplyr::filter(interview__status %in% statuts_a_rejeter) |>
  # par les données de l'entretien
  dplyr::filter(
    # résultat de l'entretien: rempli, ménage sélectionné ou de replacement
    (s00q08 %in% c(1, 2))
    &
    # toutes les visites ont été faites
    (visite1 == 1 & visite2 == 2 & visite3 == 3)
  ) |>
  dplyr::mutate(interview_complete = 1) |>
  dplyr::select(
    interview__id, interview__key,
    interview_complete, interview__status
  )

haven::write_dta(
  data = entretiens_a_valider,
  path = fs::path(dirs$valider$cas, "entretiens_a_valider.dta")
)

# ==============================================================================
# charger les bases requises
# ==============================================================================

# ------------------------------------------------------------------------------
# bases à charger tel quel
# ------------------------------------------------------------------------------

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# données d'enquête
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

bases <- c(
  "membres",
  "filets_securite",
  "chocs",
  "parcelles",
  "cultures",
  "elevage",
  "equipements",
  "depense_7j",
  "depense_30j",
  "depense_3m",
  "depense_6m",
  "depense_12m"
)

purrr::walk(
  .x = bases,
  .f = ~ charger_base_filtree(
    dir = dirs$obtenir$menage$fusionnees,
    base = .x,
    nom = .x,
    entretiens_a_valider = entretiens_a_valider
  )
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# données de système
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

bases_sys <- c(
  "interview__errors", "interview__diagnostics", "interview__comments"
)

noms_sys <- c(
  "suso_errors", "suso_diagnostics", "comments"
)

purrr::walk2(
  .x = bases_sys,
  .y = noms_sys,
  .f = ~ charger_base_filtree(
    dir = dirs$obtenir$menage$fusionnees,
    base = .x,
    nom = .y,
    entretiens_a_valider = entretiens_a_valider
  )
)

# ------------------------------------------------------------------------------
# bases à charger avec des modification de nom ou de chemin
# ------------------------------------------------------------------------------

# ménage
# mettre le nom au pluriel
menages <- charger_base_filtree(
  dir = dirs$obtenir$menage$fusionnees,
  base = fichier_menage,
  nom = "menages",
  entretiens_a_valider = entretiens_a_valider
)

# travail familial dans l'entreprise familiale
# mettre le nom en cas de serpent
entreprise_travail_familial <- charger_base_filtree(
  dir = dirs$obtenir$menage$fusionnees,
  base = "entreprise_travailFamilial",
  nom = "entreprise_travail_familial",
  entretiens_a_valider = entretiens_a_valider
)

# consommation alimentaire des 7 derniers jours
conso_alim_7j <- charger_base_filtree(
  dir = dirs$obtenir$menage$derivees,
  base = "conso_alim_7j",
  nom = "conso_alim_7j",
  entretiens_a_valider = entretiens_a_valider
)
