
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
#' @param ... additional arguments are passed to
#'    [utils::install.packages()].
#' @inheritParams utils::install.packages
#'
#' @export
#' @family caching package manager functions

install_packages <- function(
  pkgs, lib, repos = getOption("repos"),
  contriburl = contrib.url(repos, type), method, available = NULL,
  destdir = NULL, dependencies = NA, type = getOption("pkgType"), ...) {

  if (! is_crancache_active()) {
    call <- match.call()
    call[[1]] <- quote(utils::install.packages)
    return(eval(call, envir = parent.frame()))
  }

  warn_for_ignored_arg("contriburl")
  warn_for_ignored_arg("available")

  ## Check if repos should be NULL, i.e. we are installing a single
  ## package file
  if (length(pkgs) == 1L && missing(repos) && missing(contriburl) &&
      grepl("\\.zip$|\\.tgz$|\\.tar\\.gz$", pkgs)) {
    repos <- NULL
  }

  ## If repos should be NULL, then we keep it NULL
  myrepos <- if (is.null(repos)) repos else c(get_cached_repos(type), repos)

  warnings <- list()
  errors <- list()
  timestamp <- Sys.time()

  args <- match.call(expand.dots = FALSE)$...

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
    warning = function(w) { warnings <- append(warnings, w); warning(w) },
    error = function(e) { errors <- append(errors, e); stop(e) },
    finally = update_cache(
      destdir, binaries = TRUE, warnings, errors, lib, timestamp, args
    )
  )
}
