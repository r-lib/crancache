
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
