
#' Update Outdated Packages, with Caching
#'
#' @param oldPkgs if specified as non-NULL, `update_packages()`
#'  only considers these packages for updating. This may be a character
#'  vector of package names or a matrix as returned by \code{old.packages}.
#' @param ... additional arguments are passed to
#'   [utils::update.packages()].
#' @inheritParams utils::update.packages
#' @inheritParams utils::install.packages
#'
#' @export
#' @family caching package manager functions

update_packages <- function(
  lib.loc = NULL, repos = getOption("repos"),
  contriburl = contrib.url(repos, type), method, instlib = NULL,
  ask = TRUE, available = NULL, oldPkgs = NULL, ...,
  checkBuilt = FALSE, type = getOption("pkgType")) {

  if (! is_crancache_active()) {
    call <- match.call()
    call[[1]] <- quote(utils::update.packages)
    return(eval(call, envir = parent.frame()))
  }

  warn_for_ignored_arg("contriburl")
  warn_for_ignored_arg("available")

  myrepos <- c(get_cached_repos(type), repos)

  tryCatch(
    utils::update.packages(
      lib.loc = lib.loc,
      repos = myrepos,
      ## We don't specify contriburl, on purpose
      method = method,
      instlib = instlib,
      ask = ask,
      available = NULL,                   # overwritten
      oldPkgs = oldPkgs,
      ...,
      checkBuilt = checkBuilt,
      type = type),
    error = function(e) stop(e),
    finally = update_cache(list(...)$destdir)
  )
}
