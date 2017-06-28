
#' Download Package from CRAN-like Repositories, with Caching
#'
#' @param ... additional arguments are passed to
#'   [utils::download.packages()].
#' @inheritParams utils::download.packages
#'
#' @export
#' @family caching package management functions
#' @importFrom utils contrib.url

download_packages <- function(
  pkgs, destdir, available = NULL, repos = getOption("repos"),
  contriburl = contrib.url(repos, type), method,
  type = getOption("pkgType"), ...) {

  if (! is_crancache_active()) {
    call <- match.call()
    call[[1]] <- quote(utils::download.packages)
    return(eval(call, envir = parent.frame()))
  }

  warn_for_ignored_arg("contriburl")
  warn_for_ignored_arg("available")

  myrepos <- c(get_crancache_repos(), repos)

  if (should_update_crancache()) on.exit(update_cache(destdir))

  utils::download.packages(
    pkgs = pkgs,
    destdir = destdir,
    available = NULL,                 # overwritten
    repos = myrepos,
    ## We don't specify contriburl, on purpose
    method = method,
    type = type,
    ...)
}
