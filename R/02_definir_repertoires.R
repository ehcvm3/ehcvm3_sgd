#' Créer une liste de répertoires
#'
#' @return List. Objet liste qui contient tous les chemins de répertoire.
#' 
#' @importFrom here here
#' @importFrom fs path
creer_liste_repertoires <- function() {

  # ----------------------------------------------------------------------------
  # créer les chemins de répertoires clé
  # ----------------------------------------------------------------------------

  # 01 - obtenir
  dir_obtenir <- here::here("01_obtenir")
  # ... ménage
  dir_obtenir_menage <- fs::path(dir_obtenir, "donnees", "01_menage")
  dir_obtenir_menage_telechargees <- fs::path(
    dir_obtenir_menage, "01_telechargees"
  )
  dir_obtenir_menage_fusionnees <- fs::path(dir_obtenir_menage, "02_fusionnees")
  dir_obtenir_menage_derivees <- fs::path(dir_obtenir_menage, "03_derivees")
  # ... communautaire
  dir_obtenir_communautaire <- fs::path(
    dir_obtenir, "donnees", "02_communautaire"
  )
  dir_obtenir_communautaire_telechargees <- fs::path(
    dir_obtenir_communautaire, "01_telechargees"
  )
  dir_obtenir_communautaire_fusionnees <- fs::path(
    dir_obtenir_communautaire, "02_fusionnees"
  )
  # ...
  dir_obtenir_r <- fs::path(dir_obtenir, "R")

  # 02 - valider
  dir_fusionner <- here::here("02_valider")

  # 03 - suivre
  dir_suivre <- here::here("03_suivre")
  dir_suivre_rapport_modele <- fs::path(dir_suivre, "inst")

  # ----------------------------------------------------------------------------
  # composer la liste des chemins de répertoires
  # ----------------------------------------------------------------------------

  dirs <- list(
    obtenir = list(
      menage = list(
        telechargees = dir_obtenir_menage_telechargees,
        fusionnees = dir_obtenir_menage_fusionnees,
        derivees = dir_obtenir_menage_derivees
      ),
      communautaire = list(
        telechargees = dir_obtenir_communautaire_telechargees,
        fusionnees = dir_obtenir_communautaire_fusionnees
      ),
      r = dir_obtenir_r
    )
  )

  return(dirs)

}

dirs <- creer_liste_repertoires()
