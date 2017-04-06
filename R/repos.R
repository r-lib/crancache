
interpret_type <- function(type) {
  if (type == "binary") {
    .Platform$pkgType
  } else if (type == "both") {
    unique(c(.Platform$pkgType, "source"))
  } else {
    type
  }
}

#' @importFrom cranlike create_empty_PACKAGES

get_cached_repos <- function(type) {

  ## Make sure that we have the appropriate cache directories
  cache_dir <- get_cache_dir()
  cache_url <- get_cache_url()
  package_dirs <- get_package_dirs(cache_dir, interpret_type(type))
  lapply(package_dirs, create_empty_PACKAGES)

  c(CRANCACHE = cache_url)
}
