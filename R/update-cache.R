
#' Update the cache after a download/install/update
#'
#' @param destdir Directory of the downloaded packages. See
#'   [utils::install.packages()].
#' @param binaries Whether to try to add binary packages to the cache.
#' @param warnings List of warnings we got from [utils::install.packages()].
#' @param lib The `lib` argument to `install_packages`. Where the
#'   packages are installed. If missing or `NULL`, then first element
#'   of [base::.libPaths()] is used.
#' @param timestamp A timestamp, when the installation started.
#'   We use this to decide if a package was installed in the current
#'   process.
#' @param args additional arguments to `install_packages` (or the other
#'   functions), they have to be matched.
#'
#' @keywords internal

update_cache <- function(destdir, binaries = FALSE, warnings = list(),
                         lib, timestamp, args) {
    update_cache_safe(destdir, binaries, warnings, lib, timestamp, args)
}

update_cache_safe <- function(destdir, binaries, warnings, lib,
                              timestamp, args) {

  ## Find the downloaded packages
  destdir <- destdir %||% file.path(tempdir(), "downloaded_packages")

  ## Get the downloaded package files
  files <- list.files(destdir, pattern = "\\.zip$|\\.tgz$|\\.tar\\.gz$")
  ffiles <- file.path(destdir, files)

  ## Add them to the cache
  lapply(ffiles, function(f) try_silently(update_cache_file(f)))

  if (binaries) {
    update_cache_binaries(destdir, warnings, lib, timestamp, args)
  }
}

#' @importFrom cranlike add_PACKAGES package_versions
#' @importFrom tools md5sum

update_cache_file <- function(file) {
  dir <- get_cache_dir_for_file(file)
  if (is.null(dir)) return()

  ## If already exists, then quit
  md5 <- md5sum(file)
  versions <- package_versions(dir)
  if (md5 %in% versions$MD5sum) return()

  ## If not a proper file, then quit
  if (! check_integrity(file)) return ()

  dir.create(tmp <- tempfile())
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  file.copy(file, tmp)

  ## Final check, maybe the file has changed since we looked at it
  tfile <- file.path(tmp, basename(file))
  if (md5sum(tfile) != md5) return()

  ## All is good
  if (!is_quiet()) {
    message("Adding ", sQuote(basename(file)), " to the cache")
  }
  file.copy(tfile, dir)
  add_PACKAGES(basename(file), dir = dir)
}

#' @importFrom desc desc_get

get_cache_dir_for_file <- function(file) {
  repository <- desc_get("Repository", file)[[1]]
  biocViews <- desc_get("biocViews", file)[[1]]

  linux_binary <- !grepl("[-0-9.]+\\.tar\\.gz$", file)

  prefix <- if (identical(repository, "CRAN")) {
    if (linux_binary) "cran-bin/" else "cran/"
  } else if (!is.na(biocViews)) {
    if (linux_binary) "bioc-bin/" else "bioc/"
  } else {
    if (linux_binary) "other-bin/" else "other/"
  }

  which <- if (grepl("\\.zip$", file)) {
    if (.Platform$pkgType == "win.binary") {
      "platform"
    }

  } else if (grepl("\\.tgz$", file)) {
    if (grepl("^mac.binary", .Platform$pkgType)) {
      "platform"
    }

  } else if (grepl("\\.tar\\.gz$", file)) {
    ## This also includes Linux binaries
    "source"
  }

  get_cache_package_dirs()[[paste0(prefix, which)]]
}
