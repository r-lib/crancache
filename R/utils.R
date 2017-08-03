
`%||%` <- function(l, r) if (is.null(l)) r else l

url_scheme <- function(url) {
  if (grepl("^[^:]+:", url)) {
    sub("(^[^:]+):.*", "\\1", url)
  } else {
    ""
  }
}

bak_file <- function(path) {
  paste0(path, ".bak")
}

make_key <- function(x) {
  gsub("[^a-z0-9]+", "-", tolower(x))
}

read_dcf <- function(file) {
  as.list(read.dcf(file)[1,])
}

write_dcf <- function(x, file) {
  m <- matrix(unlist(x), nrow = 1)
  colnames(m) <- names(x)
  write.dcf(m, file = file)
}

try_silently <- function(expr) {
  try(expr, silent = TRUE)
}

unique_with_names <- function(x) {
  x[! duplicated(x)]
}

warn_for_ignored_arg <- function(x) {
  call <- match.call(sys.function(sys.parent(1)), sys.call(-1))
  if (x %in% names(call)) {
    warning(sQuote(x), " argument is ignored", call. = FALSE)
  }
}

pkg_name_from_file <- function(x) {
  sub("^([a-zA-Z0-9\\.]+)_.*$", "\\1", basename(x))
}

isFALSE <- function(x) {
  identical(x, FALSE)
}

ungzip <- function(path) {
  if (! grepl("\\.gz$", path)) stop("Not the a gzipped file")
  target <- sub("\\.gz$", "", path)
  gzf <- gzfile(path, open = "r")
  on.exit(close(gzf))
  writeLines(readLines(gzf), target)
}

r_version <- function() {
  paste0(R.Version()[c("major", "minor")], collapse = ".")
}

is_download_error <- function(x) {
  inherits(x, "download_error")
}

#' @importFrom utils getFromNamespace

`%:::%` <- function(pkg, fun) getFromNamespace(fun, asNamespace(pkg))

is_nonstd_binary <- function(file) {
  !grepl("[-0-9.]+\\.tar\\.gz$", file) &&
    !grepl("\\.tgz$", file) &&
    !grepl("\\.zip$", file)
}
