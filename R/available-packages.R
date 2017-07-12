
#' List Available Packages at CRAN-like Repositories, Including Local Caches
#'
#' This function is similar to [utils::available.packages()], but also
#' includes the crancache repositories in the list.
#'
#' @inheritParams utils::available.packages
#' @export
#' @importFrom digest sha1
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

  if (!missing(contriburl)) update_repo_metadata(contriburl)

  mytype <- if (missing(type) || type == "both") "source" else type

  call <- match.call()
  call[[1]] <- quote(utils::available.packages)
  call$repos <-
    if (is.null(repos)) NULL else c(get_crancache_repos(mytype), repos)
  call$filters <- list()

  res <- eval(call, envir = parent.frame())

  filters <- get_filters(filters)

  hash <- sha1(list(res, filters))
  if (hash %in% ls(data_env)) {
    get(hash, data_env)
  } else {
    res <- apply_filters(res, filters)
    assign(hash, res, envir = data_env)
    res
  }
}

apply_filters <- function(pkgs, filters) {
  if (!length(pkgs)) return(pkgs)

  for (f in filters) {
    if (!length(pkgs)) break
    if (is.character(f)) {
      f <- ("utils" %:::% "available_packages_filters_db")[[f]]
    }
    if (!is.function(f)) stop("invalid 'filters' argument, not a function")
    pkgs <- f(pkgs)
  }

  pkgs
}

get_filters <- function(filters) {
  filters <- filters %||%
    getOption("available_packages_filters") %||%
    "utils" %:::% "available_packages_filters_default"

  if (is.list(filters) && isTRUE(filters$add)) {
    filters$add <- NULL
    filters <- c("utils" %:::% "available_packages_filters_default", filters)
  }
  filters
}

## This will update / inject the RDS metadata cache that
## download.packages will pick up automatically
## Note that for 'both' we cannot supply 'available', but we
## inject the cached RDS files, nevertheless

update_metadata_for_install <- function(method, type, repos) {
  if (type %in% c("source", "both")) {
    av_src <- available_packages(method = method, fields = NULL,
                                 type = "source", filters = NULL,
                                 repos = repos)
  }
  if (type %in% c("binary", "both") ||
      (.Platform$pkgType != "source" && type == .Platform$pkgType)) {
    av_bin <- available_packages(method = method, fields = NULL,
                                 type = "binary", filters = NULL,
                                 repos = repos)
  }

  ## If type = "both", then available must be NULL
  if (type == "source") {
    av_src
  } else if (type == "both") {
    NULL
  } else {
    c(get_crancache_repos(), repos)
  }
}
