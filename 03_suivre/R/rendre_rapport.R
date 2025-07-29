#' Perform Quarto report rendering workflow
#'
#' @description
#' Workflow:
#' - Determine which report template to use
#' - Copy that template, and associated resources, from `inst` to `ressources`.
#' - Render the report where the template and resources have been copied
#' - Move the rendered report to a user-facing folder
#'
#' @importFrom glue glue
#' @importFrom dplyr case_when
#' @importFrom fs path path_package file_copy file_move
#' @importFrom quarto quarto_render
#'
#' @return Side-effect of producing a rendered report in a certain directory
rendre_rapport <- function(
  type,
  params
) {

  # ============================================================================
  # set paths as a function of project path and report type
  # ============================================================================

  # ----------------------------------------------------------------------------
  # app paths
  # ----------------------------------------------------------------------------

  report_name <- glue::glue("rapport_{type}.qmd")

  report_dir <- dplyr::case_when(
    type == "progres" ~ "01_progres",
    type == "qualite" ~ "02_qualite",
    TRUE ~ ""
  )

  # top-level report-specific directory
  report_dir <- fs::path(
    params$dir_proj, "03_suivre", report_dir
  )

  # where template should be copied
  template_dest_path <- fs::path(
    report_dir, "ressources", report_name
  )

  # ----------------------------------------------------------------------------
  # `inst` path
  # ----------------------------------------------------------------------------

  template_inst_path <- fs::path(
    params$dir_proj, "03_suivre", "inst", report_name
  )

  # ============================================================================
  # copy resources from package to app
  # ============================================================================

  fs::file_copy(
    path = template_inst_path,
    new_path = template_dest_path,
    overwrite = TRUE
  )

  # TODO: add files/revise approach as needed

  # ============================================================================
  # render report in situ
  # ============================================================================

  quarto::quarto_render(
    input = template_dest_path,
    execute_params = params
  )

  # ============================================================================
  # move report to user-facing report dir
  # ============================================================================

  fs::file_move(
    path = fs::path(
      report_dir, "ressources", glue::glue("rapport_{type}.html")
    ),
    new_path = fs::path(report_dir, glue::glue("rapport_{type}.html"))
  )

}
