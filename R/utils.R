
`%||%` <- function(l, r) if (is.null(l)) r else l

make_key <- function(x) {
  gsub("[^a-z0-9]+", "-", tolower(x))
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
