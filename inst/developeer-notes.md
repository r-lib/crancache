
## Caching binaries

This is tricky:

* `R CMD INSTALL` has a `--build` argument, but that puts the output
  file in the current working directory, and we might overwrite something
  there, so we don't want this.
* Working out whether an installation (and a binary build) failed or not,
  is hard. `utils::install.packages` does not work us a lot in this
  respect, because it only gives warnings for failed installs.
* If we get a warning, then something has failed, but it is hard to work
  out what exactly.
* Even if an installation succeeeds, the user might have used
  `--no-test-load`, and then the actual binary might be broken.
* It is hard to work out the packages that were installed. E.g. if the
  source package is coming from the cache, then it will not be in
  `downloaded_packages`.

Even if we don't use `--build`, but create the binary package archive
manually, we need to know which installs fails, because we don not want
to package up those.

So here is a plan:

* If the `--no-test-load` argument is included in `INSTALL_opts`, then
  we do not deal with binary packages at all. (Possibly, some other
  arguments could be treated the same, e.g. `--fake`.)
* We catch warnings and errors from `utils::install.packages`. (We also
  re-throw them.)
* We work out the `lib` directory where the new packages were installed.
* If we installed from source, then in the library, the file modification
  dates should be updated. So we check all directories in the library, that
  have a more recent modification date, than the `install_packages`
  invocation, and these will be our candidates to package up.
* If we got warnings, and the name of a package matches the warning
  (simple matching, stupid, but we want to be conservative), then that
  package is ignored.
* The chosen packages are packaged up and added to the cache.
