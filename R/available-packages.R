
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

  call <- match.call()
  call[[1]] <- quote(utils::available.packages)

  if (!is.null(repos)) {
    call$repos <- c(get_crancache_repos(), repos)

    ## We only handle the builtin filters, others are left to
    ## available.packages
    myfilt <- get_current_filters(filters)
    if (is.character(myfilt) &&
        all(myfilt %in% ls("utils" %:::% "available_packages_filters_db"))) {
      update_repo_metadata(contriburl, myfilt)
      call$filters <- list()
    } else {
      update_repo_metadata(contriburl, character())
    }
  }

  eval(call, envir = parent.frame())
}
