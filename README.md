
<!-- README.md is generated from README.Rmd. Please edit that file -->

# scrappy: A Simple Web Scraper <img src="https://raw.githubusercontent.com/villegar/scrappy/main/inst/images/logo.png" alt="logo" align="right" height=200px/>

<!-- badges: start -->

[![](https://img.shields.io/badge/devel%20version-0.0.1-yellow.svg)](https://github.com/villegar/scrappy)
[![R build
status](https://github.com/villegar/scrappy/workflows/R-CMD-check/badge.svg)](https://github.com/villegar/scrappy/actions)
[![](https://www.r-pkg.org/badges/version/scrappy?color=black)](https://cran.r-project.org/package=scrappy)
<!-- badges: end -->

The goal of scrappy is to provide simple functions to scrape data from
different websites for academic purposes.

## Installation

You can install the released version of scrappy from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("scrappy")
```

And the development version from
[GitHub](https://github.com/villegar/scrappy) with:

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
out <- scrappy::newa_nrcc(client = rD$client, 
                          year = 2020, 
                          month = 12, # December
                          station = "gbe", # Geneve (Bejo) station
                          save_file = FALSE) # Don't save output to a CSV file
# Stop server
rD$server$stop()
#> [1] TRUE
```

Partial output from the previous example:

| Date/Time            | Air Temp (℉) | Precip (inches) | Leaf Wetness (minutes) | RH (%) | Wind Spd (mph) | Wind Dir (degrees) | Solar Rad (langleys) | Dewpoint (℉) | Station |
| :------------------- | -----------: | --------------: | ---------------------: | -----: | -------------: | -----------------: | -------------------: | -----------: | :------ |
| 12/31/2020 23:00 EST |         33.1 |               0 |                      0 |     82 |            2.8 |                264 |                    0 |           28 | gbe     |
| 12/31/2020 22:00 EST |         33.0 |               0 |                      0 |     80 |            3.3 |                250 |                    0 |           28 | gbe     |
| 12/31/2020 21:00 EST |         32.8 |               0 |                      0 |     81 |            2.6 |                261 |                    0 |           28 | gbe     |
| 12/31/2020 20:00 EST |         32.5 |               0 |                      0 |     84 |            1.7 |                277 |                    0 |           28 | gbe     |
| 12/31/2020 19:00 EST |         32.9 |               0 |                      0 |     81 |            2.1 |                279 |                    0 |           28 | gbe     |
| 12/31/2020 18:00 EST |         33.3 |               0 |                      0 |     79 |            3.0 |                272 |                    0 |           28 | gbe     |
| 12/31/2020 17:00 EST |         33.5 |               0 |                      0 |     78 |            3.9 |                274 |                    1 |           27 | gbe     |
| 12/31/2020 16:00 EST |         34.1 |               0 |                      0 |     74 |            4.9 |                272 |                    7 |           27 | gbe     |
| 12/31/2020 15:00 EST |         33.8 |               0 |                      0 |     72 |            7.1 |                277 |                    8 |           26 | gbe     |
| 12/31/2020 14:00 EST |         34.4 |               0 |                      0 |     70 |            7.9 |                276 |                   13 |           26 | gbe     |
