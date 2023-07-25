
#' @importFrom parsedate parse_date
#' @importFrom rematch2 re_match

update_cache_binaries <- function(destdir, warnings, lib, timestamp,
                                  args) {

  if ("INSTALL_opts" %in% names(args) &&
      any(grepl("--no-test-load", args$INSTALL_opts, fixed = TRUE))) return()

  if (missing(lib) || is.null(lib)) lib <- .libPaths()[[1]]

  lib_pkgs <- list.dirs(lib, full.names = TRUE, recursive = FALSE)
  lib_times <- file.info(lib_pkgs)$mtime
  new_pkgs <- lib_pkgs[lib_times >= timestamp]

  ## Drop all packages whose name appears in a warning
  if (length(warnings)) {
    msgs <- vapply(warnings, conditionMessage, character(1))
    new_pkgs <- Filter(
      function(path) {
        ! any(grepl(basename(path), msgs))
      },
      new_pkgs
    )
  }

  ## Drop all packages without a 'Built' field, or a 'Built' time
  ## that is not after our time stamp
  new_pkgs <- Filter(
    function(path) {
      desc <- file.path(path, "DESCRIPTION")
      if (!file.exists(desc)) return(FALSE)
      dcf <- read.dcf(desc)
      if (! "Built" %in% colnames(dcf)) return(FALSE)
      built <- dcf[, "Built"]
      build_date <- parse_date(strsplit(built, ";")[[1]][3])
      if (is.na(build_date)) return(FALSE)
      build_date >= timestamp
    },
    new_pkgs
  )

  if (!length(new_pkgs)) return()

  dir.create(tmp <- tempfile())
  on.exit(try_silently(unlink(tmp, recursive = TRUE)), add = TRUE)
  withr::with_dir(
    tmp,
    for (pkg in new_pkgs) {
      callr::rcmd("INSTALL", c("--build", "-l", tmp, pkg))
    }
  )

  update_cache_safe(tmp, binaries = FALSE)
}
