
#' Root of the cache directory
#'
#' @return Path to the root of the cache directory,
#'   determined using `rappdirs`. E.g. on macOS it is
#'   `/Users/gaborcsardi/Library/Caches/R-crancache`.
#'
#' @importFrom rappdirs user_cache_dir
#' @export

get_cache_dir <- function() {
  Sys.getenv(
    "CRANCACHE_DIR",
    user_cache_dir("R-crancache")
  )
}

#' Get all package directories
#'
#' These are the directories that contain the packages.
#' There is a currently two of them:
#' * The `cran` directory contains binary and/or source packages,
#'   downloaded and/or installed from CRAN.
#' * The `bioc` directory contains binary and/or source BioConducor
#'   packages.
#' * The `other` directory contains non-CRAN packages.
#'
#' Each directory themself may contain multiple repositories,
#' according to the default layout by [utils::contrib.url()].
#'
#' @return A named character vector of package directories.
#' @export

get_cache_package_dirs <- function() {
  cache_dir <- get_cache_dir()

  cran <- file.path(cache_dir, "cran")
  bioc <- file.path(cache_dir, "bioc")
  other <- file.path(cache_dir, "other")

  if (.Platform$pkgType == "source") {
    cran_bin <- file.path(cache_dir, "cran-bin")
    bioc_bin <- file.path(cache_dir, "bioc-bin")
    other_bin <- file.path(cache_dir, "other-bin")

    c(
      "cran-bin/source"     = get_package_dirs(cran_bin, "source"),
      "cran/platform"       = get_package_dirs(cran, .Platform$pkgType),
      "cran/source"         = get_package_dirs(cran, "source"),
      "bioc-bin/source"     = get_package_dirs(bioc_bin, "source"),
      "bioc/platform"       = get_package_dirs(bioc, .Platform$pkgType),
      "bioc/source"         = get_package_dirs(bioc, "source"),
      "other-bin/source"    = get_package_dirs(other_bin, "source"),
      "other/platform"      = get_package_dirs(other, .Platform$pkgType),
      "other/source"        = get_package_dirs(other, "source")
    )

  } else {
    c(
      "cran/platform"       = get_package_dirs(cran, .Platform$pkgType),
      "cran/source"         = get_package_dirs(cran, "source"),
      "bioc/platform"       = get_package_dirs(bioc, .Platform$pkgType),
      "bioc/source"         = get_package_dirs(bioc, "source"),
      "other/platform"      = get_package_dirs(other, .Platform$pkgType),
      "other/source"        = get_package_dirs(other, "source")
    )
  }
}

#' @importFrom utils URLencode

get_cache_urls <- function(type = "both") {

  repo_names <- if (.Platform$pkgType == "source" && (
                      type == "both" || type == "binary" ||
                      grepl("^mac.binary", type) || grepl("win.binary", type))) {
    c("cran-bin", "cran", "bioc-bin", "bioc", "other-bin", "other")
  } else {
    c("cran", "bioc", "other")
  }

  cache_dir <- get_cache_dir()
  paths <- paste0(
    "file:///", normalizePath(get_cache_dir(),  winslash = "/"),
    "/", repo_names)
  structure(
    vapply(paths, URLencode, character(1), USE.NAMES = FALSE),
    names = repo_names
  )
}

#' @importFrom utils contrib.url

get_package_dirs <- function(root, type) {
  paste0(
    root,
    vapply(type, contrib.url, "", repos = "")
  )
}
