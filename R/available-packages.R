
#' List Available Packages at CRAN-like Repositories, Including Local Caches
#'
#' This function is similar to [utils::available.packages()], but also
#' includes the crancache repositories in the list.
#'
#' @inheritParams utils::available.packages
#' @export
#' @family caching package management functions

available_packages <- function(contriburl = contrib.url(repos, type),
                               method, fields = NULL,
                               type = getOption("pkgType"),
                               filters = NULL, repos = getOption("repos")) {

  if (! is_crancache_active()) {
    return(utils::available.packages(contriburl = contriburl,
                                     method = method, fields = fields,
                                     type = type, filters = filters,
                                     repos = repos))
  }

  myrepos <- if (is.null(repos)) {
    NULL
  } else {
    c(get_crancache_repos(), get_current_shadow_repos(repos))
  }

  call <- match.call()
  call[[1]] <- quote(utils::available.packages)
  call$repos <- myrepos
  eval(call, envir = parent.frame())

  ## TODO: need to point to the real repos, instead of the shadows
}
