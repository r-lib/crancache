
is_crancache_active <- function() {
  Sys.getenv("CRANCACHE_DISABLE", "") == ""
}

#' @importFrom rappdirs user_cache_dir

get_cache_dir <- function() {
  Sys.getenv(
    "CRANCACHE_DIR",
    user_cache_dir("R-crancache")
  )
}

get_cache_dirs <- function() {
  cache_dir <- get_cache_dir()
  c(
    platform = get_package_dirs(cache_dir, .Platform$pkgType),
    source = get_package_dirs(cache_dir, "source")
  )
}

#' @importFrom utils URLencode

get_cache_url <- function() {
  URLencode(paste0(
    "file://",
    get_cache_dir()
  ))
}

#' @importFrom utils contrib.url

get_package_dirs <- function(root, type) {
  paste0(
    root,
    vapply(type, contrib.url, "", repos = "")
  )
}
