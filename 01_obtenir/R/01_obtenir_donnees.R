#' Obtenir les données du questionnaire cible
#' @description Télécharger et décomprimer les données du questionnaire cible
#'
#' @param type Character. Type de questionnaire: "menage" ou "communautaire".
#' @param qnr_expr Character. Expression régulière qui identifie les
#' questionnaires dont les données sont à télécharger.
#' @param dirs List. Liste des répertoires du projet.
#' @param server Character. URL of the target SuSo server.
#' @param workspace Character. Name (!= display name) of workspace.
#' @param user Character. Name of the admin or API users.
#' @param password Character. Password of the user above.
#'
#' @importFrom susoflows delete_in_dir download_matching unzip_to_dir
obtenir_donnees <- function(
  type,
  qnr_expr,
  dirs,
  server,
  workspace,
  user,
  password
) {

  dir_telecharger <- dirs$obtenir[[type]]$telechargees
  dir_fusionner <- dirs$obtenir[[type]]$fusionnees

  # ----------------------------------------------------------------------------
  # Purger les anciens fichiers
  # ----------------------------------------------------------------------------

  cat(paste0("Supression d'anciennes données ", type, " en cours"))

  # téléchargées
  susoflows::delete_in_dir(dir_telecharger)
  # fusionnées
  susoflows::delete_in_dir(dir_fusionner)

  # ----------------------------------------------------------------------------
  # Télécharger les données en archive(s) zip
  # ----------------------------------------------------------------------------

  cat(paste0("Téléchargement de données ", type, " en cours"))

  susoflows::download_matching(
    matches = qnr_expr,
    export_type = "STATA",
    path = dir_telecharger,
    server = serveur,
    workspace = espace_travail,
    user = utilisateur,
    password = mot_de_passe
  )

  # ----------------------------------------------------------------------------
  # Décomprimer archive(s) zip
  # ----------------------------------------------------------------------------

  cat(paste0("Décompression de données ", type, " en cours"))

  susoflows::unzip_to_dir(dirs$obtenir$menage$telechargees)

}

#' Get team composition
#'
#' First, fetch composition. Then, write to labelled Stata file.
#'
#' @param dir Character. Directory where data should be stored.
#' @inheritParams susoflows::download_matching
#'
#' @importFrom susoapi get_interviewers
#' @importFrom labelled var_label
#' @importFrom haven write_dta
#' @importFrom fs path
#'
#' @noRd
get_team_composition <- function(
  dir,
  server,
  workspace,
  user,
  password
) {

  # construct team composition
  team_composition <- susoapi::get_interviewers(
    server = server,
    workspace = workspace,
    user = user,
    password = password
  )

  # label columns for easier comprehension
  labelled::var_label(team_composition) <- list(
    UserId = "Interviewer GUID",
    UserName = "Interviewer user name",
    SupervisorId = "Supervisor user GUID",
    SupervisorName = "Supervisor user name",
    Role = "Role: Interviewer, Supervisor"
  )

  # write to disk
  haven::write_dta(
    data = team_composition,
    path = fs::path(dir, "team_composition.dta")
  )

}
