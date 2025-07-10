#' Construire la base de la consommation alimentaire
#'
#' @description
#' L'EHCVM3 capte les infos sur la consommation alimentaire dans 2 bases.
#' Pour plusieurs raisons, l'on a besoin d'une seule base distincte.
#' Cette fonction :
#' - Identifie les bases d'entrée
#' - Harmonise les noms de colonnes dans les bases
#' - Concatine le contenu des bases
#' - S'assure d'avoir des étiquettes de variable et de valeur
#'
#' @return Effet secondaire de sauvegarder une base unique dans
#' `01_obtenir/donnees/01_menage/03_derivees`
#'
#' @importFrom fs dir_ls path
#' @importFrom cli cli_abort
#' @importFrom rlang caller_env
#' @importFrom purrr map list_rbind
#' @importFrom haven read_dta write_dta
#' @importFrom dplyr rename_with
#' @importFrom labelled var_label set_variable_labels
construire_df_conso_alim <- function(
  dirs
) {

  chemins_df <- dirs$obtenir$menage$fusionnees |>
    # créer un vecteur de chemins afin de pouvoir ingérer les bases
    fs::dir_ls(type = "file", regexp = "conso_alim")

  if (length(chemins_df) == 0) {

    cli::cli_abort(
      message = c(
        "x" = "Aucun fichier de consommation alimentaire retrouvé",
        "i" = paste(
          "Le programme recherche des fichiers {.file conso_alim*.dta}",
          "dans le répertoire {.file dirs$obtenir$menage$fusionnees}"
        ),
        "i" = paste0(
          "Veuiller s'assurer d'avoir obtenu les données du serveur",
          "et les avoir fusionné"
        )
      ),
      call = rlang::caller_env()
    )

  }

  # liste de bases de df dont les noms de colonne sont harmonisés
  conso_df_liste <-  chemins_df |>
    # créer une liste de df afin d'opérer sur chaque élément de
    # cette liste de df
    purrr::map(.f = ~ haven::read_dta(file = .x)) |>
    # harmoniser les noms en éliminant la partie servant d'indice
    purrr::map(
      .f = ~ dplyr::rename_with(
        .data = .x,
        .fn = ~ sub(
          x = .x,
          pattern = "_[12](?=__id)|_[12]$",
          replacement = "",
          perl = TRUE
        )
      )
    )

  # étiquettes de variable
  # afin de les re-appliquer après `purrr` en laisse tomber certaines
  # produit une liste avec des noms
  # dans le format demandé par `labelled::set_variable_labels()`
  conso_var_lbls <- conso_df_liste[[1]] |>
    labelled::var_label()

  # base de données
  conso_alim <- conso_df_liste |>
    # fusionner les éléments de la liste par ligne
    # NB: cette opération laisse tomber certaines étiquettees de variable
    # mais concatine correctement les étiquettes de produit des bases
    purrr::list_rbind() |>
    # re-appliquer les étiquttes de variable afin de ne pas avoir des trous
    labelled::set_variable_labels(.labels = conso_var_lbls) |>
    # modifier le nom et l'étiquette de variable
    # afin d'être l'identifiant pour être plus parlant
    dplyr::rename(produit__id = conso_alim__id) |>
    labelled::set_value_labels(
      produit__id = "Identifiant du produit alimentaire"
    )

  # sauvegarder
  haven::write_dta(
    data = conso_alim,
    path = fs::path(dirs$obtenir$menage$derivees, "conso_alim_7j.dta")
  )

}
