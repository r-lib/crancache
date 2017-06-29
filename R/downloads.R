
#' Download multiple files, in parallel
#'
#' For each file, a list of URLs can be given, and they are tried one
#' by one.
#'
#' If a `<filename>.etag` file exists, then it is used to check if the
#' download is needed, with a HTTP HEAD request.
#'
#' @param downloads Named list. The names are the paths for the target
#'   files. Each list element is a character vector of URLs to try.
#'
#' @keywords internal
#' @importFrom curl new_pool curl_fetch_multi multi_run new_handle
#'   handle_setopt parse_headers

download_files <- function(downloads) {

  result <- vector(mode = "list", length(downloads))
  etags <- get_etags_for_downloads(downloads)

  make_callbacks <- function(which) {
    force(which)
    last_try <- 0
    ## This is the etag for HEAD, and NULL for GET
    expected_etag <- NULL
    last_verb <- "GET"

    callbacks <- list(
      done = function(resp) {
        if (is_success(resp)) {
          result[[which]] <<- downloads[[which]][[last_try]]
          target <- get_target(downloads, which, last_try)
          if (last_verb == "GET") {
            writeBin(resp$content, target)
            write_etag_for_path(target, get_etag_from_response(resp))
          } else {
            Sys.setFileTime(target, Sys.time())
          }
        } else {
          try_next()
        }
      },
      fail = function(err = "no urls specified") {
        result[[which]] <<- make_download_error(err)
        try_next()
      }
    )

    try_next <- function() {
      if (last_try == length(downloads[[which]]) && last_verb == "GET") {
        return()
      }
      if (last_verb == "GET") last_try <<- last_try + 1

      h <- new_handle()
      url <- downloads[[which]][[last_try]]
      if (last_verb == "GET" && !is.na(etag <- etags[[which]][[last_try]])) {
        last_verb <<- "HEAD"
        expected_etag <- etag
        handle_setopt(h, customrequest = "HEAD", nobody = TRUE)
      } else {
        cat("getting ", url)
        last_verb <<- "GET"
        expected_etag <<- NULL
      }

      curl_fetch_multi(url, done = callbacks$done, fail = callbacks$fail,
                       pool = pool)
    }

    is_success <- function(resp) {
      if (resp$status_code != 200) return(FALSE)
      if (is.null(expected_etag)) return (TRUE)
      etag_new <- get_etag_from_response(resp)
      identical(etag_new, expected_etag)
    }

    shedule_next_http <- function(try) {
      h <- new_handle()
      if (!is.na(etags[[which]][[try]])) {
        expected_etag <<- etags[[which]][[try]]
        handle_setopt(h, customrequest = "HEAD", nobody = TRUE)

      } else {
        expected_etag <<- NULL
      }
    }

    callbacks
  }

  pool <- new_pool()
  for (d in seq_along(downloads)) make_callbacks(d)$fail()

  multi_run(pool = pool)
  structure(result, names = names(downloads))
}

get_etags_for_downloads <- function(downloads) {
  etags <- vector(mode = "list", length(downloads))
  targets <- get_targets_for_downloads(downloads)
  for (i in seq_along(downloads)) {
    e <- vapply(targets[[i]], get_etag_for_path, character(1))
    etags[[i]] <- rep_len(e, length(downloads[[i]]))
  }
  etags
}

get_target <- function(downloads, which, try) {
  if (is.null(names(downloads[[which]]))) {
    names(downloads)[which]
  } else {
    names(downloads[[which]])[try]
  }
}

get_targets_for_downloads <- function(downloads) {
  lapply(seq_along(downloads), function(i)  {
    if (is.null(names(downloads[[i]]))) {
      names(downloads)[i]
    } else {
      names(downloads[[i]])
    }
  })
}

get_etag_from_response <- function(resp) {
  line <- grep("^etag:", ignore.case = TRUE, parse_headers(resp$headers),
               value = TRUE)
  sub("^etag:[ ]*", "", line, ignore.case = TRUE)
}

get_etag_file <- function(path) {
  file.path(dirname(path), "_cache", paste0(basename(path), ".etag"))
}

get_etag_for_path <- function(path) {
  ## there is a warning if the file does not exist
  tryCatch(
    suppressWarnings(readLines(get_etag_file(path))[[1]]),
    error = function(e) NA_character_
  )
}

write_etag_for_path <- function(path, etag) {
  etag_file <- get_etag_file(path)
  dir.create(dirname(etag_file), recursive = TRUE, showWarnings = FALSE)
  writeLines(etag, etag_file)
}

make_download_error <- function(msg) {
  structure(
    list(message = msg, call = NULL),
    class = c("download_error", "error", "condition")
  )
}
