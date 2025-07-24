# ==============================================================================
# ERREURS
# ==============================================================================

issue_aucun_chef <- susoreview::create_issue(
  df = attribs,
  vars = "n_chefs",
  where = n_chefs == 0,
  type = 1,
  desc = "Aucun chef de ménage",
  comment = ""
)

issue_aucun_chef <- susoreview::create_issue(
  df = attribs,
  vars = "n_chefs",
  where = n_chefs > 1,
  type = 1,
  desc = "Trop de chefs de ménage",
  comment = ""
)

# ==============================================================================
# INCOHÉRENCES
# ==============================================================================

# ------------------------------------------------------------------------------
# emploi du membre et activité économique du ménage
# ------------------------------------------------------------------------------

# travaille dans "l'agric" sans que le ménage pratique "l'agric"
# (i.e., l'agriculture, l'élèvage, la pêche, ou la chasse)
issue_travail_agric_sans_pratiquer <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c(
    "travaille_agric_elevage_peche_ou_chasse",
    "pratique_agric", "pratique_peche", "pratique_peche"
  ),
  where =
    travaille_agric_elevage_peche_ou_chasse == 1 &
    (pratique_agric == 1 | pratique_peche == 1 | pratique_peche),
  type = 1,
  desc = "",
  comment = ""
)

# travaille dans un commerce sans que le ménage ait une entreprise
issue_travail_biz_sans_biz <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("travaille_entreprise", "possede_entreprise"),
  where = travaille_entreprise == 1 & possede_entreprise == 0,
  type = 1,
  desc = "",
  comment = ""
)

# travaille dans l'agriculture familiale sans pratique l'agriculture
issue_travail_agric_sans_agric <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("travaille_agric_familiale", "pratique_agric"),
  where = travaille_agric_familiale == 1 & pratique_agric == 0,
  type = 1,
  desc = "",
  comment = ""
)

# ------------------------------------------------------------------------------
# éducation et autres activités / attributs
# ------------------------------------------------------------------------------

# abandonner sa scolarité pour un emploi sans travailler
issue_abandon_educ_pour_emploi_lvl_membre <- susoreview::make_issue_in_roster(
  df = membres,
  where = s02q12 == 1 & !(s04q15 == 1 | s04q17 == 1),
  roster_vars = "membres__id",
  type = 2,
  desc = "Membre a abandonné l'éduc pour l'emploi, sans avoir l'emploi",
  comment = paste(
    "Ce membre a abandonné sa scolarité en raison d'un emploi mais ne travaille pas.",
    "Veuillez résoudre ou expliquer ce conflit.",
    "Dans s02q12, il déclare abandonner l'école après avoir obtenu un emploi.",
    "Mais dans le module 4A, il déclare n'avoir pas travaillé",
    "ou n'avoir pas un emploi à exercer même s'il n'a pas travaillé dans les",
    "7 derniers jours",
    "Veuillez corriger ou expliquer cette incohérence."
  ),
  issue_vars = "s02q12|s04q15|s04q17"
)

issue_abandon_educ_pour_emploi_lvl_menage <-
  issue_abandon_educ_pour_emploi_lvl_membre |>
    dplyr::mutate(
      issue_type = 1,
      issue_loc = NA_character_
    ) |>
    # ne retenir qu'une observation par entretien
    dplyr::distinct(.keep_all = TRUE) |>
    dplyr::mutate(
      issue_desc = sub(
        x = issue_desc,
        pattern = "Membre",
        replacement = "Au moins un membre"
      ),
      issue_comment = sub(
        x = issue_comment,
        pattern = "Ce membre",
        replacement = "Au moins un membre"
      )
    )

# - Si l'on a atteint le secondaire, on sait lire et écrire
# - Si l'on a atteint le post-secondaire, on sait lire et écrire

# ------------------------------------------------------------------------------
# subtient à ces besoins par une source de revenu; revenu n'existe pas
# ------------------------------------------------------------------------------

# vit d'une pension sans déclarer un revenu de pension

# vit de ses récoltes sans pratiquer l'agriculture
issue_vit_recoltes_sans_agric <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("subvient_recolte", "pratique_agric"),
  where = subvient_recolte == 1 & pratique_agric == 0,
  type = 1,
  desc = "",
  comment = ""
)

# vit de transfert de vivres gratuits, sqns transfert ni filet de sécurité
issue_vit_vivres_gratuit_sans_recevoir <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("subvient_vivres_gratuits", "transfert_recu", "beneficie_filet_securite"),
  where = 
    (subvient_vivres_gratuits == 1) &
    (transfert_recu == 0 & beneficie_filet_securite == 0),
  type = 1,
  desc = "",
  comment = ""
)

# ------------------------------------------------------------------------------
# prêt pour une activité; activité pas exercée
# ------------------------------------------------------------------------------

# éducation, sans qu'aucun membre ne fréquente l'école
issue_pret_educ_sans_ecole <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("utiliser_pret_educ", "frequenter_ecole"),
  where = utiliser_pret_educ == 1 & frequenter_ecole == 0,
  type = 1,
  desc = "",
  comment = ""
)

# acquisition de véhicule sans posséder de véhicule
issue_pret_vehicule_sans_vehicule <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("utiliser_pret_vehicule", "possede_vehicule"),
  where = utiliser_pret_vehicule == 1 & possede_vehicule == 0,
  type = 1,
  desc = "",
  comment = ""
)

# acheter des biens/équipements du ménage sans les posséder
issue_pret_articles_menagers_sans_posseder <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("utiliser_pret_biens_menagers",  "possede_biens_equipements_menage"),
  where = utiliser_pret_biens_menagers == 1 & possede_biens_equipements_menage == 0,
  type = 1,
  desc = "",
  comment = ""
)

# financer une entreprise sans déclarer une entreprise
issue_pret_biz_sans_biz <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("utiliser_pret_biz", "possede_entreprise"),
  where = utiliser_pret_biz == 1 & possede_entreprise == 0,
  type = 1,
  desc = "",
  comment = ""
)

# acheter des intrants "agricoles" sans pratiquer "l'agriculture"
issue_pret_intrants_agric_sans_agric <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("utiliser_pret_intrants", "pratique_agric"),
  where = utiliser_pret_intrants == 1 & pratique_agric == 0,
  type = 1,
  desc = "",
  comment = ""
)

# ------------------------------------------------------------------------------
# services ou biens électriques sans accès à l'électricité 
# ------------------------------------------------------------------------------

# utilise la clim sans accès à l'électricité
issue_utiliser_clim_sans_elec <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("logement_climatiseur", "access_electricite"),
  where = logement_climatiseur == 1 & access_electricite == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] Clim (s11q03a) sans accès à l'électricité (s11q32 %in% c(1, 2, 3))
)

# utilise un ventilateur sans accès à l'électricité
issue_utiliser_ventilateur_sans_elec <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("logement_ventilateur", "access_electricite"),
  where = logement_ventilateur == 1 & access_electricite == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] Ventilateur (s11q03a) sans accès à l'électricité (s11q32 %in% c(1, 2, 3))
)

# utilise l'éclairage électrique sans accès à l'électricité 
issue_utiliser_elec_eclairage_sans_elec <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("utiliser_elec_eclairer", "access_electricite"),
  where = utiliser_elec_eclairer == 1 & access_electricite == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] Source d'éclairage = électricité (s11q36 == 1), sans accès à l'éléctricité (s11q32 %in% c(1, 2, 3))
)

# possède des biens électriques sans accès à l'électricité 
issue_posseder_biens_elec_sans_elec <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("possede_biens_elec", "access_electricite"),
  where = possede_biens_elec == 1 & access_electricite == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] Possède des biens électriques (s12q02) sans accès à l'électricité (s11q32 %in% c(1, 2, 3))
)

# utilise l'électrique pour cuisiner sans accès à l'électricité 
issue_utiliser_elec_cuisiner_sans_elec <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("utiliser_elec_cuisiner", "access_electricite"),
  where = utiliser_elec_cuisiner == 1 & access_electricite == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] Électricité est la principale source d'énergie pour la cuisine (s11q43 == 2) sans accès à l'électricité (s11q32 %in% c(1, 2, 3))
)

# ------------------------------------------------------------------------------
# utiliser un bien sans le posséder
# ------------------------------------------------------------------------------

# groupe électrogène
issue_utiliser_groupe_elec_sans_posseder <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("utiliser_groupe_pendant_panne", "possede_groupe_elec"),
  where = utiliser_groupe_pendant_panne == 1 & possede_groupe_elec == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] Utilise un groupe électrogène en cas de coupure (s11q41 == 1) sans posséder de groupe (s12q02 == 827)
)

# fusil de chasse
issue_utiliser_fusil_sans_posseder <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("utiliser_fusil_pour_chasse", "possede_fusil"),
  where = utiliser_fusil_pour_chasse == 1 & possede_fusil == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] Si l'on chasse avec un fusil de chasse ((18B.03) %in% c(1, 2, 4)), il est fort probable que l'on possède un fusil ((12.02) == 1 pour la ligne 840)
)

# ------------------------------------------------------------------------------
# utilisation internet <=> accès internet
# ------------------------------------------------------------------------------

# membre connecté à l'internet sans que la maison le soit
issue_membre_internet_sans_connexion_menage <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("access_internet_menage_ou_portable", "logement_internet"),
  where = access_internet_menage_ou_portable == 1 & logement_internet == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] Au moins une personne est connecté à l'internet à la maison ou sur son téléphone portable (s01q43) sans que le ménage soit connecté (s11q50)
)

# la maison est connectée à l'internet sans qu'aucun membre ne le soit
issue_internet_maison_sans_membre_connecte <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("logement_internet", "access_internet_menage_ou_portable"),
  where = logement_internet == 1 & access_internet_menage_ou_portable == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] Le ménage est connecté à l'internet (s11q50) sans qu'aucun membre le soit (s01q43)
)

# ------------------------------------------------------------------------------
# stratégie de faire face à un choc => une action dans un autre module
# ------------------------------------------------------------------------------

# faire face grâce à l'aide d'un prôche, sans recevoir de transfert
issue_choc_aide_proche_sans_transfert <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("choc_strategie_aide_proches", "transfert_recu"),
  where = choc_strategie_aide_proches == 1 & transfert_recu == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] 2. Aide de parents ou d'amis, mais transfert (s13q09)
)

# faire face grâce à l'aide du gouvernement, sans bénéficier d'un filet de séc
issue_choc_aide_gouv_sans_filet_sec <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("choc_strategie_aide_gouv", "beneficie_filet_securite"),
  where = choc_strategie_aide_gouv == 1 & beneficie_filet_securite == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] 3. Aide du gouvernement/l'Etat, mais aucun filet de sécurité déclaré (15.02)
)

# faire face en quittant l'école, mais sans quitter
issue_choc_descolariser_sans_quitter_ecole <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("choc_strategie_descolarise", "abandonner_educ"),
  where = choc_strategie_descolarise == 1 & abandonner_educ == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] 11. Les enfants ont été déscolarisés, sans déscolarisation déclarée (module 2)
)

# faire face en obtenant un crédit, mais sans crédit
issue_choc_demander_credit_sans_credit <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("choc_strategie_credit", "demander_credit"),
  where = choc_strategie_credit == 1 & demander_credit == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] 15. Obtention d'un crédit, sans prêt déclaré (module financier)
)

# faire face en vendant du bétail, mais sans vendre
issue_choc_vendre_betail_sans_vendre <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("choc_strategie_vente_betail", "vente_betail"),
  where = choc_strategie_vente_betail == 1 & vente_betail == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] 22.Vente de bétail, sans vente déclarée (module élevage)
)

# ------------------------------------------------------------------------------
# filets de sécurité devrait résulter en dépenses ailleurs
# ------------------------------------------------------------------------------

# bénéficie d'une assistance scolaire sans bourse/allocation déclarée
issue_filet_educ_sans_bourse <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("beneficie_assistance_educ", "bourse_educ"),
  where = beneficie_assistance_educ == 1 & bourse_educ == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] Assistance education (15.05 == 1, ligne 15) sans dépense scolaire ni de bourse (module éducation)
)

# bénéficie d'une assistance carburant sans dépenses de carburant
issue_filet_carburant_sans_depense_carburant <- susoreview::create_issue(
  df_attribs = attribs,
  vars = c("beneficie_assistance_carburant", "depense_carburant_7d"),
  where = beneficie_assistance_carburant == 1 & depense_carburant_7d == 0,
  type = 1,
  desc = "",
  comment = ""
  # - [aa] Assistance carburant (15.05 == 1, ligne 19) sans dépense en carburant (dépense non-alimentaire)
)

# ------------------------------------------------------------------------------
# utilisation d'intrant déclaré globale sans être enregistrée sur une parcelle
# ------------------------------------------------------------------------------

semences_pattern <- c(
  "petit_mil",
  "sorgho",
  "mais",
  "riz",
  "coton",
  "sesame",
  "haricots",
  "arachides",
  "teck",
  "cafe",
  "cacao"
) |>
  paste(collapse = "|") |>
	(\(x) {
    paste0("(", x, ")$")
  })()

utilisation_intrant_globale_parcelle_spec <- tibble::tribble(
  ~ var1, ~ var2, ~ produit,
  # engrais
  "utiliser_uree", "appliquer_uree", "urée",
  "utiliser_phosphates", "appliquer_phosphates", "phosphates",
  "utiliser_npk",  "appliquer_npk", "NPG",
  "utiliser_super_simple", "appliquer_super_simple", "super simple",
  "utiliser_super_triple", "appliquer_super_triple", "super triple",
  "utiliser_autre_engrais_chimique", "appliquer_autre_engrais_chimique", "autre engrais chimique",
  # produits phytosanitaires
  "utiliser_pesticides", "appliquer_pesticides", "pesticides",
  "utiliser_herbicides", "appliquer_herbicides", "herbicides",
  "utiliser_fongicides", "appliquer_fongicides", "fongicides",
  "utiliser_autres_prod_phytosanitaires", "appliquer_autres_prod_phytosanitaires", "autres produits phytosanitaires",
  # semences
  "utiliser_petit_mil", "cultiver_petit_mil", "petit mil",
  "utiliser_sorgho", "cultiver_sorgho", "sorgho",
  "utiliser_mais", "cultiver_mais", "maïs",
  "utiliser_riz", "cultiver_riz", "riz",
  "utiliser_coton", "cultiver_coton", "coton",
  "utiliser_sesame", "cultiver_sesame", "sésame",
  "utiliser_haricots", "cultiver_haricots", "haricots",
  "utiliser_arachides", "cultiver_arachides", "arachides",
  "utiliser_hevea_teck", "cultiver_hevea_teck", "hévea/teck",
  "utiliser_cafe", "cultiver_cafe", "café",
  "utiliser_cacao", "cultiver_cacao", "cacao",
) |>
	dplyr::mutate(
    verbe = dplyr::if_else(
      condition = stringr::str_detect(
        string = var1,
        pattern = semences_pattern,
      ),
      true = "cultiv",
      false = "utilis"
    ),
    module = dplyr::if_else(
      condition = stringr::str_detect(
        string = var1,
        pattern = semences_pattern,
      ),
      true = "C",
      false = "A"
    )
  )


issues_intrants_global_sans_utiliser_parcelle <- purrr::pmap(
  .l = utilisation_intrant_globale_parcelle_spec,
  .f = ~ susoreview::create_issue(
    df_attribs = attribs,
    vars = c(..1, ..2),
    where = !!rlang::sym(..1) == 1 & !!rlang::sym(..2) == 0,
    type = 1,
    desc = glue::glue(
      "{..3} utilisé dans 16B sans être {..4}é sur une parcelle dans 16{..5}."
    ),
    comment = glue::glue(
      "ERREUR: {..3} utilisé sans être {..4}é sur une parcelle",
      "Dans le module 16B, le ménage dit avoir utilisé {..3}",
      "mais aucune parcelle dans le module 16{..5} ne voit son {..4}ation.",
      "Veuillez corriger ou expliquer cette incohérence.",
      .sep = " "
    )
  )
) |>
	purrr::list_rbind()


issues_intrants_utiliser_parcelle_sans_global <- purrr::pmap(
  .l = utilisation_intrant_globale_parcelle_spec,
  .f = ~ susoreview::create_issue(
    df_attribs = attribs,
    vars = c(..2, ..1),
    where = !!rlang::sym(..2) == 1 & !!rlang::sym(..1) == 0,
    type = 1,
    desc = glue::glue(
      "{..3} {..4}é dans 16B sans être utilisé sur une parcelle dans 16{..5}."
    ),
    comment = glue::glue(
      "ERREUR: {..3} utilisé sans être {..4}é sur une parcelle",
      "Dans le module 16{..5}, {..3} est {..4}é sur au moins une parcelle",
      "mais n'est pas déclaré comme étant utilisé dans le module 16C",
      "Veuillez corriger ou expliquer cette incohérence.",
      .sep = " "
    )
  )
) |>
	purrr::list_rbind()

# ------------------------------------------------------------------------------
# consommation une culture de propre production => production agricole
# ------------------------------------------------------------------------------

propre_conso_sans_cultiver_specs <- tibble::tribble(
  ~ var,
  # céréales
  "riz",
  "mais",
  "mil",
  "sorgho",
  "ble",
  "fonio",
  # fruits
  "mangues",
  "ananas",
  "banane_douce",
  "goyave",
  "noix_de_coco",
  "canne_a_sucre",
  "orange",
  "citron",
  # légumes
  "choux",
  "carotte",
  "haricot_vert",
  "concombre",
  "aubergine",
  "courge",
  "poivron",
  "tomate_fraiche",
  "gombo",
  "oignon",
  # légumineuses et tubercules
  "petits_pois",
  "niebe",
  "soja",
  "arachides",
  "sesame",
  "noix_cajou",
  "manioc",
  "igname",
  "plantain",
  "patate_douce",
  "pomme_de_terre",
  "taro",
  "souchet",
  # épices et condiments
  "ail",
  "gingembre",
) |>
	dplyr::mutate(
    # remplacer le tiret-bas par un espace
    nom = gsub(
      x = var,
      pattern = "_",
      replacement = " "
    ),
    # mettre les voyelles françaises
    nom = dplyr::case_when(
      grepl(x = nom, pattern = "ble$") ~
        sub(x = nom, pattern = "e", "é"),
      grepl(x = nom, pattern = "canne a") ~
        sub(x = nom, pattern = " a ", " à "),
      grepl(x = nom, pattern = "fraiche") ~
        sub(x = nom, pattern = "i", "î"),
      grepl(x = nom, pattern = "niebe") ~
        gsub(x = nom, pattern = "e", "é"),
      grepl(x = nom, pattern = "sesame") ~
        sub(x = nom, pattern = "e", "é"),
      grepl(x = nom, pattern = "noix cajou") ~
        sub(x = nom, pattern = "noix cajou", replacement = "noix de cajou"),
      .default = nom
    )
  )

issues_conso_propre_prod_sans_cultiver <- purrr::pmap(
  .l = propre_conso_sans_cultiver_specs,
  .f = ~ susoreview::create_issue(
    df_attribs = attribs,
    vars = c(
      glue::glue("cons_propre_prod_{..1}"),
      glue::glue("cultive_{..1}")
    ),
    where = 
      !!rlang::sym(glue::glue("cons_propre_prod_{..1}")) == 1 &
      !!rlang::sym(glue::glue("cultive_{..1}")) == 0,
    desc = "{..2} consommé de sa propre production sans être cultivé",
    comment = glue::glue(
      "ERREUR: {..2} consommé de sa propre production sans être cultivé",
      "Dans le module 7B, on dit avoir consommé {..2} de sa propre production.",
      "Or, dans le module 16C, {..2} n'est cultivé sur aucune parcelle.",
      "Veuillez corriger ou expliquer cet contradiction."
    )
  )
) |>
	purrr::list_rbind()

# ------------------------------------------------------------------------------
# consommation d'un produit animal de propre production => élevage
# ------------------------------------------------------------------------------

propre_conso_sans_elevage_specs <- tibble::tribble(
  ~ var,
  # viandes
  "boeuf",
  "mouton",
  "chevre",
  "chameau",
  "porc",
  "lapin",
  "poulet",
  "autre_volailles",
) |>
	dplyr::mutate(
    # remplacer le tiret-bas par un espace
    nom = gsub(
      x = var,
      pattern = "_",
      replacement = " "
    ),
    # mettre les voyelles françaises
    nom = dplyr::case_when(
      grepl(x = nom, pattern = "evre") ~
        sub(x = nom, pattern = "e", replacement = "è"),
      .default = nom
    ),
    action = dplyr::case_when(
      nom == "autre volailles" ~ "d'élevage d'autre volailles",
      .default = paste("d'élevage de", nom)
    )
  )

issues_conso_propre_prod_sans_elever <- purrr::pmap(
  .l = propre_conso_sans_elevage_specs,
  .f = ~ susoreview::create_issue(
    df_attribs = attribs,
    vars = c(
      glue::glue("cons_propre_prod_{..1}"),
      glue::glue("produit_viande_{..1}")
    ),
    where = 
      !!rlang::sym(glue::glue("cons_propre_prod_{..1}")) == 1 &
      !!rlang::sym(glue::glue("produit_viande_{..1}")) == 0,
    desc = "{..2} consommé de sa propre production sans élevage",
    comment = glue::glue(
      "ERREUR: {..2} consommé de sa propre production sans être cultivé",
      "Dans le module 7B, on dit avoir consommé {..2} de sa propre production.",
      "Or, dans le module 17, il n'y a pas {..3}.",
      "Veuillez corriger ou expliquer cet contradiction."
    )
  )
) |>
	purrr::list_rbind()

# ------------------------------------------------------------------------------
# consommation de sa propre production => pêche, chasse, ou cueillette
# ------------------------------------------------------------------------------

propre_conso_sans_peche_chasse_ou_cueillette_specs <- tibble::tribble(
  ~ var, ~ prod_module, ~ prefix,
  # lait et oeufs
  "lait", "17", "produit",
  "oeufs", "17", "produit",
  # poisson
  "poisson_fruit_de_mer_frais", "18A", "peche",
  "chenille", "18C", "ramasse",
  "escargot", "18C", "ramasse",
  # sucreries
  "miel", "18C", "ramasse",
  "gibier", "18B", "chasse",
) |>
	dplyr::mutate(
    # remplacer le tiret-bas par un espace
    nom = gsub(
      x = var,
      pattern = "_",
      replacement = " "
    ),
    action = dplyr::case_when(
      var %in% c("lait", "oeufs") ~
        "produit par les animaux",
      var == "poisson_fruit_de_mer_frais" ~ "pêché",
      var == "gibier" ~ "chassé",
      .default = "cuelli"
    )
  )

issues_conso_propre_prod_sans_pecher_chasser_cueillir <- purrr::pmap(
  .l = propre_conso_sans_peche_chasse_ou_cueillette_specs,
  .f = ~ susoreview::create_issue(
    df_attribs = attribs,
    vars = c(
      glue::glue("cons_propre_prod_{..1}"),
      glue::glue("{..3}_{..1}")
    ),
    where = 
      !!rlang::sym(glue::glue("cons_propre_prod_{..1}")) == 1 &
      !!rlang::sym(glue::glue("{..3}_{..1}")) == 0,
    desc = "{..4} consommé de sa propre production sans être {..5}",
    comment = glue::glue(
      "ERREUR: {..4} consommé de sa propre production sans être cultivé",
      "Dans le module 7B, on dit avoir consommé {..2} de sa propre production.",
      "Or, dans le module {..2}, {..4} n'a été {..5}.",
      "Veuillez corriger ou expliquer cet contradiction."
    )
  )
) |>
	purrr::list_rbind()

# ------------------------------------------------------------------------------
# posséder des équipements d'activité agric => pratiquer l'activité
# ------------------------------------------------------------------------------

equipements_agric_spec <- tibble::tribble(
  ~ attrib, ~ module, ~ nom, ~ desc,
  "agric", "16A", "l'agriculture", "cultive des parcelles agricoles",
  "elevage", "17", "l'élevage", "éleve des animaux",
  "peche", "18A", "la pêche", "pêche dans la mer ou des fleuves",
  "apiculture", "18C", "l'apiculture", "chercher du miel",
)

issue_equipement_agric_sans_pratiquer <- purrr::pmap(
  .l = equipements_agric_spec,
  .f = ~ susoreview::create_issue(
    df_attribs = attribs,
    vars = c(
      "possede_equipement_{..1}",
      "pratique_{..1}"
    ),
    where =
      !!rlang::sym(glue::glue("possede_equipement_{..1}")) == 1 &
      !!rlang(glue::glue("pratique_{..1}")) == 0,
    desc = "Possède des équipements de {..3} sans pratiquer {..3}",
    comment = glue::glue(
      "ERREUR: Possède des équipements de {..3} sans pratiquer {..3}",
      "Dans le module 19, le ménage déclare posséder des équipements de {..3}",
      "Or dans le module {..2}, on dit ne pas pratiquer {..3}",
      "C'est à dire, le ménage déclare ne pas {..4}",
      .sep = " "
    )
  )
) |>
	purrr::list_rbind()

# ------------------------------------------------------------------------------
# culture principale doit être les cultures cultivées
# ------------------------------------------------------------------------------

culture_principale <- parcelles |>
	dplyr::select(
    interview__id, interview__key, champs__id, parcelles__id,
    s16Aq08
  )

cultures <- parcelles |>
	dplyr::select(
    interview__id, interview__key, champs__id, parcelles__id,
    dplyr::starts_with("s16Cq05__")
  ) |>
	tidyr::pivot_longer(
    cols = dplyr::starts_with("s16Cq05__"),
    names_pattern = "s16Cq05__([0-9]+)",
    names_to = "crop",
    values_to = "planted"
  ) |>
	dplyr::filter(planted == 1) |>
	dplyr::select(
    interview__id, interview__key, champs__id, parcelles__id,
    crop
  ) |>
  dplyr::mutate(crop = as.numeric(crop))

issue_culture_principale_absente <- culture_principale |>
	dplyr::anti_join(
    cultures,
    by = dplyr::join_by(
      interview__id, interview__key, champs__id, parcelles__id,
      s16Aq08 == crop
    )
  ) |>
	dplyr::filter(!is.na(s16Aq08)) |>
  dplyr::mutate(
    issue_type = 2,
    issue_desc = "",
    issue_comment = "",
    issue_vars = "s16Aq08|s16Aq08"
  ) |>
	dplyr::rowwise(interview__id, interview__key, champs__id, parcelles__id) |>
	dplyr::mutate(issue_loc = glue::glue("[{champs__id}, {parcelles__id}]")) |>
	dplyr::ungroup() |>
	dplyr::select(
    interview__id, interview__key,
    issue_type,
    issue_desc,
    issue_comment,
    issue_vars
  )
	

# ==============================================================================
# VALEURS EXTRÊMES
# ==============================================================================

# ==============================================================================
# [2]	EDUCATION (INDIVIDUS AGES DE 3 ANS ET PLUS)
# ==============================================================================

depenses_educ_specs <- tibble::tribble(
  ~ var, ~ desc,
  "s02q21", "frais de scolarité",
  "s02q22", "cotisations",
  "s02q23", "livres",
  "s02q24", "cahiers et autres matériels scolaires",
  "s02q25", "uniformes",
  "s02q26", "cantine scolaire + restauration",
  "s02q27", "transport scolaire",
  "s02q28", "autres déponses scolaires",
  "s02q29", "bourse/allocation",
)

issue_depenses_educ <- purrr::pmap(
  .l = depenses_educ_specs,
  .f = ~ identify_outliers(
    df = membres,
    var = !!rlang::sym(..1),
    type = 2,
    desc = glue::glue("Valeur extrême pour {..2}"),
    comment = paste(
      glue::glue("Valeur extrême identifée pour {..2}."),
      glue::glue("La valeur de {..1}"),
      "({.data[[var_chr]]}) s'écarte de la norme.",
      "Veuillez vérier la justesse de la valeur.",
      "Si la valeur est erronnée, veuillez la corriger.",
      "Si la valeur est confirmée, veuillez laisser un commentaire explicatif."
    )
  )
) |>
	purrr::list_rbind()



# TODO:
# Create issue at detailed level (type = 2)
# Use issues data to create an interview-level (type = 1)

	

# - Si l'on a obtenu un emploi (s02q12), s'attend à ce que l'on a travaillé dans les 12 derniers mois
# - Si l'on a atteint le secondaire, on sait lire et écrire
# - Si l'on a atteint le post-secondaire, on sait lire et écrire


# ==============================================================================
# [3]	SANTE GENERALE
# ==============================================================================

depenses_sante_spec <- tibble::tribble(
  ~ var, ~ desc,
  "s03q14", "consultation généraliste",
  "s03q15", "consultation spécialiste",
  "s03q16", "consultation pour un dentiste",
  "s03q16", "consultation (guerisseur tradtitionnel)",
  "s03q17", "médicamments dans les officines publiques",
  "s03q18", "examens médicaux et des soins",
  "s03q19", "médicaments traditionnels",
  "s03q20", "médicaments achetés dans les officines publiques",
  "s03q21", "médicaments achetés dans les officines privées",
  "s03q31", "verres correcteurs, monture de lunettes",
  "s03q32", "appareils médicaux thérapeutiques",
  "s03q34", "vaccination",
  "s03q35", "circoncision",
  "s03q36", "bilan de santé",
  "s03q50", "accouchement",
  "s03q53", "visite prénatale",
)

issue_depenses_sante <- purrr::pmap(
  .l = depenses_sante_spec,
  .f = ~ identify_outliers(
    df = membres,
    var = !!rlang::sym(..1),
    type = 2,
    desc = glue::glue("Valeur extrême pour {..2}"),
    comment = paste(
      glue::glue("Valeur extrême identifée pour {..2}."),
      glue::glue("La valeur de {..1}"),
      "({.data[[var_chr]]}) s'écarte de la norme.",
      "Veuillez vérier la justesse de la valeur.",
      "Si la valeur est erronnée, veuillez la corriger.",
      "Si la valeur est confirmée, veuillez laisser un commentaire explicatif."
    )
  )
) |>
	purrr::list_rbind()

# ==============================================================================
# [4]	EMPLOI (INDIVIDUS AGES DE 5 ANS ET PLUS)
# ==============================================================================

## B  Emploi Principal au cours des 12 derniers mois

# - Valeurs extremes par période
#   - [ ] Bénéfice (s04q49)
#   - [ ] Salaire net (s04q51)
#   - [ ] Etc

## C  Emploi Secondaire au cours des 12 derniers mois

# - Valeurs extremes par période
#   - [ ] Bénéfice 
#   - [ ] Salaire net 
#   - [ ] Etc

# 5	REVENUS HORS EMPLOI AU COURS DES 12 DERNIERS MOIS

# - Valeurs extremes par source de revenu
#   - [ ] Pension de retraite
#   - [ ] Pension de veuvage
#   - [ ] Pension d'invalidité
#   - [ ] Pension alimentaire
#   - [ ] Revenu de loyer
#   - [ ] Revenu de mobilier et financier
#   - [ ] Autres revenus

# 6	EPARGNE ET CREDIT

# - Valeurs extremes
#   - [ ] nombre de compte (s06q02)
#   - montant nominal par prêt 
#     - [ ] immobilier (s06q15)
#     - [ ] non-immobilier
#   - nombre d'échéances par prêt 
#     - [ ] immobilier (s06q16)
#     - [ ] non-immobilier

# ==============================================================================
# [7A]  Repas pris à l'extérieur du ménage au cours des 7 derniers jours
# ==============================================================================

repas_hors_menage_specs <- tibble::tribble(
  ~ var, ~ desc,
  # petit déjeuner
  "s07Aq02b", "petit déjeuner (dépense)",
  "s07Aq03b", "petit déjeuner (cadeau)",
  "s07Aq02", "petit déjeuner (dépense)",
  "s07Aq03", "petit déjeuner (cadeau)",
  # déjeuner
  "s07Aq05b", "déjeuner (dépense)",
  "s07Aq06b", "déjeuner (cadeau)",
  "s07Aq05", "déjeuner (dépense)",
  "s07Aq06", "déjeuner (cadeau)",
  # dîner
  "s07Aq08b", "dîner (dépense)",
  "s07Aq09b", "dîner (cadeau)",
  "s07Aq08", "dîner (dépense)",
  "s07Aq09", "dîner (cadeau)",
  # collation
  "s07Aq11b", "collation (dépense)",
  "s07Aq12b", "collation (cadeau)",
  "s07Aq11", "collation (dépense)",
  "s07Aq12", "collation (cadeau)",
  # boissons chaudes
  "s07Aq14b", "boissons chaudes (dépense)",
  "s07Aq15b", "boissons chaudes (cadeau)",
  "s07Aq14", "boissons chaudes (dépense)",
  "s07Aq15", "boissons chaudes (cadeau)",
  # boissons non alcoolisée
  "s07Aq17b", "boissons non alcoolisée (dépense)",
  "s07Aq18b", "boissons non alcoolisée (cadeau)",
  "s07Aq17", "boissons non alcoolisée (dépense)",
  "s07Aq18", "boissons non alcoolisée (cadeau)",
  # boissons alcoolisée
  "s07Aq20b", "boissons alcoolisée (dépense)",
  "s07Aq21b", "boissons alcoolisée (cadeau)",
  "s07Aq20", "boissons alcoolisée (dépense)",
  "s07Aq21", "boissons alcoolisée (cadeau)",
) |>
	dplyr::mutate(
    df_nom = dplyr::if_else(
      condition = grepl(x = var, pattern = "b$"),
      true = "menages",
      false = "membres"
    )
  )

issue_depenses_repos_hors_menage <- purrr::pmap(
  .l = repas_hors_menage_specs,
  .f = ~ identify_outliers(
    df = base::get(x = ..3, envir = rlang::global_env()),
    var = !!rlang::sym(..1),
    type = 2,
    desc = glue::glue("Valeur extrême pour {..2}"),
    comment = paste(
      glue::glue("Valeur extrême identifée pour {..2}."),
      glue::glue("La valeur de {..1}"),
      "({.data[[var_chr]]}) s'écarte de la norme.",
      "Veuillez vérier la justesse de la valeur.",
      "Si la valeur est erronnée, veuillez la corriger.",
      "Si la valeur est confirmée, veuillez laisser un commentaire explicatif."
    )
  )
) |>
	purrr::list_rbind()


# ==============================================================================
# [7B] Consommation alimentaire des 7 derniers jours et achat des 30 derniers jours
# ==============================================================================

# ------------------------------------------------------------------------------
# quantité totale
# ------------------------------------------------------------------------------

issue_quantite_totale_conso_alim <- identify_outliers(
  df = conso_alim_7j,
  var = s07bq03a,
  by = c(aliment__id, s07bq03b, s07bq03c),
  type = 1,
  desc = "Valeur extrême pour la quantité totale de consommation",
  comment = paste(
    "ERREUR: Valeur extrême identifée pour la quantité totale consommé de",
    "de {labelled::to_character(aliment__id)}",
    "en {labelled::to_character(s07bq03b)} ({labelled::to_character(s07bq03c)}).",
    "La valeur de {var_chr} ({.data[[var_chr]]}) s'écarte de la norme.",
    "Veuillez vérier la justesse de la valeur.",
    "Si la valeur est erronnée, veuillez la corriger.",
    "Si la valeur est confirmée, veuillez laisser un commentaire explicatif."
  ),
  comment_question = TRUE
)

# ------------------------------------------------------------------------------
# prix unitaire d'achat
# ------------------------------------------------------------------------------

# calculer le prix unitaire
conso_alim_7j_prix_unitaire <- conso_alim_7j |>
	dplyr::mutate(
    prix_unitaire = dplyr::if_else(
      condition = !is.na(s07bq08) & !is.na(s07bq07a),
      true = s07bq08 / s07bq07a,
      false = NA_real_
    )
  )

issue_prix_unitaire_conso_alim <- identify_outliers(
  df = conso_alim_7j_prix_unitaire,
  var = prix_unitaire,
  by = c(aliment__id, s07bq07b, s07bq07c),
  type = 1,
  desc = "Valeur extrême pour le prix unitaire d'achat du produit",
  comment = paste(
    "ERREUR: Valeur extrême identifée pour prix unitaire d'achat",
    "(i.e., prix / quantité) de {labelled::to_character(aliment__id)}",
    "en {labelled::to_character(s07bq07b)} ({labelled::to_character(s07bq07c)}).",
    "La valeur du prix unitaire ({.data[[var_chr]]}) s'écarte de la norme.",
    "Veuillez vérier la justesse de la valeur.",
    "Si la valeur est erronnée, veuillez la corriger.",
    "Si la valeur est confirmée, veuillez laisser un commentaire explicatif."
  )
)

# ==============================================================================
# [9A]  Dépenses des fêtes et cérémonies au cours des 12 derniers mois
# ==============================================================================

# - Valeurs extrêmes dans les dépenses
#   - [ ] Alimentation
#   - [ ] Boissons
#   - [ ] Habits, chaussures, coiffures, et bijoux
#   - [ ] Location de salles, de chaises, et autre locations
#   - [ ] Autres dépenses

# ==============================================================================
# [9B - 9F]  Dépenses non alimentaires
# ==============================================================================

conso_non_alim_specs <- tibble::tribble(
  ~ base, ~ var, ~ periode,
  "depense_7j", "s09Bq03", "7 derniers jours",
  "depense_30j", "s09Cq03", "30 derniers jours",
  "depense_3m", "s09Dq03", "3 derniers mois",
  "depense_6m", "s09Eq03", "6 derniers mois",
  "depense_12m", "s09Fq03", "12 derniers mois"
) |>
	dplyr::mutate(id = glue::glue("{base}__id"))

issue_conso_non_alim <- purrr::pmap(
  .l = conso_non_alim_specs,
  .f = ~ identify_outliers(
    df = base::get(x = ..1, envir = rlang::global_env()),
    var = !!rlang::sym(..2),
    by = !!rlang::sym(..4),
    type = 1,
    desc = "Valeur extrême pour la consommation dans les {..3}.",
    comment = paste(
      "ERREUR: Valeur extrême identifée pour la consommation de",
      "de {labelled::to_character(",
      glue::glue("{..4}"),
      ")}",
      glue::glue("dans les {..3}"),
      "La valeur de {var_chr} ({.data[[var_chr]]}) s'écarte de la norme.",
      "Veuillez vérier la justesse de la valeur.",
      "Si la valeur est erronnée, veuillez la corriger.",
      "Si la valeur est confirmée, veuillez laisser un commentaire explicatif."
    ),
    comment_question = TRUE
  )
) |>
	purrr::list_rbind()


# ==============================================================================
# [10B]  Caractéristiques des entreprises non-agricoles
# ==============================================================================

# - Valeurs extrêmes dans les dépenses par poste de dépense
#   - [ ] Locaux
#   - [ ] Valeur des machines
#   - [ ] Valeur des matériel roulant
#   - [ ] Valeur du mobilier
#   - [ ] Valeur des autres équipements
# - Valeurs extrêmes dans les transactions
#   - [ ] Revente
#   - [ ] Achat de marchandises
#   - [ ] Revente de produits transformés
#   - [ ] Achat de matière première
#   - [ ] etc

# - [ ] Revenu >= dépense des 30 derniers jours
#   - Revenu
#     - Revente (s10q46)
#     - Vente de produits transformés (s10q48)
#     - Services rendus (s10q50)
#   - Coût
#     - Marchandise pour revente (s10q47)
#     - Matières premières (s10q49)
#     - Autre consommation intermédiatre (s10q51)
#     - Loyer, eau, éléctricité, etc (s10q52)
#     - Utiliser / louer des équipements (s10q53)
#     - Autre frais et services (s10q54)

# ==============================================================================
# [11]	LOGEMENT
# ==============================================================================

# ------------------------------------------------------------------------------
# nombre de pièces
# ------------------------------------------------------------------------------

# s11q02
# - Nombre de pièces
#   - [ ] Sous une borne supérieure raisonable
#   - [ ] Pas une valeur extrême

# ------------------------------------------------------------------------------
# factures
# ------------------------------------------------------------------------------

# - Facture. Valeur n'est un point aberrant
#   - [ ] Eau courante (s11q23a ($), s11q23b (periode))
#   - [ ] Eau auprès des vendeurs d'eau (s11q25, 30 derniers jours)
#   - [ ] Éléctricité (s11q35a ($), s11q35b (periode))
#   - [ ] Internet (s11q52a ($), s11q52b (periode))
#   - [ ] Télé (s11q56a ($), s11q56b (periode))


# ==============================================================================
# 16	AGRICULTURE > B  Coût des intrants
# ==============================================================================

# - Quantité de semence utilisé (16C.10) unité de superficie doit
#   - [ ] Être raisonable pour la supérficie cultivée
#   - [ ] Ne pas être une valeur extrême

# ==============================================================================
# 16D Utilisation de la production
# ==============================================================================

# - La somme des quantités récoltés pour une culture sur toutes les parcelles est supérieure ou égale à la somme des sources d'utilisation de la culture--la somme de (16D.02), (16D.03), (16D.05), (16D.13).
# - Prix unitaire de vente n'est pas une valeur extrême (16D.18)

# TODO: revise boilerplate from ehcvm2_rejet 👇👇

# =============================================================================
# Combine all issues
# =============================================================================

obj_expr_issues <- "^issue[s]*_"

# combine all issues
issues <- dplyr::bind_rows(mget(ls(pattern = obj_expr_issues)))

# remove intermediary objects to lighten load on memory
rm(list = ls(pattern = obj_expr_issues))

# =============================================================================
# Add issues from interview metadata
# =============================================================================

# -----------------------------------------------------------------------------
# ... if questions left unanswered
# -----------------------------------------------------------------------------

# extract number of questions unanswered
# use `interview__diagnostics` file rather than request stats from API
interview_stats <- suso_diagnostics |>
    # rename to match column names from GET /api/v1/interviews/{id}/stats
    dplyr::rename(
        NotAnswered = n_questions_unanswered,
        WithComments = questions__comments,
        Invalid = entities__errors
    ) |>
    dplyr::select(
      interview__id, interview__key,
      NotAnswered, WithComments, Invalid
    )

# add error if interview completed, but questions left unanswered
# returns issues data supplemented with unanswered question issues
issues_plus_unanswered <- susoreview::add_issue_if_unanswered(
    df_cases_to_review = entretiens_a_valider,
    df_interview_stats = interview_stats,
    df_issues = issues,
    n_unanswered_ok = 0,
    issue_desc = "Questions laissés sans réponse",
    issue_comment = glue::glue(
      "ERREUR: L'entretien a été marqué comme achevé,",
      "mais {NotAnswered} questions ont été laissées sans réponse.",
      "Veuillez renseigner ces questions.",
      .sep = " "
    )
)

# -----------------------------------------------------------------------------
# ... if any SuSo errors
# -----------------------------------------------------------------------------

# add issue if there are SuSo errors
issues_plus_miss_and_suso <- susoreview::add_issues_for_suso_errors(
    df_cases_to_review = entretiens_a_valider,
    df_errors = suso_errors,
    issue_type = 3,
    df_issues = issues_plus_unanswered
)
