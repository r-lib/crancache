
#' @importFrom rappdirs user_cache_dir

get_cache_dir <- function() {
  Sys.getenv(
    "CRANCACHE_DIR",
    user_cache_dir("R-crancache")
  )
}

get_cache_url <- function() {
  URLencode(paste0(
    "file://",
    get_cache_dir()
  ))
}

get_package_dirs <- function(root, type) {
  paste0(
    root,
    vapply(type, contrib.url, "", repos = "")
  )
}
