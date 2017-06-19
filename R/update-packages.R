
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
#' @family caching package management functions

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

  myrepos <- c(get_crancache_repos(), repos)

  warnings <- list()
  errors <- list()
  timestamp <- Sys.time()
  args <- match.call(expand.dots = FALSE)$...

  update_cache <- should_update_crancache()
  add_built_binaries <- should_add_binaries()

  available <- update_metadata_for_install(method, type, repos)

  withr::with_options(
    list(repos = if (is.null(repos)) getOption("repos") else myrepos),
    tryCatch(
      utils::update.packages(
        lib.loc = lib.loc,
        repos = myrepos,
        ## We don't specify contriburl, on purpose
        method = method,
        instlib = instlib,
        ask = ask,
        available = available,
        oldPkgs = oldPkgs,
        ...,
        checkBuilt = checkBuilt,
        type = type),
      warning = function(w) { warnings <- append(warnings, w); warning(w) },
      error = function(e) { errors <- append(errors, e); stop(e) },
      error = function(e) stop(e),
      finally = if (update_cache) update_cache(
        list(...)$destdir, binaries = add_built_binaries, warnings, errors,
        lib.loc, timestamp, args)
    )
  )
}
