
context("download_files")

test_that("downloads and etags", {

  skip_if_offline()
  dir.create(tmp <- tempfile())
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  dl <- structure(
    list("https://httpbin.org/etag/etag-x1",
         "https://httpbin.org/etag/etag-x2"),
    names = file.path(tmp, c("x1", "x2"))
  )

  expect_equal(
    get_etags_for_downloads(dl),
    list(NA_character_, NA_character_)
  )

  skip_if_download_errors(download_files(dl))

  expect_equal(file.exists(names(dl)), c(TRUE, TRUE))
  expect_equal(
    get_etags_for_downloads(dl),
    list("etag-x1", "etag-x2")
  )
})

test_that("alternative urls", {

  skip_if_offline()
  dir.create(tmp <- tempfile())

  dl <- structure(
    list(c("https://httpbin.org/status/404",
           "https://httpbin.org/etag/etag-x1"),
         c("https://httpbin.org/status/403",
           "https://httpbin.org/etag/etag-x2")),
    names = file.path(tmp, c("x1", "x2"))
  )

  expect_equal(
    get_etags_for_downloads(dl),
    list(c(NA_character_, NA_character_), c(NA_character_, NA_character_))
  )

  skip_if_download_errors(download_files(dl))

  expect_equal(file.exists(names(dl)), c(TRUE, TRUE))
  expect_equal(
    get_etags_for_downloads(dl),
    list(c("etag-x1", "etag-x1"), c("etag-x2", "etag-x2"))
  )
})

test_that("alternative target files", {

  skip_if_offline()
  dir.create(tmp <- tempfile())

  dl <- list(
    structure(c("https://httpbin.org/status/404",
                "https://httpbin.org/etag/etag-x1"),
              names = file.path(tmp, c("x1bad", "x1"))),
    structure(c("https://httpbin.org/status/403",
                "https://httpbin.org/etag/etag-x2"),
              names = file.path(tmp, c("x2bad", "x2")))
  )

  expect_equal(
    get_etags_for_downloads(dl),
    list(c(NA_character_, NA_character_), c(NA_character_, NA_character_))
  )

  skip_if_download_errors(download_files(dl))

  expect_false(file.exists(names(dl[[1]])[1]))
  expect_false(file.exists(names(dl[[2]])[1]))
  expect_true (file.exists(names(dl[[1]])[2]))
  expect_true (file.exists(names(dl[[2]])[2]))
  expect_equal(
    get_etags_for_downloads(dl),
    list(c(NA_character_, "etag-x1"), c(NA_character_, "etag-x2"))
  )
})

test_that("redirects", {

  skip_if_offline()
  dir.create(tmp <- tempfile())
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  dl <- structure(
    list("https://httpbin.org/redirect-to?url=https%3A%2F%2Fhttpbin.org%2Fetag%2Fetag-x1",
         "https://httpbin.org/etag/etag-x2"),
    names = file.path(tmp, c("x1", "x2"))
  )

  expect_equal(
    get_etags_for_downloads(dl),
    list(NA_character_, NA_character_)
  )

  skip_if_download_errors(download_files(dl))

  expect_equal(file.exists(names(dl)), c(TRUE, TRUE))
  expect_equal(
    get_etags_for_downloads(dl),
    list("etag-x1", "etag-x2")
  )
})

test_that("empty url list does nothing", {

  dir.create(tmp <- tempfile())
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  dl <- structure(
    list(character(), character()),
    names = file.path(tmp, c("x1", "x2"))
  )

  expect_equal(get_etags_for_downloads(dl), list(character(), character()))

  res <- download_files(dl)
  expect_true(is_download_error(res[[1]]))
  expect_true(is_download_error(res[[2]]))

  expect_equal(file.exists(names(dl)), c(FALSE, FALSE))
  expect_equal(get_etags_for_downloads(dl), list(character(), character()))
})
