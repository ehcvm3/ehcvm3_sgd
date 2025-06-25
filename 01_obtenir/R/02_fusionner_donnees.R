#' Inventory Stata data files in target directory
#'
#' @param dir Character. Path to parent directory to scan files in child
#' directories
#'
#' @return Data frame. Columns: `path`, path to the file; `file_name`,
#' file name without path.
#'
#' @importFrom fs dir_ls dir_info
#' @importFrom dplyr mutate select
inventory_files <- function(dir) {

  # obtain list of all directories of unpacked zip files
  sub_dirs <- fs::dir_ls(
    path = dir,
    type = "directory",
    recurse = FALSE
  )

  # compile list of all Stata files in all directories
  if (length(sub_dirs) > 0) {
  files_df <- sub_dirs |>
    purrr::map_dfr(
      .f = ~ fs::dir_info(
        path = .x,
        recurse = FALSE,
        type = "file",
        regexp = "\\.dta$"
      )
    ) |>
    dplyr::mutate(file_name = fs::path_file(.data$path)) |>
    dplyr::select(path, file_name)
  # assign a null value if one found
  } else {
    files_df <- NULL
  }

  return(files_df)

}

#' Combine and save Stata data files with the same name
#' 
#' @param file_df Data frame. Return value of `inventory_files()`.
#' @param name Character. Name of the file (with extension) to ingest from
#' all folders where it is found.
#' @param dir Character. Directory where combined data will be saved.
#'
#' @return Side-effect of writing combined files to disk.
#'
#' @importFrom dplyr filter pull
#' @importFrom purrr map_dfr
#' @importFrom haven read_dta
#' @importFrom fs path
combine_and_save <- function(
  file_df,
  name,
  dir
) {

  # file paths
  # so that can locate same-named data files to combine
  file_paths <- file_df |>
    dplyr::filter(.data$file_name == name) |>
    dplyr::pull(.data$path)

  # variable labels
  # so that can assign labels where purrr drops them
  # returns named list of the form needed by `labelled::set_variable_labels()`
  lbls <- file_paths[1] |>
    haven::read_dta(n_max = 0) |>
    labelled::var_label()

  # data frame
  # so that can assign this value to a name
  df <- purrr::map_dfr(
    .x = file_paths,
    .f = ~ haven::read_dta(file = .x)
  )

  # apply variable labels
  df <- df |>
    labelled::set_variable_labels(.labels = lbls)

  # save to destination directory
  haven::write_dta(data = df, path = fs::path(dir, name))

}

#' Combine and save Stata data files, iterating over each file name
#'
#' @param dir_downloaded Character. Directory data are downloaded and unzipped.
#' @param dir_combined Charcter. Directory data are combined.
#'
#' @return Side-effect of writing combined files to disk
#'
#' @importFrom dplyr `%>%` distinct pull
#' @importFrom purrr walk
combine_and_save_all <- function(
  dir_downloaded,
  dir_combined
) {

  # inventory all Stata data files in sub-directories below `dir`
  files_df <- inventory_files(dir = dir_downloaded)

  # if any files found
  if (!is.null(files_df)) {

    # create a list of unique file names
    # so that can iterate over all files names
    file_names <- files_df |>
      dplyr::distinct(file_name) |>
      dplyr::pull(file_name)

    # combine and save all same-named Stata files
    purrr::walk(
      .x = file_names,
      .f = ~ combine_and_save(
        file_df = files_df,
        name = .x,
        dir = dir_combined
      )
    )

  }

}
