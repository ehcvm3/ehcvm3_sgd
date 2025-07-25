#' Identifier outliers
#'
#' @param df Data frame. 
#' @param var Bare variable name. Variable to check for outliers.
#' @param by tidy-select expression
#' (e.g., `c(var1, var2)`, `dplyr::starts_with("var")`)
#' @param exclude Numeric vector. One or more values to exclude from the
#' algorithm (e.g., 0 in zero-inflated distributions, DK values like 9999).
#' @param transform Character. Name of tranformation for data prior to outlier
#' detection. One of: "none" (no transformation), "log" (natural logarithm).
#' @param n_mad Numeric. Acceptable distance from the median as the
#' number of median absolute deviations.
#' @param min_obs Numeric. Minimum number of within-group observations for
#' outlier detection to be deemed valid.
#' @param type Numeric. Type of issue. Values are as follows:
#' `c(Reject = 1, Comment = 2, Review = 4)`
#' @param desc Character. Short, HQ-facing description of the issue.
#' @param comment Character. Longer, field staff-facing description of the
#' @param comment_question Boolean. Whether or not to add a comment to the
#' variable specified in `var`.
#' issue.
#'
#' @return Data frame of outlier issues that are at the interview level and,
#' if `comment_question = TRUE`, comments at the question level.
#'
#' @importFrom cli cli_abort
#' @importFrom rlang enquo as_name quo_is_null expr_text enexpr as_name sym
#' englue
#' @importFrom tidyselect eval_select
#' @importFrom dplyr group_by pick summarise n ungroup mutate left_join if_else
#' between filter rowwise select bind_rows case_when
#' @importFrom tibble tibble
#' @importFrom glue glue glue_collapse
identify_outliers <- function(
  df,
  var,
  by = NULL,
  exclude = NULL,
  transform = "none",
  n_mad = 2,
  min_obs = 30,
  type = 1,
  desc,
  comment,
  comment_question = FALSE
) {


  # ============================================================================
  # check args
  # ============================================================================

  # ============================================================================
  # defuse/transform for later use/evaluation
  # ============================================================================

  # ----------------------------------------------------------------------------
  # var
  # ----------------------------------------------------------------------------

  var_chr <- rlang::as_name(rlang::enquo(var))

  # ----------------------------------------------------------------------------
  # by
  # ----------------------------------------------------------------------------

  # as a Boolean based on whether `by` is `NULL` or not
  # to determine whether data should be grouped or not
  by_is_null <- rlang::quo_is_null(quo = rlang::enquo(by))

  # as a character vector of variable names for joining
  # so that `left_join()` has a set of keys for data with
  # computed thresholds for saying whether each datum is an outlier
  # because join variables need to either be an expression
  # or a vector of column names
  by_vars <- if (!by_is_null) {
    by_vars <- rlang::enquo(by) |>
      # evaluate the expression in the context of the data
      # return a named set of indices for the selected columns
      tidyselect::eval_select(data = df) |>
      # grab the names
      names()
  } else {
    NULL
  }

  # as a character containing the user-provided expression
  # so that this parameter can be injected into the HQ-facing
  # description, which contains computed values and function params
  by_expr_chr <- rlang::expr_text(
    expr = rlang::enexpr(by),
    width = 500
  )

  # ============================================================================
  # compute thresholds for outliers
  # either by group(s) in `by` or overall
  # ============================================================================

  df_thresholds <- df |>
    (\(x) {
      if (!by_is_null) {
        dplyr::group_by(
          .data = x,
          dplyr::pick({{by}})
        )
      } else {
        x
      }
    })() |>
    # change excluded values, if any, to NA
    (\(x) {
      if (!is.null(exclude)) {
        dplyr::mutate(
          .data = x,
          {{var}} := dplyr::if_else(
            condition = {{var}} %in% exclude,
            NA_real_,
            {{var}}
          )
        )
      } else {
        x
      }
    })() |>
    # transform values before outlier detection
    (\(x) {
      if (transform == "log") {
        dplyr::mutate(
          .data = x,
          {{var}} := log({{var}})
        )
      } else {
        x
      }
    })() |>
    dplyr::summarise(
      n_obs = dplyr::n(),
      med = stats::median({{var}}, na.rm = TRUE),
      mad = stats::mad({{var}}, na.rm = TRUE)
    ) |>
    (\(x) {
      if (!by_is_null) {
        dplyr::ungroup(x = x)
      } else {
        x
      }
    })() |>
    dplyr::mutate(
      # create bounds
      ll = med - (n_mad * mad),
      ul = med + (n_mad * mad)
    )

  # ============================================================================
  # combine raw data and thresholds to filter to outliers
  # ============================================================================

  df_outliers <- df |>
    # drop observations with excluded values
    # so that they are not compared against outlier thresholds and classified
    dplyr::filter(!{{var}} %in% exclude) |>
    # transform variable
    dplyr::mutate(
      "transform_{{var}}" := dplyr::case_when(
        transform == "log" ~ log({{var}}),
        transform == "none" ~ {{var}},
        .default = {{var}}
      )
    ) |>
    (\(x) {

      if (!by_is_null) {

        df_w_thresholds <- dplyr::left_join(
          x = x,
          y = df_thresholds,
          by = by_vars
        )

      } else {

        # if there is no `by` variable, then summary is a single-row df
        # extract atomic values from the columns of that df
        n_obs <- df_thresholds$n_obs
        med <- df_thresholds$med
        mad <- df_thresholds$mad
        ul <- df_thresholds$ul
        ll <- df_thresholds$ll

        # inject values as fixed values in columns
        df_w_thresholds <- dplyr::mutate(
          .data = x,
          n_obs = n_obs,
          med = med,
          mad = mad,
          ul = ul,
          ll = ll
        )

      }

      df_w_thresholds

    })() |>
    # determine whether value lies within the bounds
    dplyr::mutate(
      is_outlier = dplyr::if_else(
        condition = n_obs >= min_obs,
        true = !dplyr::between(
          x = !!rlang::sym(rlang::englue("transform_{{var}}")),
          left = ll,
          right = ul
        ),
        false = NA,
        missing = NA
      )
    ) |>
    dplyr::filter(is_outlier == TRUE)

  # ============================================================================
  # construct the data frame of issues
  # ============================================================================

  # if no outliers found, construct an empty data frame
  if (nrow(df_outliers) == 0) {

    df_issues <- tibble::tibble(
      interview__id = NA_character_,
      interview__key = NA_character_,
      issue_type = NA_real_,
      issue_desc = NA_character_,
      issue_comment = NA_character_,
      issue_vars = NA_character_,
      issue_loc = NA_character_,
      .rows = 0
    )

  # if any outliers found, construct the data frame's contents
  } else {

    df_issues <- df_outliers |>
      dplyr::mutate(
        issue_type = type,
        issue_desc = glue::glue(
          "{desc}",
          "[GROUP VAL: value={.data[[var_chr]]}, n_obs={n_obs}, med={med}, ll={ll}, ul={ul}]",
          "[FUN ARGS: n_mad={n_mad}, min_obs: {min_obs}, by: {by_expr_chr}]",
          .sep = "\n"
        ),
        issue_comment = glue::glue(comment),
        issue_vars = var_chr,
        issue_loc = NA_character_
      ) |>
      dplyr::select(
        interview__id, interview__key,
        issue_type, issue_desc, issue_comment, issue_vars, issue_loc
      )

  }

  # ============================================================================
  # construct the data frame of question-level comments
  # ============================================================================

  # create a data frame of question-level comments
  # if the user requests those comments, construct an appropriate data frame
  # otherwise, construct an empty data frame for row-binding below
  if (comment_question == TRUE) {

    main_id_vars <- c("interview__id", "interview__id")

    # get the names of all ID columns
    id_vars <- base::grep(
      x = base::names(df_outliers),
      pattern = "__id$",
      value = TRUE
    )

    # subset to those other than the main ID variables
    # that is, to all roster ID variables
    roster_vars <- id_vars[!id_vars %in% main_id_vars]

    # if any roster ID variables are present, construct coordinates to locate the variable
    # otherwise, do not construct the coordinates
    # in both cases, create one issue per outlier observation with a comment type
    if (length(roster_vars) > 0) {

      # construct a comma-separated series of roster coordinates
      # taking values from all ID variables in the same row
      # to identify where in the offending observation is located
      # (e.g., `2, 1, 3` for row 2 of parent roster, row 1 of child, row 3
      # of grandchild)
      df_outliers_w_loc <- df_outliers |>
        dplyr::rowwise() |>
        dplyr::mutate(
          # first, construct the series of comma-separated coordinates
          issue_loc = glue::glue_collapse(
            x = dplyr::pick(roster_vars),
            sep = ", "
          ),
          # then, enclose this series of cordinates in square brackets
          # to be understood # as an array by the API endpoint
          issue_loc = paste0("[", issue_loc,"]")
        ) |>
        dplyr::ungroup()

    } else {

      df_outliers_w_loc <- df_outliers |>
        dplyr::mutate(
          issue_loc = NA_character_
        )

    }

    df_var_lvl_comments <- df_outliers_w_loc |>
      dplyr::mutate(
        issue_type = 2,
        issue_desc = glue::glue(
          "{desc}",
          "[GROUP VAL: value={{var_chr}}, n_obs={n_obs}, med={med}, ll={ll}, ul={ul}]",
          "[FUN ARGS: n_mad={n_mad}, min_obs: {min_obs}, by: {by_expr_chr}]",
          .sep = "\n"
        ),
        issue_comment = glue::glue(comment),
        issue_vars = var_chr
      ) |>
      dplyr::select(
        interview__id, interview__key,
        issue_type, issue_desc, issue_comment, issue_vars, issue_loc
      )

  } else {

    df_var_lvl_comments <- tibble::tibble(
      interview__id = NA_character_,
      interview__key = NA_character_,
      issue_type = NA_real_,
      issue_desc = NA_character_,
      issue_comment = NA_character_,
      issue_vars = NA_character_,
      issue_loc = NA_character_,
      .rows = 0
    )

  }

  df_issues_all <- dplyr::bind_rows(
    df_issues, df_var_lvl_comments
  )

  return(df_issues_all)

}
