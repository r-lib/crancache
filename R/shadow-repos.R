
#' Return current shadow repositories
#'
#' Note that there is no `type` argument here, and we handle both binary
#' and source packages. We update both for each shadow, just in case
#' `utils::available_packages` needs either or both.
#'
#' @param repos Character vector of repositories. Typically just the
#'   value of `getOption("repos")`.
#' @return Character vector of shadow repositories.
#'
#' @keywords internal

get_current_shadow_repos <- function(repos) {
  vapply(repos, get_current_shadow_repo, character(1))
}

get_current_shadow_repo <- function(repo, type) {
  update_shadow_repo(repo)
  paste0("file://", get_shadow_directory(repo))
}

get_shadow_directory <- function(repo) {
  file.path(get_cache_dir(), "_shadow", make_key(repo))
}

update_shadow_repo <- function(repo) {
  ## Do not touch local repos
  if (substring(repos, 1L, 8L) == "file:///") return()
  update_shadow_repo_type(repo, "source")
  update_shadow_repo_type(repo, "binary")
}

update_shadow_repo_type <- function(repo, type) {
  repo <- sub("/$", "", repo)
  url <- contrib.url(repo, type = type)

  ## Work out local directory for the shadow
  if (substring(url, 1, nchar(repo)) != repo) {
    stop("Internal error, repo is not a prefix of contrib.url")
  }
  pc <- strsplit(
    substring(url, nchar(repo) + 2, nchar(url)), "/", fixed = TRUE)[[1]]
  path <- do.call(file.path, as.list(c(get_shadow_directory(repo), pc)))

  ## If shadow does not exist, we create it
  if (!file.exists(path)) {
    dir.create(path, showWarnings = FALSE, recursive = TRUE)
  }

  ## Check etag file. We have a single etag, and if it matches the
  ## current etag of PACKAGES or PACKAGES.gz, then we are current.
  etagfile <- file.path(path, "packages-etag.txt")
  if (! file.exists(etagfile) ||
      ! compare_etag(url, readLines(etagfile))) {
    message("Updating repo metadata: ", repo, " (", type, ")")
    etag <- mirror_packages(repo, url, path, etagfile)
    writeLines(etag, etagfile)
  }
}

#' Compare local etag to remote
#'
#' @keywords internal
#' @importFrom httr HEAD headers

compare_etag <- function(url, old) {
  packages_gz_url <- paste0(url, "/PACKAGES.gz")
  packages_url    <- paste0(url, "/PACKAGES")

  ## Try to check PACKAGES.gz first
  etag <- tryCatch(
    headers(HEAD(packages_gz_url))$etag,
    error = function(e) e
  )

  ## If error, check PACKAGES
  ## Or, if different, check PACKAGES
  if (inherits(etag, "error") || ! identical(etag, old)) {
    etag <- headers(HEAD(packages_url))$etag
  }

  identical(etag, old)
}

#' @importFrom httr GET write_disk

mirror_packages <- function(repo, url, path, etagfile) {
  packages_gz_url  <- paste0(url, "/PACKAGES.gz")
  packages_url     <- paste0(url, "/PACKAGES")
  packages_gz_path <- file.path(path, "PACKAGES.gz")
  packages_path    <- file.path(path, "PACKAGES")
  etagfile         <- file.path(path, "packages-etag.txt")

  ## Try PACKAGES.gz
  resp <- tryCatch(
    {
      GET(packages_gz_url, write_disk(packages_gz_path, overwrite = TRUE))
      ungzip(packages_gz_path)
    },
    error = function(x) x
  )

  ## Try PACKAGES as well
  if (inherits(resp, "error")) {
    resp <- GET(packages_url, write_disk(packages_path))
  }

  headers(resp)$etag
}
