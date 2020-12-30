
<!-- README.md is generated from README.Rmd. Please edit that file -->

# scrappy: A Simple Web Scraper

<!-- badges: start -->

[![](https://img.shields.io/badge/devel%20version-0.0.0.9000-yellow.svg)](https://github.com/villegar/scrappy)
[![R build
status](https://github.com/villegar/scrappy/workflows/R-CMD-check/badge.svg)](https://github.com/villegar/scrappy/actions)
[![](https://www.r-pkg.org/badges/version/scrappy?color=black)](https://cran.r-project.org/package=scrappy)
<!-- badges: end -->

The goal of scrappy is to provide simple functions to scrape data from
different websites for academic purposes.

## Installation

You can(not) install the released version of scrappy from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("scrappy")
```

And the development version from [GitHub](https://github.com/scrappy)
with:

``` r
# install.packages("devtools")
devtools::install_github("villegar/scrappy")
```

## Example

### NEWA @ Cornell University

The Network for Environment and Weather Applications at Cornell
University. Website: <http://newa.cornell.edu>

``` r
# Create RSelenium session
rD <- RSelenium::rsDriver(browser = "firefox", port = 4548L, verbose = FALSE)

# Call scrappy
scrappy::newa_nrcc(client = rD$client, 
                   year = 2020,
                   month = 12,
                   station = "gbe")
# Stop server
rD$server$stop()
```
