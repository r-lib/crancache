% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/package.R
\docType{package}
\name{crancache}
\alias{crancache}
\alias{crancache-package}
\title{Transparent Caching of Packages from CRAN-like Repositories}
\description{
Provides wrappers for \code{\link[utils:install.packages]{utils::install.packages()}},
\code{\link[utils:download.packages]{utils::download.packages()}} and \code{\link[utils:update.packages]{utils::update.packages()}} that
transparently cache downloaded packages in a local CRAN-like repository.
}
\section{Configuration}{

The package can be configured via environment variables. The reason for
this (as opposed to direct argument to the functions), is that
\code{crancache} functions are often used via other packages (e.g. \code{remotes}),
and the user does not call them directly. Environment variables still
allow an easy configuration, especially with the \code{withr} package.
See examples below.

Environment variables:
\itemize{
\item \code{CRANCACHE_DISABLE}: set this to a non-empty value to disable
\code{crancache} completely.
\item \code{CRANCACHE_REPOS}: set this to a comma separated list of repository
names (e.g. \code{cran} or \code{other}, see \code{\link[=get_cache_package_dirs]{get_cache_package_dirs()}}. If
empty string or unset, all local repositories are used.
\item \code{CRANCACHE_DISABLE_UPDATES}: set this to a non-empty value to
disable updates to the cache.
\item \code{CRANCACHE_DISABLE_BINARY_UPDATES}: set this to a non-empty value
to disable adding just-built binary packages to the cache.
(Downloaded binaries are still added.)
\item \code{CRANCACHE_QUIET}: if set to a non-empty value, then \code{crancache}
does not print status messages to the screen.
}

If non of these environment variables are set (i.e. by default)
the cache is used and updated and all cache repositories are active.
}

\examples{
\dontrun{
## Install a package with remotes, enable the cache
withr::with_envvar(
  c(CRANCACHE_DISABLE = NA),
  remotes::install_local("my-local-package")
)

## Install a package with remotes, disable the cache
withr::with_envvar(
  c(CRANCACHE_DISABLE = "yes"),
  remotes::install_local("my-local-package")
)

## Install a package with cache, but do not update the cache
withr::with_envvar(
  c(CRANCACHE_DISABLE = NA, CRANCACHE_DISABLE_UPDATES = "yes"),
  remotes::install_local("my-local-package")
)

## Install a package with cache, disable binary updates
withr::with_envvar(
  c(CRANCACHE_DISABLE = NA, CRANCACHE_DISABLE_BINARY_UPDATES = "yes"),
  remotes::install_local("my-local-package")
)

## See which repos are active for various CRANCACHE_REPOS settings
withr::with_envvar(
  c(CRANCACHE_DISABLE = NA, CRANCACHE_REPOS = NA),
  get_crancache_repos()
)
withr::with_envvar(
  c(CRANCACHE_DISABLE = NA, CRANCACHE_REPOS = ""),
  get_crancache_repos()
)
withr::with_envvar(
  c(CRANCACHE_DISABLE = NA, CRANCACHE_REPOS = "cran"),
  get_crancache_repos()
)
withr::with_envvar(
  c(CRANCACHE_DISABLE = NA, CRANCACHE_REPOS = "cran,other"),
  get_crancache_repos()
)
}
}
