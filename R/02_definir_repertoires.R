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
  # ... meta
  dir_obtenir_meta <- fs::path(dir_obtenir, "donnees", "00_meta")
  dir_obtenir_equipes <- fs::path(dir_obtenir_meta, "01_composition_equipes")
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
  dir_valider <- here::here("02_valider")
  dir_valider_r <- fs::path(dir_valider, "R")
  dir_valider_sortie <- fs::path(dir_valider, "sortie")
  dir_valider_01_cas <- fs::path(dir_valider_sortie, "01_cas")
  dir_valider_02_recommandations <- fs::path(
    dir_valider_sortie,
    "02_recommandations"
  )
  dir_valider_03_decisions <- fs::path(dir_valider_sortie, "03_decisions")

  # 03 - suivre
  dir_suivre <- here::here("03_suivre")
  dir_suivre_rapport_modele <- fs::path(dir_suivre, "inst")
  dir_suivre_r <- fs::path(dir_suivre, "R")
  dir_suivre_progres <- fs::path(dir_suivre, "01_progres")
  dir_suivre_qualite <- fs::path(dir_suivre, "01_qualite")

  # ----------------------------------------------------------------------------
  # composer la liste des chemins de répertoires
  # ----------------------------------------------------------------------------

  dirs <- list(
    proj = here::here(),
    r = here::here("R"),
    obtenir = list(
      meta = list(
        equipes = dir_obtenir_equipes
      ),
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
    ),
    valider = list(
      r = dir_valider_r,
      sortie = dir_valider_sortie,
      cas = dir_valider_01_cas,
      recommandations = dir_valider_02_recommandations,
      decisions = dir_valider_03_decisions
    ),
    suivre = list(
      inst = dir_suivre_rapport_modele,
      r = dir_suivre_r,
      progres = dir_suivre_progres,
      qualite = dir_suivre_qualite
    )
  )

  return(dirs)

}

dirs <- creer_liste_repertoires()
