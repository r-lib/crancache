
# crancache

> Transparent Caching of Packages from CRAN-like Repositories

[![Linux Build Status](https://travis-ci.org/r-hub/crancache.svg?branch=master)](https://travis-ci.org/r-hub/crancache)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/r-hub/crancache?svg=true)](https://ci.appveyor.com/project/gaborcsardi/crancache)
[![](http://www.r-pkg.org/badges/version/crancache)](http://www.r-pkg.org/pkg/crancache)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/crancache)](http://www.r-pkg.org/pkg/crancache)

Provides a wrapper for 'install.packages()', that transparently caches
downloaded packages in a local CRAN-like repository.

## Installation

```r
source("https://install-github.me/r-hub/crancache")
```

## Usage

```r
library(crancache)
```

Just load the package and call the `install.packages()`,
`update.packages()` or `download_packages()` functions. `crancache`
automatically sets up the cache in the user's operating system dependent
cache directory, and uses it whenever it is possible. In particular:

* If the requrest version of a package (usually the newest version) is
  available from the cache, then the cache is used, without downloading it
  (again). 
* If a package is not in the cache, or the version in the cache is
  outdated, it downloads it and adds it to the cache.

## Example session

For this example, we clean the cache first. In practice you almost never
need to clean the cache manually.

```r
crancache_clean()
```

We set up a new package library, and install some packages in it.
After installation, they will be added to the cache.

```r
dir.create(lib <- tempfile())
.libPaths(lib)
system.time(install.packages("tidyverse"))
```

```
#> Installing package into ‘/private/var/folders/ws/7rmdm_cn2pd8l1c3lqyycv0c0000gn/T/RtmppR97sc/file16f684a4c4c95’
#> (as ‘lib’ is unspecified)
#> also installing the dependencies ‘colorspace’, ‘mnormt’, ‘RColorBrewer’,
#> ‘dichromat’, ‘munsell’, ‘labeling’, ‘plyr’, ‘psych’, ‘reshape2’,
#> ‘assertthat’, ‘R6’, ‘Rcpp’, ‘lazyeval’, ‘DBI’, ‘BH’, ‘gtable’,
#> ‘scales’, ‘mime’, ‘curl’, ‘openssl’, ‘stringi’, ‘selectr’, ‘broom’,
#> ‘dplyr’, ‘forcats’, ‘ggplot2’, ‘haven’, ‘httr’, ‘hms’, ‘jsonlite’,
#> ‘lubridate’, ‘magrittr’, ‘modelr’, ‘purrr’, ‘readr’, ‘readxl’,
#> ‘stringr’, ‘tibble’, ‘rvest’, ‘tidyr’, ‘xml2’
#> 
#> trying URL 'https://cran.rstudio.com/bin/macosx/mavericks/contrib/3.3/colorspace_1.3-2.tgz'
#> Content type 'application/x-gzip' length 432604 bytes (422 KB)
#> ==================================================
#> downloaded 422 KB
#> 
#> trying URL 'https://cran.rstudio.com/bin/macosx/mavericks/contrib/3.3/mnormt_1.5-5.tgz'
#> Content type 'application/x-gzip' length 89235 bytes (87 KB)
#> ==================================================
#> downloaded 87 KB
...
.rstudio.com/bin/macosx/mavericks/contrib/3.3/tidyverse_1.1.1.tgz'
Content type 'application/x-gzip' length 37228 bytes (36 KB)
==================================================
downloaded 36 KB


The downloaded binary packages are in
	/var/folders/ws/7rmdm_cn2pd8l1c3lqyycv0c0000gn/T//RtmppR97sc/downloaded_packages
Adding ‘assertthat_0.1.tgz’ to the cache
Adding ‘BH_1.62.0-1.tgz’ to the cache
Adding ‘broom_0.4.2.tgz’ to the cache
Adding ‘colorspace_1.3-2.tgz’ to the cache
Adding ‘curl_2.3.tgz’ to the cache
Adding ‘DBI_0.6-1.tgz’ to the cache
Adding ‘dichromat_2.0-0.tgz’ to the cache
Adding ‘dplyr_0.5.0.tgz’ to the cache
Adding ‘forcats_0.2.0.tgz’ to the cache
Adding ‘ggplot2_2.2.1.tgz’ to the cache
Adding ‘gtable_0.2.0.tgz’ to the cache
Adding ‘haven_1.0.0.tgz’ to the cache
Adding ‘hms_0.3.tgz’ to the cache
Adding ‘httr_1.2.1.tgz’ to the cache
Adding ‘jsonlite_1.4.tgz’ to the cache
Adding ‘labeling_0.3.tgz’ to the cache
Adding ‘lazyeval_0.2.0.tgz’ to the cache
Adding ‘lubridate_1.6.0.tgz’ to the cache
Adding ‘magrittr_1.5.tgz’ to the cache
Adding ‘mime_0.5.tgz’ to the cache
Adding ‘mnormt_1.5-5.tgz’ to the cache
Adding ‘modelr_0.1.0.tgz’ to the cache
Adding ‘munsell_0.4.3.tgz’ to the cache
Adding ‘openssl_0.9.6.tgz’ to the cache
Adding ‘plyr_1.8.4.tgz’ to the cache
Adding ‘psych_1.7.3.21.tgz’ to the cache
Adding ‘purrr_0.2.2.tgz’ to the cache
Adding ‘R6_2.2.0.tgz’ to the cache
Adding ‘RColorBrewer_1.1-2.tgz’ to the cache
Adding ‘Rcpp_0.12.10.tgz’ to the cache
Adding ‘readr_1.1.0.tgz’ to the cache
Adding ‘readxl_0.1.1.tgz’ to the cache
Adding ‘reshape2_1.4.2.tgz’ to the cache
Adding ‘rvest_0.3.2.tgz’ to the cache
Adding ‘scales_0.4.1.tgz’ to the cache
Adding ‘selectr_0.3-1.tgz’ to the cache
Adding ‘stringi_1.1.5.tgz’ to the cache
Adding ‘stringr_1.2.0.tgz’ to the cache
Adding ‘tibble_1.3.0.tgz’ to the cache
Adding ‘tidyr_0.6.1.tgz’ to the cache
Adding ‘tidyverse_1.1.1.tgz’ to the cache
Adding ‘xml2_1.1.1.tgz’ to the cache
   user  system elapsed
 16.583   4.156  87.581
```

At the end of the installation these packages are added to the cache:

```
crancache_list()
```

```
#> $`/Users/gaborcsardi/Library/Caches/R-crancache/bin/macosx/mavericks/contrib/3.3`
#>         Package  Version                           MD5sum
#> 1    assertthat      0.1 1224abccd335fdde83c4ccf351f3b105
#> 2            BH 1.62.0-1 06d1c3d59d8d7c5972bc06b2e6a2d26b
#> 3         broom    0.4.2 46455afbd480dbd73fa04fff79961dd8
#> 4    colorspace    1.3-2 4bc7bdac8b389f38faf62ad0c7defbf9
#> 5          curl      2.3 66da2a69d6499a8375e1982e81f4774b
#> 6           DBI    0.6-1 42524e874e39207139ca11ab64a0d241
#> 7     dichromat    2.0-0 c282dd735bb5ddaac9a2541d68736df2
#> 8         dplyr    0.5.0 744b169c9fe6ffa5909abb4ab3015e3e
#> 9       forcats    0.2.0 30f99cf49d4942ad53e54945f504df86
#> 10      ggplot2    2.2.1 5a3cfa734f17b35e409ca250d23105b8
#> 11       gtable    0.2.0 d43a89a2305a7f2eb9f6601712b1a89f
#> 12        haven    1.0.0 cb3a43af05d237de9ce058cd85607f45
#> 13          hms      0.3 c01daf00b612636dd936e49056b51282
#> 14         httr    1.2.1 25d387091cb912484108b2f493edbd89
#> 15     jsonlite      1.4 352874e225ce3a7183d39794f2a2f21d
#> 16     labeling      0.3 986e3a33b9ec407f2490f27dad0209d7
#> 17     lazyeval    0.2.0 a184f215a601249145f2069652d8d574
#> 18    lubridate    1.6.0 ecc257d783076177fa9971e041f4a7f7
#> 19     magrittr      1.5 a46576a03a0441cdbb1a6ff5c1a74c41
#> 20         mime      0.5 324a147ccb700960dacefdc2169b1db6
#> 21       mnormt    1.5-5 93d6d35c41ac0f28f95f3840d423b806
#> 22       modelr    0.1.0 1be1047896c64e836431c46b3532145b
#> 23      munsell    0.4.3 777dc0e864aa93e6a7e21dbb9ffc1782
#> 24      openssl    0.9.6 646af29dd64e2ed54049fc4b5aabf79c
#> 25         plyr    1.8.4 25fdcd875af2db7b23a98e385c407fd5
#> 26        psych 1.7.3.21 db91e624d5432cfab48d3aad0a8df822
#> 27        purrr    0.2.2 cfc62eaa6a02a02a901eeed65282f639
#> 28           R6    2.2.0 b073f9206d33a6fbd4c622ee097019f8
#> 29 RColorBrewer    1.1-2 15c2b4b421a9aaf82f332d229a044636
#> 30         Rcpp  0.12.10 ea29e3b8361f7992ed1d0d8f13cb09c7
#> 31        readr    1.1.0 f7f0b88c55fe1512338c11246cbbb059
#> 32       readxl    0.1.1 85aa4504d877def89e3175d9acd70dc5
#> 33     reshape2    1.4.2 88ca91299fa40ac37884a75bc8968f05
#> 34        rvest    0.3.2 d2e04a555653ed4cf7219773c2846c63
#> 35       scales    0.4.1 56112f85d50f900c7cfa5362e6c60264
#> 36      selectr    0.3-1 f67f87b3eefaa7f89e823e167192947b
#> 37      stringi    1.1.5 60ac663680eb51f23e9679bd6c672ec0
#> 38      stringr    1.2.0 bc4c3aad2725cdb6027edc8287ee3bda
#> 39       tibble    1.3.0 547682025168a43fd31be2d149b71075
#> 40        tidyr    0.6.1 72e9db39b8580d71f23847bdc2500c39
#> 41    tidyverse    1.1.1 196e404a10ec3709297ccb45013d6e99
#> 42         xml2    1.1.1 3155d4639a0bad5a78afaa286591c1b1
```

The next time these package files are needed, `install.packages()` will
use the cached versions:

```
dir.create(lib <- tempfile())
.libPaths(lib)
system.time(install.packages("tidyverse"))
```

```
system.time(install.packages("tidyverse"))
```

```
#> Installing package into ‘/private/var/folders/ws/7rmdm_cn2pd8l1c3lqyycv0c0000gn/T/RtmppR97sc/file16f684a4c4c95’
#> (as ‘lib’ is unspecified)
#> also installing the dependencies ‘colorspace’, ‘mnormt’, ‘RColorBrewer’,
#> ‘dichromat’, ‘munsell’, ‘labeling’, ‘plyr’, ‘psych’, ‘reshape2’,
#> ‘assertthat’, ‘R6’, ‘Rcpp’, ‘lazyeval’, ‘DBI’, ‘BH’, ‘gtable’,
#> ‘scales’, ‘mime’, ‘curl’, ‘openssl’, ‘stringi’, ‘selectr’, ‘broom’,
#> ‘dplyr’, ‘forcats’, ‘ggplot2’, ‘haven’, ‘httr’, ‘hms’, ‘jsonlite’,
#> ‘lubridate’, ‘magrittr’, ‘modelr’, ‘purrr’, ‘readr’, ‘readxl’,
#> ‘stringr’, ‘tibble’, ‘rvest’, ‘tidyr’, ‘xml2’
#>
#> The downloaded binary packages are in
#> 	/var/folders/ws/7rmdm_cn2pd8l1c3lqyycv0c0000gn/T//RtmppR97sc/downloaded_packages
#>    user  system elapsed
#>   2.083   2.899   7.818
```
  
## License

MIT © Gábor Csárdi
