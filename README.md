
<!-- README.md is generated from README.Rmd. Please edit that file -->

# scrappy: A Simple Web Scraper <img src="https://raw.githubusercontent.com/villegar/scrappy/main/inst/images/logo.png" alt="logo" align="right" height=200px/>

<!-- badges: start -->

[![](https://www.r-pkg.org/badges/version/scrappy?color=black)](https://cran.r-project.org/package=scrappy)
[![](https://img.shields.io/badge/devel%20version-0.0.2-yellow.svg)](https://github.com/villegar/scrappy)
[![R build
status](https://github.com/villegar/scrappy/workflows/R-CMD-check/badge.svg)](https://github.com/villegar/scrappy/actions)
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

**NOTE:** To run the following examples on your computer, you need to
download and install Mozilla Firefox
(<https://www.mozilla.org/en-GB/firefox/new/>). Alternatively, you can
replace the value of `browser` in the call to `RSelenium::rsDriver`.

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
                          station = "gbe", # Geneva (Bejo) station
                          save_file = FALSE) # Don't save output to a CSV file
# Stop server
rD$server$stop()
```

Partial output from the previous example:

| Date/Time            | Air Temp (℉) | Precip (inches) | Leaf Wetness (minutes) | RH (%) | Wind Spd (mph) | Wind Dir (degrees) | Solar Rad (langleys) | Dewpoint (℉) | Station |
|:---------------------|-------------:|----------------:|-----------------------:|-------:|---------------:|-------------------:|---------------------:|-------------:|:--------|
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

### Google Maps

Extract the reviews for Sefton Park in Liverpool (only the 20 most
recent):

``` r
# Create RSelenium session
rD <- RSelenium::rsDriver(browser = "firefox", port = 4548L, verbose = FALSE)

# Call scrappy
out <- scrappy::google_maps(client = rD$client,
                            name = "Sefton Park",
                            max_reviews = 20)
# Stop server
rD$server$stop()
```

Output after removing original authors’ names and URL to their profiles:

| id                                   | author    | author_url | comment                                                                                                                                       | rating | locality    | total_reviews | date_relative | date_absolute           | date_downloaded     |
|:-------------------------------------|:----------|:-----------|:----------------------------------------------------------------------------------------------------------------------------------------------|-------:|:------------|--------------:|:--------------|:------------------------|:--------------------|
| ChdDSUhNMG9nS0VJQ0FnSUMtOW8zYXVnRRAB | Author 1  |            |                                                                                                                                               |      5 | Local Guide |             9 | 21 hours ago  | 2022-11-03 20:48:11 GMT | 2022-11-04 17:48:11 |
| ChZDSUhNMG9nS0VJQ0FnSUMtNXJDOGRREAE  | Author 2  |            |                                                                                                                                               |      5 | Local Guide |             3 | a day ago     | 2022-11-03 17:48:11 GMT | 2022-11-04 17:48:11 |
| ChdDSUhNMG9nS0VJQ0FnSUMtcHFPWGtRRRAB | Author 3  |            |                                                                                                                                               |      5 | Local Guide |             7 | a day ago     | 2022-11-03 17:48:11 GMT | 2022-11-04 17:48:11 |
| ChZDSUhNMG9nS0VJQ0FnSUMtcHNpV01BEAE  | Author 4  |            |                                                                                                                                               |      4 | NA          |            NA | 2 days ago    | 2022-11-02 17:48:11 GMT | 2022-11-04 17:48:11 |
| ChZDSUhNMG9nS0VJQ0FnSUMteHVLRlNBEAE  | Author 5  |            | Nice place to take the kids so they can see the Verity of plants and trees.                                                                   |      4 | Local Guide |             7 | 2 days ago    | 2022-11-02 17:48:11 GMT | 2022-11-04 17:48:11 |
| ChdDSUhNMG9nS0VJQ0FnSUMtaHRTTHpRRRAB | Author 6  |            | Beautiful park in Liverpool, with 2 cafes and a playground                                                                                    |      5 | Local Guide |            36 | 2 days ago    | 2022-11-02 17:48:11 GMT | 2022-11-04 17:48:11 |
| ChdDSUhNMG9nS0VJQ0FnSUNpc3VlSGpRRRAB | Author 7  |            | Beautiful idyllic place                                                                                                                       |      5 | Local Guide |            72 | 3 days ago    | 2022-11-01 17:48:11 GMT | 2022-11-04 17:48:11 |
| ChZDSUhNMG9nS0VJQ0FnSURNNXRucGNnEAE  | Author 8  |            | Brilliant park                                                                                                                                |      4 | Local Guide |            27 | 3 days ago    | 2022-11-01 17:48:11 GMT | 2022-11-04 17:48:11 |
| ChZDSUhNMG9nS0VJQ0FnSUMtNnU2clBnEAE  | Author 9  |            | great place to walk and chill out with a bite to eat and a coffee at the cafe around the lake if you are lucky you may spot the parakeets     |      4 | Local Guide |            22 | 3 days ago    | 2022-11-01 17:48:11 GMT | 2022-11-04 17:48:11 |
| ChdDSUhNMG9nS0VJQ0FnSUMtcXN1NDFRRRAB | Author 10 |            |                                                                                                                                               |      5 | Local Guide |             3 | 3 days ago    | 2022-11-01 17:48:11 GMT | 2022-11-04 17:48:11 |
| ChdDSUhNMG9nS0VJQ0FnSUMtcXA2UnZBRRAB | Author 11 |            | Always well kept and always love walking around                                                                                               |      5 | Local Guide |             5 | 3 days ago    | 2022-11-01 17:48:16 GMT | 2022-11-04 17:48:16 |
| ChdDSUhNMG9nS0VJQ0FnSUMtMHFXNHFnRRAB | Author 12 |            |                                                                                                                                               |      5 | Local Guide |            99 | 4 days ago    | 2022-10-31 17:48:16 GMT | 2022-11-04 17:48:16 |
| ChZDSUhNMG9nS0VJQ0FnSUMtb3BHTFVBEAE  | Author 13 |            |                                                                                                                                               |      5 | Local Guide |             4 | 5 days ago    | 2022-10-30 17:48:16 GMT | 2022-11-04 17:48:16 |
| ChdDSUhNMG9nS0VJQ0FnSUMtd3BQSWpRRRAB | Author 14 |            | Loved it. Big, fun. Plenty of space for different activities                                                                                  |      5 | Local Guide |            99 | 5 days ago    | 2022-10-30 17:48:16 GMT | 2022-11-04 17:48:16 |
| ChZDSUhNMG9nS0VJQ0FnSUMtdkp6OGNREAE  | Author 15 |            | Really nice to see every one happy it lifted my spirits.thankyou all                                                                          |      5 | Local Guide |             1 | 5 days ago    | 2022-10-30 17:48:16 GMT | 2022-11-04 17:48:16 |
| ChZDSUhNMG9nS0VJQ0FnSUNHOFA2T0ZnEAE  | Author 16 |            |                                                                                                                                               |      5 | Local Guide |            46 | 6 days ago    | 2022-10-29 18:48:16 BST | 2022-11-04 17:48:16 |
| ChZDSUhNMG9nS0VJQ0FnSUMtak9teE93EAE  | Author 17 |            | (Translated by Google) A very well-kept park (Original) Bardzo zadbany park                                                                   |      5 | Local Guide |           225 | a week ago    | 2022-10-28 18:48:16 BST | 2022-11-04 17:48:16 |
| ChdDSUhNMG9nS0VJQ0FnSUMtOUx1ODdBRRAB | Author 18 |            | Beautiful place to visit or have a walk                                                                                                       |      5 | Local Guide |           155 | a week ago    | 2022-10-28 18:48:16 BST | 2022-11-04 17:48:16 |
| ChdDSUhNMG9nS0VJQ0FnSUMwcnBicy13RRAB | Author 19 |            | One of the liverpool best park. With kids play area, coffee shop, tennis courts, fountains a stream and much more to enjoy.                   |      5 | Local Guide |           365 | a week ago    | 2022-10-28 18:48:16 BST | 2022-11-04 17:48:16 |
| ChdDSUhNMG9nS0VJQ0FnSUMtbEtxdjNBRRAB | Author 20 |            | Love a visit round Sefton Park. Everytime of year it looks great and it’s a perfect place for a walk, jog, bike ride or meet up with friends. |      5 | Local Guide |            29 | a week ago    | 2022-10-28 18:48:16 BST | 2022-11-04 17:48:16 |
