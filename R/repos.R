
interpret_type <- function(type) {
  if (type == "binary") {
    .Platform$pkgType
  } else if (type == "both") {
    unique(c(.Platform$pkgType, "source"))
  } else {
    type
  }
}

get_cached_repos <- function() {
  create_cache_if_needed()
  get_cache_urls()
}

#' @importFrom cranlike create_empty_PACKAGES

create_cache_if_needed <- function() {
  dirs <- get_cache_package_dirs()
  for (dir in get_cache_package_dirs()) {
    pkgfile <- file.path(dir, "PACKAGES")
    if (!file.exists(pkgfile)) create_empty_PACKAGES(dir)
  }
}
