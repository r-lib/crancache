
update_repo_metadata <- function(contriburl) {
  files <- get_packages_urls(contriburl)
  dlres <- download_files(files)
  for (i in seq_along(contriburl)) {
    build_metadata_rds(contriburl[i])
  }
  sneak_in_rds_cache(contriburl)
}

get_packages_urls <- function(contriburl) {
  structure(
    lapply(contriburl, get_packages_url),
    names = vapply(contriburl, get_metadata_file, character(1), type = ".gz")
  )
}

get_packages_url <- function(contriburl) {
  ## We do not handle local repos, because available.packages
  ## does not cache them, anyway.
  if (substring(contriburl, 1, 8) == "file:///") return(character())

  ## Cache for 5 minutes
  gzfile <- get_metadata_file(contriburl, type = ".gz")
  if (file.exists(gzfile)) {
    age <- Sys.time() - file.mtime(gzfile)
    if (age < as.difftime(5, units = "mins")) return(character())
  }

  ## Otherwise try to download (or at least ping)
  paste0(contriburl, "/", "PACKAGES.gz")
}

build_metadata_rds <- function(contriburl) {
  gz <- get_metadata_file(contriburl, type = ".gz")
  rds <- get_metadata_file(contriburl, type = ".rds")

  ## No input? Then nothing to do
  if (!file.exists(gz)) return()

  ## Output is newer, nothing to do
  if (file.exists(rds) && file.mtime(gz) < file.mtime(rds)) return()

  gzf <- gzfile(gz, open = "r")
  av <- read.dcf(gzf)
  if (length(av)) rownames(av) <- av[, "Package"]
  close(gzf)
  saveRDS(av, file = rds)
}

sneak_in_rds_cache <- function(contriburl) {
  for (url1 in contriburl) {
    dest <- file.path(
      tempdir(),
      paste0("repos_", URLencode(url1, TRUE), ".rds")
    )
    mine <- get_metadata_file(url1, type = ".rds")
    if (file.exists(mine)) file.copy(mine, dest)
  }
}

get_metadata_dir <- function(url) {
  d <- file.path(get_cache_dir(), "_meta", make_key(url))
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
  d
}

get_metadata_file <- function(url, type = c(".gz", ".rds")) {
  type <- match.arg(type)
  file.path(get_metadata_dir(url), paste0("PACKAGES", type))
}
