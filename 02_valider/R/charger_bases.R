#' Charger les observations à valider pour une base donnée
#'
#' @description
#' Constuire une base qui :
#' - Contient toutes les observations à passer en revue
#' - Exclut toutes les autres observations
#'
#' @param dir Character. Répertoire où trouver la base
#' @param base Character. Nom de la base, sans extension `.dta`
#' @param nom Character. Nom à affecter à la base dans l'environment global.
#' @param entretiens_a_valider Data frame. Base des entretiens à traiter.
#'
#' @return Effet secondaire de peupler l'environment d'une base du nom fourni.
#'
#' @importFrom fs path
#' @importFrom haven read_dta
#' @importFrom dplyr select left_join
#' @importFrom rlang global_env
charger_base_filtree <- function(
  dir,
  base,
  nom,
  entretiens_a_valider
) {

  # ingérer la base brute
  df <- fs::path(dir, glue::glue("{base}.dta")) |>
    haven::read_dta()

  # si la base contient `interview__status`, supprimer cette variable
  df <- df |>
    (\(x) {
      if ("interview__status" %in% base::names(x)) {
        dplyr::select(x, -interview__status)
      } else {
        x
      }
    })()

  # ne retenir que les observations à passer en revue
  # construisant la base filtrée sur les `entretiens_a_valider` de sorte à
  # avoir ces observations dans chaque base
  # et ainsi garantir un valeur d'indicateur pour l'observation
  df_filtered <- entretiens_a_valider |>
    dplyr::left_join(
      df,
      by = c("interview__id", "interview__key")
    )

  # attribuer la base à un nom dans l'environnement global
  base::assign(
    x = nom,
    value = df_filtered,
    envir = rlang::global_env()
  )

}
