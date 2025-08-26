# ==============================================================================
# Server connection details
# ==============================================================================

# ------------------------------------------------------------------------------
# Connection details provided
# ------------------------------------------------------------------------------

missing_server_params <- c(
  serveur, espace_travail, utilisateur, mot_de_passe
) == ""

if (any(missing_server_params)) {

  connection_params <- c(
    "serveur", "espace_travail", "utilisateur", "mot_de_passe"
  )

  missing_server_params_txt <- connection_params[missing_server_params]

  stop(
    glue::glue(
      "Détails de connexion au serveur absent.",
      paste0(
        "Les détails suivants ont été laissé vides dans _details_server.R :",
        glue::glue_collapse(
          glue::backtick(missing_server_params_txt),
          last = ", et "
        )
      ),
      .sep = "\n"
    )
  )

}

# ------------------------------------------------------------------------------
# Server exists at specified URL
# ------------------------------------------------------------------------------

server_exists <- function(url) {

  tryCatch(
    expr = httr::status_code(httr::GET(url = url)) == 200,
    error = function(e) {
      FALSE
    }
  )

}

if (!server_exists(url = serveur)) {
  stop(paste0("Le serveur n'existe pas à l'adresse fournie : ", serveur))
}

# ------------------------------------------------------------------------------
# Credentials valid
# ------------------------------------------------------------------------------

credentials_valid <- suppressMessages(
	susoapi::check_credentials(
    server = serveur,
    workspace = espace_travail,
    user = utilisateur,
    password = mot_de_passe,
		verbose = TRUE
	)
)

if (credentials_valid == FALSE) {

  stop(
    glue::glue(
      "Informations d'identification non valides pour l'utilisateur API.",
      "L'un des problèmes suivants peut être présent.",
      paste0(
        "1. Ces informations d'identification peuvent être invalide",
        "(e.g., mauvais utilistaeur, mot de passe, etc)."
      ),
      paste0(
        "2. Ces informations peuvent être pour le mauvais type d'utilisateur",
        "(e.g., Headquarters)."
      ),
      "3. L'utilisateur peut ne pas avoir accès à l'espace de travail cible.",
      "Veuillez vérifier et reprendre.",
      .sep = "\n"
    )
  )

}

# ------------------------------------------------------------------------------
# Confirmer que le(s) questionnaire(s) cible existe(nt)
# ------------------------------------------------------------------------------

confirmer_qnr_existe <- function(
  qnr_type,
  qnr_expr,
  call = rlang::caller_env()
) {

  tryCatch(
    expr = susoflows::find_matching_qnrs(
      matches = qnr_expr,
      server = serveur,
      workspace = espace_travail,
      user = utilisateur,
      password = mot_de_passe
    ),
    warning = function(cnd) {

      qnrs <- susoapi::get_questionnaires(
        server = serveur,
        workspace = espace_travail,
        user = utilisateur,
        password = mot_de_passe
      ) |>
      dplyr::mutate(qnr_title = glue::glue("{title} (version {version})")) |>
      dplyr::pull(qnr_title) |>
      glue::glue_collapse(sep = ", ")

      qnr_var <- dplyr::case_when(
        qnr_type == "menage" ~ "qnr_menage",
        qnr_type == "communautaire" ~ "qnr_communautaire",
        .default = "titre du questionnaire"
      )

      cli::cli_abort(
        message = c(
          "x" = "Aucun questionnaire {qnr_type} correspondant retrouvé",
          "i" = "Veuillez reprendre la valeur de {.code {qnr_var}}",
          "i" = "Voici les questionnaires dans l'espace de travail cible : {qnrs}"
        ),
        call = call
      )

    }

  )
}

confirmer_qnr_existe(
  qnr_type = "menage",
  qnr_expr = qnr_menage
)

confirmer_qnr_existe(
  qnr_type = "communautaire",
  qnr_expr = qnr_communautaire
)

# ------------------------------------------------------------------------------
# Confirmer le nom du fichier ménage
# ------------------------------------------------------------------------------

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# n'est pas vide
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

if (fichier_menage == "") {

  cli::cli_abort(
    message = c(
      "x" = "Paramètre {.arg fichier_menage} est vide.",
      "i" = paste0(
        "Veuillez lire les commentaires du fichier {.file _parametres.R}",
        "et fournir la valeur attendue."
      )
    )
  )

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# ne contient pas l'extension `.dta`
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

if (grepl(x = fichier_menage, pattern = "\\.dta")) {

  cli::cli_abort(
    message = c(
      "x" = "Nom du fichier Stata fourni au lieu de la variable du qnr.",
      "i" = paste0(
        "Veuillez fournir la valeur trouvé dans Designer, en suivant les",
        "en suivant les consignes du fichier {.file _parametre.R}"
      )
    )
  )

}

# ------------------------------------------------------------------------------
# Confirmer les statuts à passer en revue
# ------------------------------------------------------------------------------

if (!is.vector(statuts_a_rejeter) | !is.numeric(statuts_a_rejeter)) {

  cli::cli_abort(
    message = c(
      "x" = paste(
        "Le paramètre {.arg statuts_a_rejeter}",
        "n'est le pas de la forme attendue."
      ),
      "i" = "Le programme s'attend à un vecteur délimité par virgule :",
      " " = "{.code statuts_a_rejeter <- c(100, 120)}"
    )
  )

}

statuts_possibles <- c(100, 120, 130)

if (!all(statuts_a_rejeter %in% statuts_possibles)) {

  cli::cli_abort(
    message = c(
      "x" = "Valeur(s) inattendue(s) dans {.arg statuts_a_rejeter}",
      "i" = paste(
        "Valeurs possibles :",
        glue::glue_collapse(statuts_possibles, sep = ", ")
      ),
      "i" = paste(
        "Valeur(s) retrouvé(s) :",
        glue::glue_collapse(statuts_a_rejeter, sep = ", ")
      )
    )
  )

}

# ------------------------------------------------------------------------------
# Confirmer les problèmes à rejeter
# ------------------------------------------------------------------------------

if (!is.vector(problemes_a_rejeter) | !is.numeric(problemes_a_rejeter)) {

  cli::cli_abort(
    message = c(
      "x" = paste(
        "Le paramètre {.arg problemes_a_rejeter}",
        "n'est le pas de la forme attendue."
      ),
      "i" = "Le programme s'attend à un vecteur de délimité par virgule :",
      " " = "{.code problemes_a_rejeter <- c(100, 120)}"
    )
  )

}

problemes_possibles <- c(1, 2, 3, 4)

if (!all(problemes_a_rejeter %in% problemes_possibles)) {

  cli::cli_abort(
    message = c(
      "x" = "Valeur(s) inattendue(s) dans {.arg problemes_a_rejeter}",
      "i" = paste(
        "Valeurs possibles :",
        glue::glue_collapse(problemes_possibles, sep = ", ")
      ),
      "i" = paste(
        "Valeur(s) retrouvé(s) :",
        glue::glue_collapse(problemes_a_rejeter, sep = ", ")
      )
    )
  )

}

# ------------------------------------------------------------------------------
# Confirmer si le programme devrait rejeter ou pas
# ------------------------------------------------------------------------------

if (!is.logical(devrait_rejeter)) {

  cli::cli_abort(
    message = c(
      "x" = paste(
        "Le paramètre {.arg devrait_rejeter}",
        "n'est le pas de la forme attendue."
      ),
      "i" = "Le programme s'attend à une valeur TRUE/FALSE :"
    )
  )

}
