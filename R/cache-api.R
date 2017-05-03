
#' List packages in the cache
#'
#' @return A list of data frames. There is one data frame for each package
#'   directory. I.e. on platforms where CRAN supports binary packages,
#'   there is one directory for binaries, and one for source packages.
#'   The name of the list element is the absolute path to the package
#'   directory.
#'
#'   Each data frame has three columns: `Package`, `Version` and `MD5sum`.
#'
#' @family cache management functions
#' @export
#' @importFrom cranlike package_versions

crancache_list <- function() {
  create_cache_if_needed()
  cache_dirs <- unique_with_names(get_cache_package_dirs())
  structure(
    lapply(cache_dirs, package_versions),
    names = cache_dirs
  )
}

#' Remove the cache completely
#'
#' It deletes the cache directory as well.
#'
#' @inheritParams base::unlink
#' @family cache management functions
#' @export

crancache_clean <- function(force = FALSE) {
  create_cache_if_needed()
  cache_dir <- get_cache_dir()
  unlink(cache_dir, recursive = TRUE, force = force)
  invisible()
}

#' Remove some packages from the cache
#'
#' The function ignores errors, so if it fails to remove a
#' package, it just continues with the rest of the packages.
#'
#' @param pkgs A character vector of regular expressions, that are
#'   matched to file names in all package directories. The matching
#'   files are removed from the cache.
#'
#' @family cache management functions
#' @export
#' @importFrom cranlike remove_PACKAGES

crancache_remove <- function(pkgs) {
  create_cache_if_needed()
  cache_dirs <- get_cache_package_dirs()
  for (dir in cache_dirs) {
    files <- unlist(lapply(pkgs, list.files, path = dir))
    for (file in files) {
      message("Removing ", sQuote(file), " from cache")
      try(remove_PACKAGES(file, dir = dir))
    }
  }
  invisible()
}
