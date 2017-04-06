
#' Install Packages from Repositories or Local Files, with Caching
#'
#' @param pkgs character vector of the names of packages whose
#'    current versions should be downloaded from the repositories.
#'
#'    If \code{repos = NULL}, a character vector of file paths.
#'    These can be source directories or archives
#'    or binary package archive files (as created by \command{R CMD build
#'      --binary}).  (\code{http://} and \code{file://} URLs are also
#'    accepted and the files will be downloaded and installed from local
#'    copies.)  On a CRAN build of \R for macOS these can be \file{.tgz}
#'    files containing binary package archives.
#'    Tilde-expansion will be done on file paths.
#'
#'    If this is missing or a zero-length character vector, a listbox of
#'    available packages is presented where possible in an interactive \R
#'    session.
#' @inheritParams utils::install.packages
#'
#' @export
#' @family caching package manager functions
#' @importFrom cranlike create_empty_PACKAGES
#' @importFrom utils contrib.url

install.packages <- function(
  pkgs, lib, repos = getOption("repos"),
  contriburl = contrib.url(repos, type), method, available = NULL,
  destdir = NULL, dependencies = NA, type = getOption("pkgType"), ...) {

  warn_for_ignored_arg("contriburl")
  warn_for_ignored_arg("available")

  myrepos <- c(get_cached_repos(type), repos)

  tryCatch(
    utils::install.packages(
      pkgs = pkgs,
      lib = lib,
      repos = myrepos,
      ## We don't specify contriburl, on purpose
      method = method,
      available = NULL,                   # overwritten
      destdir = destdir,
      dependencies = dependencies,
      type = type,
      ...),
    error = function(e) stop(e),
    finally = update_cache(destdir)
  )
}
