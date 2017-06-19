
update_repo_metadata <- function(contriburl) {
  lapply(contriburl, update_repo_metadata1)
}

#' @importFrom conf conf

update_repo_metadata1 <- function(url1) {
  ## We do not handle local repos, because available.packages
  ## does not cache them, anyway.
  if (substring(url1, 1, 8) == "file:///") return()

  metafile <- get_metadata_file(url1)
  cf <- conf$new(file = metafile)

  if (!try_update_packages(url1, cf, "PACKAGES.rds") &&
      !try_update_packages(url1, cf, "PACKAGES.gz")  &&
      !try_update_packages(url1, cf, "PACKAGES")) {
    warning("Cannot update repo metadata for ", sQuote(url1))
    return()
  }

  dest <- file.path(
    tempdir(),
    paste0("repos_", URLencode(url1, TRUE), ".rds")
  )

  set_full_metadata_rds(dest, url1, cf)
}

set_full_metadata_rds <- function(dest, url, cf) {
  myrds <- file.path(get_metadata_dir(url), "PACKAGES.rds")
  file.copy(myrds, dest)
}

get_metadata_dir <- function(url) {
  d <- file.path(get_cache_dir(), "_meta", make_key(url))
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
  d
}

get_metadata_file <- function(url) {
  file.path(get_metadata_dir(url), "config.yml")
}

try_update_packages <- function(url, cf, pkgfile) {
  etag <- cf$get(paste0("etags:", pkgfile))
  myrds <- file.path(get_metadata_dir(url), "PACKAGES.rds")

  if (! file.exists(myrds)) {
    return(really_try_update_packages(url, cf, pkgfile))

  } else if (! is.null(etag)) {
    new <- get_contrib_etag(url, pkgfile, default = NULL)
    if (!is.null(new)) {
      if (identical(etag, new)) return(TRUE)
      return(really_try_update_packages(url, cf, pkgfile))
    } else {
      return(FALSE)
    }
  } else {
    return(really_try_update_packages(url, cf, pkgfile))
  }
}

#' @importFrom httr HEAD http_error

get_contrib_etag <- function(url, file, default = NULL) {
  url <- paste0(url, "/", file)
  resp <- HEAD(url)
  if (http_error(resp)) {
    NULL
  } else {
    headers(resp)$etag
  }
}

#' @importFrom httr GET headers http_error write_disk

really_try_update_packages <- function(url, cf, pkgfile) {

  message("Updating package data, ", url, ", ", pkgfile)

  ## Try downloading the file
  url2 <- paste0(url, "/", pkgfile)
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  resp <- GET(url2, write_disk(tmp))
  if (http_error(resp)) return(FALSE)

  ## Parse PACKAGES file into an RDS
  myrds <- file.path(get_metadata_dir(url), "PACKAGES.rds")
  if (pkgfile == "PACKAGES.rds") {
    file.copy(tmp, myrds, overwrite = TRUE)

  } else if (pkgfile == "PACKAGES.gz") {
    gz <- gzfile(tmp, open = "r")
    on.exit(close(gz), add = TRUE)
    av <- read.dcf(gz)
    saveRDS(av, file = myrds)

  } else if (pkgfile == "PACKAGES") {
    av <- read.dcf(tmp)
    saveRDS(av, file = myrds)

  } else {
    warning("Unknown package metadata file: ", sQuote(pkgfile))
    return(FALSE)
  }

  ## Update etags in config file
  cf$lock(exclusive = TRUE, timeout = 5000)
  if (file.exists(cf$get_path())) cf$reload()
  cf$set(paste0("etags:", pkgfile), headers(resp)$etag)
  cf$save(unlock = TRUE)

  TRUE
}
