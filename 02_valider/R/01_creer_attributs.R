# ==============================================================================
# Note explicative
# ==============================================================================

#' Comment comprendre les objets créés par ce script
#'
#' @details
#' - `attributs_*` et/ou `*_specs`. Base de specifications.
#' - `attrib_*`. Base d'attributs.
#' - `attribs_*`. Liste dont les éléments sont des bases d'attributs, à l'instar
#' de la classe d'objet décrit immédiatement ci-haut

# ==============================================================================
# [1] Caractéristiques socio demographiques
# ==============================================================================

attributs_membres_spec <- tibble::tribble(
  ~ attrib_name, ~ fn_name, ~ condition, ~ attrib_vars,
  "access_internet_menage_ou_portable", "any_obs", "s01q43 == 1", "s01q43",
  "n_chefs", "count_obs", "s01q02 == 1", "s01q02",
) |>
	dplyr::mutate(df_name = "membres", .after = fn_name)

attribs_membres <- purrr::pmap(
  .l = attributs_membres_spec,
  .f = create_attribute_from_spec
)

# ==============================================================================
# [2]	EDUCATION (INDIVIDUS AGES DE 3 ANS ET PLUS)
# ==============================================================================

educ_specs <- tibble::tribble(
  ~ attrib_name, ~ fn_name, ~ condition, ~ attrib_vars,
  "abandonner_educ", "any_obs", "(s02q11 == 5) | (s02q13 == 2)", "s02q1[13]",
  "bourse_educ", "any_obs", "s02q29 > 0", "s02q29",
  "frequenter_ecole", "any_obs", "s02q09 == 1 | s02q13 == 1", "s02q09|s02q13",
) |>
	dplyr::mutate(df_name = "membres", .after = fn_name)

attribs_educ <- purrr::pmap(
  .l = educ_specs,
  .f = create_attribute_from_spec
)

# ==============================================================================
# 4	EMPLOI (INDIVIDUS AGES DE 5 ANS ET PLUS)	27
# ==============================================================================

# ------------------------------------------------------------------------------
# activités économiques
# ------------------------------------------------------------------------------

activite_membre_specs <- tibble::tribble(
  ~ attrib_name, ~ fn_name, ~ df_name, ~ condition, ~ attrib_vars,
  "travaille_agric_elevage_peche_ou_chasse",
    "any_obs", "membres", "s04q09 == 1", "s04q09",
  "travaille_entreprise",
    "any_obs", "membres",
    "(s04q10 == 1) | (s04q14 == 1) | (s04q46 == 9) | (s04q66 == 9)", "s04q1[04]|s04q[46]6",
  "travaille_agric_familiale",
    "any_obs", "membres", "s04q13 == 1", "s04q13",
)

attribs_activites_membres <- purrr::pmap(
  .l = activite_membre_specs,
  .f = create_attribute_from_spec
)

# ------------------------------------------------------------------------------
# comment subvenir à ses besoins sans emploi
# ------------------------------------------------------------------------------

revenus_specs <- tibble::tribble(
  ~ attrib_name, ~ fn_name, ~ df_name, ~ condition, ~ attrib_vars,
  "subvient_recolte",
    "any_obs", "membres", "s04q19 == 5", "s04q19",
  "subvient_vivres_gratuits",
    "any_obs", "membres", "s04q19 == 6", "s04q19",
)

attribs_revenus <- purrr::pmap(
  .l = revenus_specs,
  .f = create_attribute_from_spec
)

# ==============================================================================
# 6	EPARGNE ET CREDIT
# ==============================================================================

epargne_credit_specs <- tibble::tribble(
  ~ attrib_name, ~ fn_name, ~ condition, ~ attrib_vars,
  # demander un prêt
  "demander_credit", "any_obs", "s06q04 == 1", "s06q04",
  # utilisation de prêt
  "utiliser_pret_educ", "any_obs", "s06q23 == 1", "s06q23",
  "utiliser_pret_sante", "any_obs", "s06q23 == 2", "s06q23",
  "utiliser_pret_vehicule", "any_obs", "s06q23 == 3", "s06q23",
  "utiliser_pret_biens_menagers", "any_obs", "s06q23 == 4", "s06q23",
  "utiliser_pret_fete", "any_obs", "s06q23 == 5", "s06q23",
  "utiliser_pret_biz", "any_obs", "s06q23 %in% c(6, 7)", "s06q23",
  "utiliser_pret_intrants", "any_obs", "s06q23 == 8", "s06q23",
) |>
	dplyr::mutate(df_name = "membres", .after = fn_name)

attribs_epargne_credit <- purrr::pmap(
  .l = epargne_credit_specs,
  .f = create_attribute_from_spec
)

# ==============================================================================
# [7B] CONSOMMATION ALIMENTAIRE DES 7 DERNIERS JOURS
# ==============================================================================

conso_propre_prod_specs <- tibble::tribble(
  ~ attrib_name, ~ condition,
  # céréales
  "riz", "aliment__id %in% c(1, 2)",
  "mais", "aliment__id %in% c(6, 7)",
  "mil", "aliment__id == 8",
  "sorgho", "aliment__id == 9",
  "ble", "aliment__id == 10",
  "fonio", "aliment__id == 11",
  # viandes
  "boeuf", "aliment__id %in% c(40:47)",
  "mouton", "aliment__id %in% c(48, 50, 58)",
  "chevre", "aliment__id %in% c(49, 50, 59)",
  "chameau", "aliment__id == 56",
  "porc", "aliment__id %in% c(51:55, 60)",
  "lapin", "aliment__id == 57",
  "poulet", "aliment__id %in% c(69:72, 75)",
  "autre_volailles", "aliment__id %in% c(73:78)",
  "gibier", "aliment__id %in% c(61, 62, 63, 64)",
  # poisson
  "poisson_fruit_de_mer_frais", "aliment__id %in% c(85:95, 108, 109, 112)",
  "chenille", "aliment__id %in% c(116, 117)",
  "escargot", "aliment__id == 113",
  # lait et oeufs
  "lait", "aliment__id %in% c(119, 120)",
  "oeufs", "aliment__id == 130",
  # huiles
  "beurre", "aliment__id == 131",
  # fruits
  "mangues", "aliment__id == 145",
  "ananas", "aliment__id == 146",
  "banane_douce", "aliment__id == 151",
  "goyave", "aliment__id == 160",
  "noix_de_coco", "aliment__id == 156",
  "canne_a_sucre", "aliment__id == 157",
  "orange", "aliment__id == 147",
  "citron",  "aliment__id == 148",
  # légumes
  "choux", "aliment__id == 174",
  "carotte",  "aliment__id == 175",
  "haricot_vert",   "aliment__id == 176",
  "concombre",   "aliment__id == 177",
  "aubergine",   "aliment__id == 178",
  "courge",   "aliment__id == 180",
  "poivron",   "aliment__id == 182",
  "tomate_fraiche",   "aliment__id == 183",
  "gombo",   "aliment__id == 185",
  "oignon",   "aliment__id == 188",
  # légumineuses et tubercules
  "petits_pois",   "aliment__id == 204",
  "niebe",   "aliment__id == 208",
  "soja",   "aliment__id == 209",
  "arachides",   "aliment__id %in% c(212:219)",
  "sesame", "aliment__id == 221",
  "noix_cajou", "aliment__id == 222",
  "manioc",  "aliment__id %in% c(224:225, 237:239)",
  "igname",   "aliment__id %in% c(226:227)",
  "plantain", "aliment__id == 228",
  "patate_douce",  "aliment__id == 229",
  "pomme_de_terre", "aliment__id == 230",
  "taro", "aliment__id == 231",
  "souchet", "aliment__id == 233",
  # sucreries
  "miel", "aliment__id == 246",
  # épices et condiments
  "ail", "aliment__id == 256",
  "gingembre", "aliment__id == 254",
) |>
	dplyr::mutate(
    df_name = "conso_alim_7j",
    fn_name = "any_obs",
    condition = glue::glue("({condition}) & (s07bq04 > 0)"),
    attrib_name = glue::glue("cons_propre_prod_{attrib_name}"),
    attrib_vars = "s07Bq02_|s07bq04"
  ) |>
	dplyr::select(attrib_name, fn_name, df_name, condition, attrib_vars)

attribs_conso_propre_prod_agric <- purrr::pmap(
  .l = conso_propre_prod_specs,
  .f = create_attribute_from_spec
)

# ==============================================================================
# [9B] Dépenses non alimentaires au cours des 7 derniers jours
# ==============================================================================

attrib_dep_non_alim_7d <- menages |>
	susoreview::create_attribute(
    condition = s09Bq02__302 == 1,
    attrib_name = "depense_carburant_7d",
    attrib_vars = "s09Bq02"
  )

# ==============================================================================
# [9C]  Dépenses non alimentaires au cours des 30 derniers jours
# ==============================================================================

attrib_dep_non_alim_30d <- menages |>
	susoreview::any_vars(
    var_pattern = "s09Cq02__(409|410|411|412)",
    attrib_name = "depense_carburant_30d",
    attrib_vars = "s09Cq02"
  )

# ==============================================================================
# [10]	ENTREPRISES NON AGRICOLES
# ==============================================================================

attrib_possede_entreprise <- susoreview::any_vars(
  df = menages,
  var_pattern = "s10q0[2-9]|s10q10",
  var_val = 1,
  attrib_name = "possede_entreprise"
)

# ------------------------------------------------------------------------------
# travail familial utilisé par l'entreprise
# ------------------------------------------------------------------------------

attrib_biz_utilise_travail_familial <- susoreview::any_obs(
  df = entreprise_travail_familial,
  where = s10q61a == 1,
  attrib_name = "biz_utilise_travail_familial",
  attrib_vars = "s10q61a"
)

# ==============================================================================
# [11]	LOGEMENT
# ==============================================================================

caracteristiques_logement_specs <- tibble::tribble(
  ~ attrib_name, ~ fn_name, ~ condition, ~ attrib_vars,
  "logement_climatiseur", "create_attribute", "s11q03__1 == 1", "s11q03",
  "logement_ventilateur", "create_attribute", "s11q03__3 == 1", "s11q03",
  "access_electricite", "create_attribute", "s11q32 %in% c(1, 2, 3)", "s11q32",
  "utiliser_elec_eclairer", "create_attribute", "s11q36 == 1", "s11q36",
  "utiliser_groupe_pendant_panne", "create_attribute", "s11q41 == 1", "s11q41",
  "utiliser_elec_cuisiner", "create_attribute", "s11q43 == 2", "s11q43",
  "logement_internet", "create_attribute", "s11q50 == 1", "s11q50",
) |>
	dplyr::mutate(df_name = "menages", .after = fn_name)

attrib_logement <- purrr::pmap(
  .l = caracteristiques_logement_specs,
  .f = create_attribute_from_spec
)

# ==============================================================================
# [12]	ACTIFS DU MENAGE
# ==============================================================================

# ------------------------------------------------------------------------------
# possède des biens spécifiques
# ------------------------------------------------------------------------------

biens_durables_specs <- tibble::tribble(
  ~ attrib_name, ~ condition,
  "groupe_elec", "s12q02__827 == 1",
  "fusil", "s12q02__840 == 1",
) |>
	dplyr::mutate(
    attrib_name = glue::glue("possede_{attrib_name}"),
    fn_name = "create_attribute",
    df_name = "menages",
    attrib_vars = "s12q02"
  ) |>
	dplyr::select(attrib_name, fn_name, df_name, condition, attrib_vars)

attrib_biens_durable <- purrr::pmap(
  .l = biens_durables_specs,
  .f = create_attribute_from_spec
)

# ------------------------------------------------------------------------------
# possède un véhicule
# ------------------------------------------------------------------------------

codes_vehicules <- c(
  "828", # Voiture personnelle
  "829", # Moto/Vélomoteur/Tricycle à moteur
  "830", # Bicyclette, vélo de course
  "839" # Pirogue et hors-bord (bateaux de plaisance)
) |>
	paste(collapse = "|")

attrib_posseder_vehicule <- menages |>
  susoreview::any_vars(
    var_pattern = glue::glue("s12q02__({codes_vehicules})"),
    var_val = 1,
    attrib_name = "possede_vehicule",
  )

# ------------------------------------------------------------------------------
# possède des biens/équipements du ménage
# ------------------------------------------------------------------------------

codes_biens_equipements_menage <- c(
  "801", # Salon  (Fauteuils et table basse)
  "802", # Table à manger  (table + chaises)
  "803", # Lit
  "804", # Matelas simple
  "805", # Armoires et autres meubles
  "806", # Tapis
  "807", # Fer à repasser électrique
  "808", # Fer à repasser à charbon
  "809", # Cuisinière à gaz ou électrique
  "810", # Bonbonne de gaz
  "811", # Réchaud (plaque) à gaz ou électrique
  "812", # Four à micro-onde ou électrique
  "813", # Foyers améliorés
  "814", # Robot de cuisine électrique (Moulinex)
  "815", # Mixeur/Presse-fruits non électrique
  "816", # Réfrigérateur
  "817", # Congélateur
  "818", # Ventilateur sur pied
  "819", # Radio simple/Radiocassette
  "820", # Appareil TV
  "821", # Magnétoscope/CD/DVD
  "822", # Antenne parabolique / décodeur
  "823", # Lave-linge, sèche linge
  "824", # Aspirateur
  "825", # Climatiseurs/splits (non installés au mur)
  "826", # Tondeuse à gazon et autre article de jardinage
  "833", # Chaîne Hi Fi
  "834" # Téléphone fixe
) |>
	paste(collapse = "|")
	
attrib_posseder_biens_equipement_menage <- menages |>
  susoreview::any_vars(
    var_pattern = glue::glue("s12q02__({codes_biens_equipements_menage})"),
    var_val = 1,
    attrib_name = "possede_biens_equipements_menage",
  )

# ------------------------------------------------------------------------------
# possède des biens ayant besoin d'électricité
# ------------------------------------------------------------------------------

codes_biens_electriques <- c(
  "807", # Fer à repasser électrique
  "812", # Four à micro-onde ou électrique
  "814", # Robot de cuisine électrique (Moulinex)
  "816", # Réfrigérateur
  "817", # Congélateur
  "818", # Ventilateur sur pied
  "820", # Appareil TV
  "821", # Magnétoscope/CD/DVD
  "824", # Aspirateur
  "825", # Climatiseurs/splits (non installés au mur)
  "833" # Chaîne Hi Fi
) |>
	paste(collapse = "|")

attrib_possede_biens_elec <- menages |>
	susoreview::any_vars(
    var_pattern = glue::glue("s12q02__({codes_biens_electriques})"),
    var_val = 1,
    attrib_name = "possede_biens_elec",
  )

# ==============================================================================
# [15]	FILETS DE SECURITE
# ==============================================================================

filets_securite_specs <- tibble::tribble(
  ~ attrib_name, ~ fn_name, ~ condition, ~ attrib_vars,
  "beneficie_filet_securite", "any_obs", "s15q05 == 1", "s15q05",
  "beneficie_assistance_educ", "any_obs", "(filets_securite__id == 15) & (s15q05 == 1)", "s15q0[25]",
  "beneficie_assistance_carburant", "any_obs", "(filets_securite__id) == 19 & (s15q05 == 1)", "s15q0[25]",
) |>
	dplyr::mutate(df_name = "filets_securite", .after = fn_name)

attrib_filets_securite <- purrr::pmap(
  .l = filets_securite_specs,
  .f = create_attribute_from_spec
)

# ==============================================================================
# [13] TRANSFERTS
# ==============================================================================

transferts_specs <- tibble::tribble(
  ~ attrib_name, ~ fn_name, ~ condition, ~ attrib_vars,
  "transfert_recu", "create_attribute", "s13q09 == 1", "s13q09",
) |>
	dplyr::mutate(df_name = "menages", .after = fn_name)

attrib_transferts <- purrr::pmap(
  .l = transferts_specs,
  .f = create_attribute_from_spec
)

# ==============================================================================
# [14] CHOCS ET STRATEGIES DE SURVIE
# ==============================================================================

chocs_12m_specs <- tibble::tribble(
  ~ attrib_name, ~ condition,
  "aide_proches", "(s14q03 == 1) & (s14q07__2 == 1)",
  "aide_gouv", "(s14q03 == 1) & (s14q07__3 == 1)",
  "descolarise", "(s14q03 == 1) & (s14q07__11 == 1)",
  "credit", "(s14q03 == 1) & (s14q07__15 == 1)",
  "vente_betail", "(s14q03 == 1) & (s14q07__22 == 1)",
) |>
	dplyr::mutate(
    attrib_name = glue::glue("choc_strategie_{attrib_name}"),
    fn_name = "any_obs",
    df_name = "chocs",
    attrib_vars = "s14q0[37]"
  )

attrib_chocs_12m_strategie_adaptation <- purrr::pmap(
  .l = chocs_12m_specs,
  .f = create_attribute_from_spec
)

# ==============================================================================
# [16A] Parcelles
# ==============================================================================

attrib_pratique_agric <- susoreview::create_attribute(
  df = menages,
  condition = s16Aq00 == 1,
  attrib_name = "pratique_agric",
  attrib_vars = "s16Aq00"
)

intrants_appliques_specs <- tibble::tribble(
  ~ attrib_name, ~ condition, ~ attrib_vars,
  # engrais
  "appliquer_uree", "s16Aq29a1 > 0", "s16Aq29a1",
  "appliquer_phosphates", "s16Aq29b1 > 0", "s16Aq29b1",
  "appliquer_npk", "s16Aq29c1 > 0", "s16Aq29c1",
  "appliquer_super_simple", "s16Aq29d1 > 0", "s16Aq29d1",
  "appliquer_super_triple", "s16Aq29e1 > 0", "s16Aq29e1",
  "appliquer_autres_engrais_chimique", "s16Aq29f1 > 0", "s16Aq29f1",
  # produits phytosanitaires
  "appliquer_pesticides", "s16Aq31a1 > 0", "s16Aq31a1",
  "appliquer_herbicides", "s16Aq31b1 > 0", "s16Aq31b1",
  "appliquer_fongicides", "s16Aq31c1 > 0", "s16Aq31c1",
  "appliquer_autres_prod_phytosanitaires", "s16Aq31d1 > 0", "s16Aq31d1",
) |>
	dplyr::mutate(
    fn_name = "any_obs",
    df_name = "parcelles"
  ) |>
	dplyr::select(attrib_name, fn_name, df_name, condition, attrib_vars)

attrib_parelles <- purrr::pmap(
  .l = intrants_appliques_specs,
  .f = create_attribute_from_spec
)

# ==============================================================================
# [16B] Coût des intrants
# ==============================================================================

# ------------------------------------------------------------------------------
# utilisation d'intrants agricoles
# ------------------------------------------------------------------------------

intrants_acquis_specs <- tibble::tribble(
  ~ attrib_name, ~ condition, ~ attrib_vars,
  # engrais
  "utiliser_uree", "s16bq02__3 == 1", "s16bq02",
  "utiliser_phosphates", "s16bq02__4 == 1", "s16bq02",
  "utiliser_npk", "s16bq02__5 == 1", "s16bq02",
  "utiliser_super_simple", "s16bq02__6 == 1", "s16bq02",
  "utiliser_super_triple", "s16bq02__8 == 1", "s16bq02",
  "utiliser_autres_engrais_chimique", "s16bq02__8 == 1", "s16bq02",
  # produits phytosanitaires
  "utiliser_pesticides", "s16bq02__9 == 1", "s16bq02",
  "utiliser_herbicides", "s16bq02__10 == 1", "s16bq02",
  "utiliser_fongicides", "s16bq02__11 == 1", "s16bq02",
  "utiliser_autres_prod_phytosanitaires", "s16bq02__12 == 1", "s16bq02",
  # semences
  "utiliser_petit_mil", "s16bq02__13 == 1", "s16bq02",
  "utiliser_sorgho", "s16bq02__14 == 1", "s16bq02",
  "utiliser_mais", "s16bq02__15 == 1", "s16bq02",
  "utiliser_riz", "s16bq02__16 == 1", "s16bq02",
  "utiliser_autres_cereales", "s16bq02__17 == 1", "s16bq02",
  "utiliser_coton", "s16bq02__18 == 1", "s16bq02",
  "utiliser_sesame", "s16bq02__19 == 1", "s16bq02",
  "utiliser_haricots", "s16bq02__20 == 1", "s16bq02",
  "utiliser_arachides", "s16bq02__21 == 1", "s16bq02",
  "utiliser_tubercules", "s16bq02__22 == 1", "s16bq02",
  "utiliser_hevea_teck", "s16bq02__23 == 1", "s16bq02",
  "utiliser_cafe", "s16bq02__24 == 1", "s16bq02",
  "utiliser_cacao", "s16bq02__25 == 1", "s16bq02",
) |>
	dplyr::mutate(
    fn_name = "create_attribute",
    df_name = "menages"
  ) |>
	dplyr::select(attrib_name, fn_name, df_name, condition, attrib_vars)

attribs_intrants_agric <- purrr::pmap(
  .l = intrants_acquis_specs,
  .f = create_attribute_from_spec
)

# ==============================================================================
# [16C] Cultures
# ==============================================================================

# ------------------------------------------------------------------------------
# cultures liées aux semences dans 16B
# ------------------------------------------------------------------------------

cultures_liees_aux_semences_specs <- tibble::tribble(
  ~ attrib_name, ~ condition, ~ attrib_vars,
  "cultiver_petit_mil", "s16Cq05__1 == 1", "s16bq02",
  "cultiver_sorgho", "s16Cq05__2 == 1", "s16bq02",
  "cultiver_mais", "s16Cq05__4 == 1", "s16bq02",
  "cultiver_riz", "s16Cq05__3 == 1", "s16bq02",
  "cultiver_coton", "s16Cq05__43 == 1", "s16Cq05",
  "cultiver_sesame", "s16Cq05__13 == 1", "s16Cq05",
  "cultiver_haricots", "s16Cq05__37 == 1", "s16Cq05",
  "cultiver_arachides", "s16Cq05__10 == 1", "s16Cq05",
  "cultiver_hevea_teck", "s16Cq05__52 == 1", "s16Cq05",
  "cultiver_cafe", "s16Cq05__49 == 1", "s16Cq05",
  "cultiver_cacao", "s16Cq05__48 == 1", "s16Cq05",
) |>
	dplyr::mutate(
    df_name = "parcelles",
    fn_name = "any_obs",
  ) |>
	dplyr::select(attrib_name, fn_name, df_name, condition, attrib_vars)

attrib_cultures_liees_aux_semences <- purrr::pmap(
  .l = cultures_liees_aux_semences_specs,
  .f = create_attribute_from_spec
)

# ------------------------------------------------------------------------------
# catégories de cultures
# ------------------------------------------------------------------------------

codes_autres_cereales <- c(
  5, # Souchet
  6, # Blé
  7, # Fonio
  67 # Autre (à préciser)
) |>
	paste(collapse = "|")

attrib_cultiver_cereales <- parcelles |>
	susoreview::any_obs(
    where = dplyr::if_any(
      .cols = dplyr::matches(glue::glue("s16Cq05__({codes_autres_cereales})")),
      .fns = ~ .x == 1
    ),
    attrib_name = "cultiver_cereales",
    attrib_vars = glue::glue("s16Cq05__({codes_autres_cereales})")
  )

codes_tubercules <- c(
  14, # Manioc
  15, # Patate douce
  16, # Pomme de terre
  44, # Betterave
  46, # Taro
  47, # Igname
  67 # Autre (à préciser)
) |>
	paste(collapse = "|")

attrib_cultiver_tubercules <- parcelles |>
	susoreview::any_obs(
    where = dplyr::if_any(
      .cols = dplyr::matches(glue::glue("s16Cq05__({codes_tubercules})")),
      .fns = ~ .x == 1
    ),
    attrib_name = "cultiver_tubercules",
    attrib_vars = glue::glue("s16Cq05__({codes_tubercules})")
  )

# ------------------------------------------------------------------------------
# cultures citées dans la consommation alimentaire
# ------------------------------------------------------------------------------

cultures_propre_conso_specs <- tibble::tribble(
  ~ attrib_name, ~ condition,
  # céréales
  "riz", "cultures__id == 3",
  "mais", "cultures__id == 4",
  "mil", "cultures__id == 1",
  "sorgho", "cultures__id == 2",
  "ble", "cultures__id == 6",
  "fonio", "cultures__id == 7",
  # fruits
  "mangues", "cultures__id == 54",
  "ananas", "cultures__id == 56",
  "banane_douce", "cultures__id == 58",
  "goyave", "cultures__id == 59",
  "noix_de_coco", "cultures__id == 60",
  "canne_a_sucre", "cultures__id == 61",
  "orange", "cultures__id == 65",
  "citron",  "cultures__id == 66",
  # légumes
  "choux", "cultures__id == 28",
  "carotte",  "cultures__id == 30",
  "haricot_vert",   "cultures__id == 37",
  "concombre",   "cultures__id == 34",
  "aubergine",   "cultures__id == 32",
  "courge",   "cultures__id == 35",
  "poivron",   "cultures__id == 17",
  "tomate_fraiche",   "cultures__id == 29",
  "gombo",   "cultures__id == 11",
  "oignon",   "cultures__id == 33",
  # légumineuses et tubercules
  "petits_pois",   "cultures__id == 45",
  "niebe",   "cultures__id == 8",
  "soja",   "cultures__id == 64",
  "arachides",   "cultures__id == 10",
  "sesame", "cultures__id == 13",
  "noix_cajou", "cultures__id == 55",
  "manioc",  "cultures__id == 14",
  "igname",   "cultures__id == 47",
  "plantain", "cultures__id == 57",
  "patate_douce",  "cultures__id == 15",
  "pomme_de_terre", "cultures__id == 16",
  "taro", "cultures__id == 46",
  "souchet", "cultures__id == 5",
  # épices et condiments
  "ail", "cultures__id == 36",
  "gingembre", "cultures__id == 18",
) |>
	dplyr::mutate(
    df_name = "cultures",
    fn_name = "any_obs",
    attrib_name = glue::glue("cultive_{attrib_name}"),
    attrib_vars = "s16Cq05"
  ) |>
	dplyr::select(attrib_name, fn_name, df_name, condition, attrib_vars)

attribs_cultures_propre_conso <- purrr::pmap(
  .l = cultures_propre_conso_specs,
  .f = create_attribute_from_spec
)

# ==============================================================================
# [17] ELEVAGE
# ==============================================================================

attrib_pratique_elevage <- susoreview::create_attribute(
  df = menages,
  condition = s17q00 == 1,
  attrib_name = "pratique_elevage",
  attrib_vars = "s17q00"
)

attrib_vente_betail <- susoreview::any_obs(
  df = elevage,
  where = s17q10 > 0,
  attrib_name = "vente_betail",
  attrib_vars = "s17q10"
)

betail_consomme_specs <- tibble::tribble(
  ~ attrib_name, ~ condition,
  # viandes
  "boeuf", "elevage__id == 1",
  "mouton", "elevage__id == 2",
  "chevre", "elevage__id == 3",
  "chameau", "elevage__id == 4",
  "porc", "elevage__id == 7",
  "lapin", "elevage__id == 8",
  "poulet", "elevage__id == 10",
  "autre_volailles", "elevage__id %in% c(11, 12)",
) |>
	dplyr::mutate(
    df_name = "elevage",
    fn_name = "any_obs",
    condition = glue::glue("{condition} & s17q16 == 1"),
    attrib_name = glue::glue("produit_viande_{attrib_name}"),
    attrib_vars = "s17q03|s17q16"
  ) |>
	dplyr::select(attrib_name, fn_name, df_name, condition, attrib_vars)

attribs_produit_viande_animaux <- purrr::pmap(
  .l = betail_consomme_specs,
  .f = create_attribute_from_spec
)

produits_animaliers_specs <- tibble::tribble(
  ~ attrib_name, ~ condition, ~ attrib_vars,
  "lait", "s17q28 == 1", "s17q28",
  "oeufs", "s17q42 == 1", "s17q42",
) |>
	dplyr::mutate(
    df_name = "elevage",
    fn_name = "any_obs",
    attrib_name = glue::glue("produit_{attrib_name}")
  ) |>
	dplyr::select(attrib_name, fn_name, df_name, condition, attrib_vars)

attribs_produits_animaliers <- purrr::pmap(
  .l = produits_animaliers_specs,
  .f = create_attribute_from_spec
)

# =============================================================================
# [18A] PÊCHE
# =============================================================================

attrib_pratique_peche <- susoreview::create_attribute(
  df = menages,
  condition = s18aq01 == 1,
  attrib_name = "pratique_peche",
  attrib_vars = "s18aq01"
)

attrib_peche_poissons <- susoreview::any_vars(
  df = menages,
  var_pattern = "s18aq14__|s18aq20__",
  var_val = 1,
  attrib_name = "peche_poisson_fruit_de_mer_frais"
)

# =============================================================================
# [18B] CHASSE
# =============================================================================

# pratique la chasse
attrib_pratique_chasse <- susoreview::create_attribute(
  df = menages,
  condition = s18bq01 == 1,
  attrib_name = "pratique_chasse",
  attrib_vars = "s18bq01"
)

# utilise un fusil pour chasser
attrib_utiliser_fusil <- susoreview::create_attribute(
  df = menages,
  # 1 = fusil de chasse, 2 = fusil tradittionel, 3 = fusil et piège
  condition = s18bq03 %in% c(1, 2, 4),
  attrib_name = "utiliser_fusil_pour_chasse",
  attrib_vars = "s18bq03"
)

attrib_chasse_gibier <- susoreview::any_vars(
  df = menages,
  var_pattern = "s18bq13__",
  var_val = 1,
  attrib_name = "chasse_gibier"
)

# =============================================================================
# [18C] CUEILLETTE
# =============================================================================

# pratique la cueillette
attrib_pratique_chasse <- susoreview::create_attribute(
  df = menages,
  condition = s18cq00a == 1,
  attrib_name = "pratique_cueillette",
  attrib_vars = "s18cq00a"
)

# produits cueillis
cueillette_specs <- tibble::tribble(
  ~ attrib_name, ~ condition,
  "chenille", "6",
  "escargot", "7",
  "miel", "9",
) |>
	dplyr::mutate(
    df_name = "menages",
    fn_name = "create_attribute",
    attrib_name = glue::glue("ramasse_{attrib_name}"),
    condition = glue::glue("s18cq01__{condition} == 1"),
    attrib_vars = "s18cq01"
  ) |>
	dplyr::select(attrib_name, fn_name, df_name, condition, attrib_vars)

attribs_conso_propre_prod_cueillir <- purrr::pmap(
  .l = cueillette_specs,
  .f = create_attribute_from_spec
)

# pratique l'apiculture (cherche du miel)
attrib_pratique_apiculture <- susoreview::create_attribute(
  df = menages,
  condition = s18cq01__9 == 1,
  attrib_name = "pratique_apiculture",
  attrib_vars = "s18cq01"
)

# =============================================================================
# [19] EQUIPEMENTS AGRICOLES
# =============================================================================

equip_peche <- c(
  129, # Pirogue motorisée
  130, # Pirogue non-motorisée
  131, # Filet maillant
  132, # Senne
  133, # Epervier
  134, # Palangre à Hameçon
  135 # Harpon
) |>
	paste(collapse = ", ") |>
  (\(x) paste0("c(", x, ")"))()

equip_agric <- c(
  101, # Tracteur
  102, # Pulvériseur
  103, # Motoculteur
  104, # Multiculteur
  105, # Charrue
  107, # Houe/daba/hilaire
  109, # Houe asine
  110, # Semoir
  111, # Herse
  112, # Animaux de labour
  115, # Décortiqueuse à riz
  116, # Egreneuse à maïs
  117, # Batteuse
  118, # Groupe moto pompe
  119, # Pompe manuelle
  126 # Epandeur d'engrais
) |>
	paste(collapse = ", ") |>
  (\(x) paste0("c(", x, ")"))()

equip_elevage <- c(
  121, # Botteleuse
  122, # Hache-Paille
  123, # Abreuvoir / Mangeoire
  127, # Machine à traire
  128 # Couveuse
) |>
	paste(collapse = ", ") |>
  (\(x) paste0("c(", x, ")"))()

equipements_agric_specs <- tibble::tribble(
  ~ attrib_name, ~ condition,
  "peche", equip_peche,
  "agric", equip_agric,
  "elevage", equip_elevage,
  "apiculture", "c(114)",
) |>
	dplyr::mutate(
    attrib_name = glue::glue("possede_equipement_{attrib_name}"),
    fn_name = "any_obs",
    df_name = "equipements",
    condition = glue::glue("s19q03 == 1 & equipements__id %in% {condition}"),
    attrib_vars = "s19q03"
  ) |>
	dplyr::select(attrib_name, fn_name, df_name, condition, attrib_vars)

attribs_equipement_agricole <- purrr::pmap(
  .l = equipements_agric_specs,
  .f = create_attribute_from_spec
)

# =============================================================================
# Fusionner les attributs
# =============================================================================

# ------------------------------------------------------------------------------
# transformer les objets `attribs_*` de liste de df en df
# ------------------------------------------------------------------------------

# obtenir le nom des attributs
objets_attribs <- base::ls(pattern = "^attribs_")

# remplacer la valeur de l'objet avec un df qui rassemble les dfs de la liste
# appliquant une fonction à chaque objet
purrr::walk(
  .x = objets_attribs,
  .f = \(nom) {

    # obtenir la valeur de l'objet du nom `nom`
    liste_df <- base::get(x = nom)

    # transformer la liste de df en un seul df
    # si la liste est composée d'un seul élément `get()` produit un simple df
    if ("list" %in% class(liste_df)) {
      df <- purrr::list_rbind(x = liste_df)
    # dans tous les autres cas, `get()` produit une liste de dfs
    } else if ("data.frame" %in% class(liste_df)) {
      df <- liste_df
    }

    # affecter la nouvells valeur au nom d'objet initial
    assign(
      x = nom,
      value = df,
      envir = rlang::global_env()
    )
  }
)

# ------------------------------------------------------------------------------
# mettre ensemble toutes les bases
# ------------------------------------------------------------------------------

# composer l'expression régulière pour viser les deux types d'objet
objets_rexpr <- c(
 "^attribs_", # objets anciennement des listes de dfs
 "^attrib_" # objets simple . df
) |>
	paste(collapse = "|")

# mettre ensemble, en une seule basem tout les qttributs
attribs <- dplyr::bind_rows(mget(ls(pattern = objets_rexpr)))

# ------------------------------------------------------------------------------
# nettoyer l'environnement en supprimant les objets intermédiaires
# ------------------------------------------------------------------------------

rm(list = ls(pattern = objets_rexpr))
