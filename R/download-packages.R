
#' Download Package from CRAN-like Repositories, with Caching
#'
#' @inheritParams utils::download.packages
#'
#' @export
#' @family caching package manager functions
#' @importFrom utils contrib.url

download.packages <- function(
  pkgs, destdir, available = NULL, repos = getOption("repos"),
  contriburl = contrib.url(repos, type), method,
  type = getOption("pkgType"), ...) {

  warn_for_ignored_arg("contriburl")
  warn_for_ignored_arg("available")

  myrepos <- c(get_cached_repos(type), repos)

  tryCatch(
    utils::download.packages(
      pkgs = pkgs,
      destdir = destdir,
      available = NULL,                 # overwritten
      repos = myrepos,
      ## We don't specify contriburl, on purpose
      method = method,
      type = type,
      ...),
    error = function(e) stop(e),
    finally = update_cache(destdir)
  )
}
