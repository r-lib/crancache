
is_crancache_active <- function() {
  Sys.getenv("CRANCACHE_DISABLE", "") == ""
}
