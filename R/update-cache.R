
update_cache <- function(destdir) {
  ## Find the downloaded packages
  destdir <- destdir %||% file.path(tempdir(), "downloaded_packages")

  ## Get the downloaded package files
  files <- list.files(destdir, pattern = "\\.zip$|\\.tgz$|\\.tar\\.gz$")

  ## Backup the files, so that they do not change by other
  ## install processes that might be running
  bakdir <- backup_files(destdir, files)
  on.exit(try_silently(unlink(bakdir, recursive = TRUE)), add = TRUE)

  ## Add them to the cache
  lapply(file.path(bakdir, files), update_cache_file)
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

  versions <- package_versions(dir)
  md5 <- md5sum(file)
  if (! md5 %in% versions$MD5sum && check_integrity(file)) {
    message("Adding ", sQuote(basename(file)), " to the cache")
    file.copy(file, dir)
    add_PACKAGES(basename(file), dir = dir)
  }
}

backup_files <- function(dir, files) {
  dir.create(bakdir <- tempfile())
  file.copy(file.path(dir, files), bakdir)
  bakdir
}
