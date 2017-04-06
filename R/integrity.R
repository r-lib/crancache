
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
    { unzip(file, list = TRUE); TRUE },
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
    { untar(con, list = TRUE); TRUE },
    error = function(e) FALSE
  )
}
