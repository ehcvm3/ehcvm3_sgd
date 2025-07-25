# ==============================================================================
# Make decisions
# ==============================================================================

# check for comments
# returns a data frame of cases that contain comments
interviews_with_comments <- susoreview::check_for_comments(
  df_comments = comments,
  df_issues = issues_plus_miss_and_suso,
  df_cases_to_review = entretiens_a_valider
)

# decide what action to take
decisions <- susoreview::decide_action(
  df_cases_to_review = entretiens_a_valider,
  df_issues = issues_plus_miss_and_suso,
  issue_types_to_reject = problemes_a_rejeter,
  df_has_comments = interviews_with_comments,
  df_interview_stats = interview_stats
)

# add rejection messages
to_reject <- decisions[["to_reject"]]

to_reject <- susoreview::add_rejection_msgs(
  df_to_reject = to_reject,
  df_issues = issues_plus_miss_and_suso
)

# flag persistent issues
revised_decisions <- susoreview::flag_persistent_issues(
  df_comments = comments,
  df_to_reject = to_reject
)

# ==============================================================================
# Extract decisions into data representing them
# ==============================================================================

# ------------------------------------------------------------------------------
# To reject
# ------------------------------------------------------------------------------

to_reject_ids <- revised_decisions[["to_reject"]] |>
  dplyr::select(interview__id) |>
  dplyr::left_join(entretiens_a_valider, by = "interview__id")

to_reject_issues <- to_reject_ids |>
  dplyr::left_join(
    issues_plus_miss_and_suso,
    by = c("interview__id", "interview__key")
  ) |>
  dplyr::filter(issue_type %in% c(problemes_a_rejeter, 2)) |>
  dplyr::select(
    interview__id, interview__key, interview__status,
    dplyr::starts_with("issue_")
  )

to_reject_api <- revised_decisions[["to_reject"]]

# ---------------------------------------------------------------------------
# To review
# ---------------------------------------------------------------------------

to_review_ids <- decisions[["to_review"]]

to_review_issues <- to_review_ids |>
  dplyr::left_join(
    issues_plus_miss_and_suso,
    by = c("interview__id", "interview__key")
  ) |>
  dplyr::filter(issue_type %in% c(problemes_a_rejeter, 4)) |>
  dplyr::select(
    interview__id, interview__key, interview__status,
    dplyr::starts_with("issue_")
  )

to_review_api <- susoreview::add_rejection_msgs(
  df_to_reject = decisions[["to_review"]],
  df_issues = issues_plus_miss_and_suso
)

# ---------------------------------------------------------------------------
# To follow up
# ---------------------------------------------------------------------------

to_follow_up_ids <- revised_decisions[["to_follow_up"]] |>
  dplyr::left_join(entretiens_a_valider, by = "interview__id") |>
  dplyr::select(interview__id, interview__key)

to_follow_up_issues <- revised_decisions[["to_follow_up"]] |>
  dplyr::left_join(issues_plus_miss_and_suso, by = "interview__id") |>
  dplyr::left_join(
    entretiens_a_valider,
    by = c("interview__id", "interview__key")
  ) |>
  dplyr::select(
    interview__id, interview__key, interview__status,
    dplyr::starts_with("issue_")
  )

to_follow_up_api <- revised_decisions[["to_follow_up"]]

# ===========================================================================
# Collect recommendations in a named list
# ===========================================================================

decisions_list <- list(
  # to reject
  to_reject_ids = to_reject_ids,
  to_reject_issues = to_reject_issues,
  to_reject_api = to_reject_api,
  # to review
  to_review_ids = to_review_ids,
  to_review_issues = to_review_issues,
  to_review_api = to_review_api,
  # to follow up
  to_follow_up_ids = to_follow_up_ids,
  to_follow_up_issues = to_follow_up_issues,
  to_follow_up_api = to_follow_up_api
)

# ===========================================================================
# Write recommendations to disk
# ===========================================================================

# intermediate data
write_df_to_disk(df = entretiens_a_valider, dir = dirs$valider$recommandations)
write_df_to_disk(df = attribs, dir = dirs$valider$recommandations)
write_df_to_disk(df = issues, dir = dirs$valider$recommandations)

# recommendation files
write_df_list_to_disk(df_list = decisions_list, dir = dirs$valider$recommandations)
