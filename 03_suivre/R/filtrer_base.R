#' Filtrer la base de microdonnées d'enquête
#'
#' @param dir Character. Répertoire où se trouve la base
#' @param base Character. Nom du ficher sans extension.
#' @param nom Character. Nom à attribuer à la base.
#' @param entretiens_acheves Data frame. Base avec les identifiants d'entretien
#' à retenir.
#'
#' @return Data frame. Base données d'enquête filtrée
#'
#' @importFrom fs path
#' @importFrom haven read_dta
#' @importFrom dplyr semi_join
filtrer_base <- function(
  dir,
  base,
  nom,
  entretiens_acheves
) {

  # ingérer la base
  df <- fs::path(dir, paste0(base, ".dta")) |>
    haven::read_dta()

  # filtrer la base pour ne retenir que les entretiens achevés
  df_filtree <- df |>
    dplyr::semi_join(
      entretiens_acheves,
      by = c("interview__id", "interview__key")
    )

  return(df_filtree)

}
