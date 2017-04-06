
get_cached_list <- function(url) {
  if (needs_update(url)) update_list(url)
  cache_get_data(url)
}

clear_cache <- function(url = NULL) {
  cf <- if (!is.null(url)) {
    ## TODO
  } else {
    ## TODO
  }
}

## -----------------------------------------------------------------------
## Rest is the implementation

get_cache_file <- function(key) {
  dir <- get_cache_dir()
  file.path(dir, "download_cache", make_key(key))
}

cache_store <- function(key, data, metadata) {
  cf <- get_cache_file(key)
  dir.create(dirname(cf), showWarnings = FALSE, recursive = FALSE)
  data_file <- paste0(cf, ".rds")
  metadata_file <- paste0(cf, ".dcf")

  write_dcf(metadata, file = bak_file(metadata_file))
  saveRDS(data, file = bak_file(data_file))

  file.rename(
    bak_file(c(data_file, metadata_file)),
    c(data_file, metadata_file)
  )
}

cache_get_data <- function(key) {
  file <- paste0(get_cache_file(key), ".rds")
  readRDS(file)
}

cache_get_metadata <- function(key) {
  file <- paste0(get_cache_file(key), ".dcf")
  read_dcf(file)
}

cache_has_file <- function(key) {
  file.exists(paste0(get_cache_file(key), ".dcf"))
}

needs_update <- function(url) {
  if (!cache_has_file(url)) return(TRUE)
  switch(
    url_scheme(url),
    "http" = needs_update_http(url),
    "https" = needs_update_http(url),
    "ftp" = needs_update_ftp(url),
    "file" = needs_update_file(url),
    TRUE
  )
}

#' @importFrom httr headers HEAD

needs_update_http <- function(url) {
  record <- cache_get_metadata(url)
  heads <- headers(HEAD(url))
  if (! is.null(heads$etag) && "etag" %in% names(record)) {
    return(heads$etag != record$etag)
  } else if (! is.null(heads$`last-modified`)) {
    return(as.POSIXct(record$timestamp) < heads$`last-modified`)
  } else {
    return(TRUE)
  }
}

needs_update_ftp <- function(url) {
  ## TODO
  TRUE
}

needs_update_file <- function(url) {
  ## TODO
  TRUE
}

#' @importFrom httr GET stop_for_status content

update_list <- function(url) {
  timestamp <- format(Sys.time())
  stop_for_status(resp <- GET(url))
  metadata <- list(
    etag = headers(resp)$etag,
    timestamp = timestamp
  )
  ## Note that this assumes a .gz file!
  data <- read.dcf(gzcon(rawConnection(content(resp))))
  cache_store(url, data, metadata)
}
