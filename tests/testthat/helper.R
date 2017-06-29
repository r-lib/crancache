
skip_if_offline <- function(host = "httpbin.org", port = 80) {

  res <- tryCatch(
    pingr::ping_port(host, count = 1L, port = port),
    error = function(e) NA
  )

  if (is.na(res)) skip("No internet connection")
}

skip_if_download_errors <- function(dl) {
  if (any(vapply(dl, is_download_error, logical(1)))) {
    skip("download error(s)")
  }
}
