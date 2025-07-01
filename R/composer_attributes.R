
#' Create attributes from a set of character-based specs
#'
#' @param attrib_name Character. Name of attribute.
#' @param fn_name Character. Name of `{susoreview}` function to use.
#' @param df_name Character. Name of the data frame.
#' @param condition Character. Expression used by the function.
#' @param attrib_vars Character. Regular expression for selecting variables used
#' in creating the attribute.
#'
#' @return Data frame. Same return value as that of the function in `fn_name`.
#'
#' @importFrom cli cli_abort
#' @importFrom base get0 is.null switch
#' @importFrom rlang caller_env parse_expr expr sym eval_bare
create_attribute_from_spec <- function(
  attrib_name,
  fn_name,
  df_name,
  condition,
  attrib_vars
) {

  valid_fn_names <- c(
    # from single column
    "extract_attribute",
    "create_attribute",
    # from several columns
    "count_vars",
    "count_list",
    "any_vars",
    # from several rows
    "count_obs",
    "any_obs",
    "sum_vals"
  )

  # check that function is valid
  if (!fn_name %in% valid_fn_names) {

    cli::cli_abort(
      message = c(
        "x" = "Invalid attribute function name provided",
        "i" = "Use either {.or {.arg {valid_fn_names}}}"
      )
    )

  }
  
  # fetch the matching data frame; return NULL if match not found
  df <- base::get0(
    x = df_name,
    envir = rlang::caller_env(),
    ifnotfound = NULL
  )

  # check whether the data frame values returned is NULL
  if (base::is.null(df)) {

    cli::cli_abort(
      message = c(
        "x" = "Data frame named {.arg {df_name}} does not exist.",
        "i" = "Please correct the name provided."
      )
    )

  }

  # transform character string into an expression
  condition_expr <- rlang::parse_expr(condition)

  # compose the call based on the function name provided
  call_expr <- base::switch(
    fn_name,
    # from a single column
    extract_attribute = rlang::expr(
      susoreview::extract_attribute(
        df = df,
        var = !!rlang::sym(condition),
        attrib_name = attrib_name,
        attrib_vars = attrib_vars
      )
    ),
    create_attrib = rlang::expr(
      susoreview::create_attrib(
        df = df,
        condition = !!condition_expr,
        attrib_name = attrib_name,
        attrib_vars = attrib_vars
      )
    ),
    # from several columns
    count_vars = rlang::expr(
      susoreview::count_vars(
        df = df,
        var_pattern = condition,
        var_val = 1,
        attrib_name = attrib_name,
        attrib_vars = attrib_vars
      )
    ),
    count_list = rlang::expr(
      susoreview::count_list(
        df = df,
        var_pattern = condition,
        missing_vals = c("##N/A##", "", NA_character_),
        attrib_name = attrib_name,
        attrib_vars = attrib_vars
      )
    ),
    any_vars = rlang::expr(
      susoreview::any_vars(
        df = df,
        var_pattern = condition,
        var_val = 1,
        attrib_name = attrib_name,
        attrib_vars = attrib_vars
      )
    ),
    # from several rows
    count_obs = rlang::expr(
      susoreview::count_obs(
        df = df,
        where = !!condition_expr,
        attrib_name = attrib_name,
        attrib_vars = attrib_vars
      )
    ),
    any_obs = rlang::expr(
      susoreview::any_obs(
        df = df,
        where = !!condition_expr,
        attrib_name = attrib_name,
        attrib_vars = attrib_vars
      )
    ),
    sum_vals = rlang::expr(
      susoreview::sum_vals(
        df = df,
        var = !!rlang::sym(condition),
        attrib_name = attrib_name,
        attrib_vars = attrib_vars
      )
    )
  )

  # evaluate the composed expression
  attrib_df <- rlang::eval_bare(call_expr)

  return(attrib_df)

}
