
is_crancache_active <- function() {
  Sys.getenv("CRANCACHE_DISABLE", "") == ""
}

get_crancache_repos <- function() {

  if (!is_crancache_active()) return(character())

  repos <- Sys.getenv("CRANCACHE_REPOS", NA_character_)

  use_cache <- if (is.na(repos)) {
    ## Not set, everything
    TRUE
  } else {
    ## Set, only selected
    unique(trimws(strsplit(repos, ",", fixed = TRUE)[[1]]))
  }

  crancache_repos <- get_cached_repos()

  if (isTRUE(use_cache)) {
    use_cache <- rep(TRUE, length(crancache_repos))
  } else {
    use_cache <- intersect(names(crancache_repos), use_cache)
  }

  crancache_repos[use_cache]
}

should_update_crancache <- function() {
  is_crancache_active() &&
    Sys.getenv("CRANCACHE_DISABLE_UPDATES", "") == ""
}

should_add_binaries <- function() {
  is_crancache_active() &&
  Sys.getenv("CRANCACHE_DISABLE_BINARY_UPDATES", "") == ""
}
