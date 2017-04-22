
#' Update the cache after a download/install/update
#'
#' @param destdir Directory of the downloaded packages. See
#'   [utils::install.packages()].
#' @param binaries Whether to try to add binary packages to the cache.
#' @param warnings List of warnings we got from [utils::install.packages()].
#' @param errors List of errors we got from [utils::install.packages()].
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
                         errors = list(), lib, timestamp, args) {
  tryCatch(
    update_cache_safe(destdir, binaries, warnings, errors, lib,
                      timestamp, args),
    error = function(e) stop(e)
  )
}

update_cache_safe <- function(destdir, binaries, warnings, errors, lib,
                              timestamp, args) {

  ## Find the downloaded packages
  destdir <- destdir %||% file.path(tempdir(), "downloaded_packages")

  ## Get the downloaded package files
  files <- list.files(destdir, pattern = "\\.zip$|\\.tgz$|\\.tar\\.gz$")
  ffiles <- file.path(destdir, files)

  ## Add them to the cache
  lapply(ffiles, function(f) try_silently(update_cache_file(f)))

  if (binaries) {
    update_cache_binaries(destdir, warnings, errors, lib, timestamp, args)
  }
}

#' @importFrom cranlike add_PACKAGES package_versions
#' @importFrom tools md5sum

update_cache_file <- function(file) {
  dirs <- get_cache_dirs()

  dir <- if (grepl("\\.zip$", file)) {
    if (.Platform$pkgType == "win.binary") {
      dirs[["platform"]]
    }

  } else if (grepl("\\.tgz$", file)) {
    if (grepl("^mac.binary", .Platform$pkgType)) {
      dirs[["platform"]]
    }

  } else if (grepl("\\.tar\\.gz$", file)) {
    dirs[["source"]]
  }

  if (is.null(dir)) return()

  ## If already exists, then quit
  md5 <- md5sum(file)
  versions <- package_versions(dir)
  if (md5 %in% versions$MD5sum) return()

  ## If not a proper file, then quit
  if (! check_integrity(file)) return ()

  file.copy(file, dir)

  ## Final check, maybe the file has changed since we looked at it
  tfile <- file.path(dir, basename(file))
  if (md5sum(tfile) != md5) {
    unlink(tfile, recursive = TRUE)
    return()
  }

  ## All is good
  message("Adding ", sQuote(basename(file)), " to the cache")
  add_PACKAGES(basename(file), dir = dir)
}
