
#' Update Outdated Packages, with Caching
#'
#' @param ... additional arguments are passed to
#'   [utils::update.packages()].
#' @inheritParams utils::update.packages
#' @inheritParams utils::install.packages
#'
#' @export update.packages
#' @family caching package manager functions

update.packages <- function(
  lib.loc = NULL, repos = getOption("repos"),
  contriburl = contrib.url(repos, type), method, instlib = NULL,
  ask = TRUE, available = NULL, oldPkgs = NULL, ...,
  checkBuilt = FALSE, type = getOption("pkgType")) {

  if (! is_crancache_active()) {
    call <- match.call()
    call[[1]] <- quote(utils::update.packages)
    return(eval(call, env = parent.frame()))
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
