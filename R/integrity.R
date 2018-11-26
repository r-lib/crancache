
check_integrity <- function(file) {
  if (grepl("\\.zip$", file)) {
    check_integrity_zip(file)
  } else if (grepl("\\.tgz$|\\.tar\\.gz$", file)) {
    check_integrity_targz(file)
  } else {
    ## Just ignore other files
    FALSE
  }
}

#' @importFrom utils unzip

check_integrity_zip <- function(file) {
  if (file.info(file)$size == 0) return(FALSE)
  tryCatch(
    is_package_file_list(file, unzip(file, list = TRUE)$Name),
    error = function(e) FALSE,
    warning = function(e) FALSE
  )
}

#' @importFrom utils untar

check_integrity_targz <- function(file) {
  if (file.info(file)$size == 0) return(FALSE)
  con <- gzfile(file, open = "rb")
  on.exit(close(con), add = TRUE)
  tryCatch(
    is_package_file_list(file, untar(con, list = TRUE)),
    error = function(e) FALSE
  )
}

is_package_file_list <- function(file, list) {
  pkgname <- pkg_name_from_file(file)

  ## A single directory, named after the package
  if (any(! grepl(paste0("^", pkgname, "\\b"), list))) return(FALSE)

  ## DESCRIPTION file
  if (! paste0(pkgname, "/DESCRIPTION") %in% list) return(FALSE)

  return(TRUE)
}
