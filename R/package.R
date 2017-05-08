
#' Transparent Caching of Packages from CRAN-like Repositories
#'
#' Provides wrappers for [utils::install.packages()],
#' [utils::download.packages()] and [utils::update.packages()] that
#' transparently cache downloaded packages in a local CRAN-like repository.
#'
#' @section Configuration:
#' The package can be configured via environment variables. The reason for
#' this (as opposed to direct argument to the functions), is that
#' `crancache` functions are often used via other packages (e.g. `remotes`),
#' and the user does not call them directly. Environment variables still
#' allow an easy configuration, especially with the `withr` package.
#' See examples below.
#'
#' Environment variables:
#' * `CRANCACHE_DISABLE`: set this to a non-empty value to disable
#'   `crancache` completely.
#' * `CRANCACHE_REPOS`: set this to a comma separated list of repository
#'   names (e.g. `cran` or `other`, see [get_cache_package_dirs()]. If
#'   empty string or unset, all local repositories are used.
#' * `CRANCACHE_DISABLE_UPDATES`: set this to a non-empty value to
#'   disable updates to the cache.
#' * `CRANCACHE_DISABLE_BINARY_UPDATES`: set this to a non-empty value
#'   to disable adding just-built binary packages to the cache.
#'   (Downloaded binaries are still added.)
#' * `CRANCACHE_QUIET`: if set to a non-empty value, then `crancache`
#'   does not print status messages to the screen.
#'
#' If non of these environment variables are set (i.e. by default)
#' the cache is used and updated and all cache repositories are active.
#'
#' @examples
#' \dontrun{
#' ## Install a package with remotes, enable the cache
#' withr::with_envvar(
#'   c(CRANCACHE_DISABLE = NA),
#'   remotes::install_local("my-local-package")
#' )
#'
#' ## Install a package with remotes, disable the cache
#' withr::with_envvar(
#'   c(CRANCACHE_DISABLE = "yes"),
#'   remotes::install_local("my-local-package")
#' )
#'
#' ## Install a package with cache, but do not update the cache
#' withr::with_envvar(
#'   c(CRANCACHE_DISABLE = NA, CRANCACHE_DISABLE_UPDATES = "yes"),
#'   remotes::install_local("my-local-package")
#' )
#'
#' ## Install a package with cache, disable binary updates
#' withr::with_envvar(
#'   c(CRANCACHE_DISABLE = NA, CRANCACHE_DISABLE_BINARY_UPDATES = "yes"),
#'   remotes::install_local("my-local-package")
#' )
#'
#' ## See which repos are active for various CRANCACHE_REPOS settings
#' withr::with_envvar(
#'   c(CRANCACHE_DISABLE = NA, CRANCACHE_REPOS = NA),
#'   get_crancache_repos()
#' )
#' withr::with_envvar(
#'   c(CRANCACHE_DISABLE = NA, CRANCACHE_REPOS = ""),
#'   get_crancache_repos()
#' )
#' withr::with_envvar(
#'   c(CRANCACHE_DISABLE = NA, CRANCACHE_REPOS = "cran"),
#'   get_crancache_repos()
#' )
#' withr::with_envvar(
#'   c(CRANCACHE_DISABLE = NA, CRANCACHE_REPOS = "cran,other"),
#'   get_crancache_repos()
#' )
#' }
#' @docType package
#' @name crancache
NULL
