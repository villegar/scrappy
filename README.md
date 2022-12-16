
<!-- README.md is generated from README.Rmd. Please edit that file -->

# scrappy: A Simple Web Scraper <img src="https://raw.githubusercontent.com/villegar/scrappy/main/inst/images/logo.png" alt="logo" align="right" height=200px/>

<!-- badges: start -->

[![](https://www.r-pkg.org/badges/version/scrappy?color=black)](https://cran.r-project.org/package=scrappy)
[![](https://img.shields.io/badge/devel%20version-0.0.3-yellow.svg)](https://github.com/villegar/scrappy)
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
out <- scrappy::newa_nrcc(
  client = rD$client,
  year = 2020,
  month = 12, # December
  station = "gbe", # Geneva (Bejo) station
  save_file = FALSE
) # Don't save output to a CSV file
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
out <- scrappy::google_maps(
  client = rD$client,
  name = "Sefton Park",
  max_reviews = 20
)
# Stop server
rD$server$stop()
```

Output after removing original authors’ names and URL to their profiles:

| id                                   | author    | author_url | comment                                                                                                                                                                                                                                                                      | rating | locality    | total_reviews | date_relative | date_absolute           | date_downloaded     |
|:-------------------------------------|:----------|:-----------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------:|:------------|--------------:|:--------------|:------------------------|:--------------------|
| ChZDSUhNMG9nS0VJQ0FnSUNCcUxlU1RREAE  | Author 1  |            |                                                                                                                                                                                                                                                                              |      4 | Local Guide |            19 | 6 hours ago   | 2022-12-16 03:08:37 GMT | 2022-12-16 09:08:37 |
| ChdDSUhNMG9nS0VJQ0FnSUNCOE1PRTN3RRAB | Author 2  |            |                                                                                                                                                                                                                                                                              |      5 | Local Guide |             5 | 20 hours ago  | 2022-12-15 13:08:38 GMT | 2022-12-16 09:08:38 |
| ChdDSUhNMG9nS0VJQ0FnSUNCa0xlbGxBRRAB | Author 3  |            |                                                                                                                                                                                                                                                                              |      5 | NA          |            NA | a day ago     | 2022-12-15 09:08:38 GMT | 2022-12-16 09:08:38 |
| ChZDSUhNMG9nS0VJQ0FnSURPanBDUVVREAE  | Author 4  |            | Cold and icy but still brilliant.. The local parakeets are still there by the lake, freezing their feathers off.                                                                                                                                                             |      5 | Local Guide |             9 | a day ago     | 2022-12-15 09:08:38 GMT | 2022-12-16 09:08:38 |
| ChdDSUhNMG9nS0VJQ0FnSUQtci0yd2hRRRAB | Author 5  |            | Great place for long walks, running and having your kids and dogs all around this natural beauty !                                                                                                                                                                           |      5 | Local Guide |            10 | 3 days ago    | 2022-12-13 09:08:38 GMT | 2022-12-16 09:08:38 |
| ChZDSUhNMG9nS0VJQ0FnSUNpLXJpWE53EAE  | Author 6  |            | Amazing city park, great to walk in and around. You can even spend the whole day there with your family having a BBQ. Two cafes and lots of great walks and lakes and streams. Africa Oye also uses the park as its venue as well as lots of other events. World class park. |      5 | Local Guide |           105 | 3 days ago    | 2022-12-13 09:08:38 GMT | 2022-12-16 09:08:38 |
| ChZDSUhNMG9nS0VJQ0FnSUQtbDRmMkJnEAE  | Author 7  |            | (Translated by Google) Nice to come and stroll in the park to forget the city (Original) Sympa pour venir flâner dans le parc pour oublier la ville                                                                                                                          |      5 | Local Guide |            51 | 4 days ago    | 2022-12-12 09:08:38 GMT | 2022-12-16 09:08:38 |
| ChZDSUhNMG9nS0VJQ0FnSUQtbDVhWVd3EAE  | Author 8  |            | Lovely park.                                                                                                                                                                                                                                                                 |      5 | Local Guide |            12 | 4 days ago    | 2022-12-12 09:08:38 GMT | 2022-12-16 09:08:38 |
| ChZDSUhNMG9nS0VJQ0FnSUQtNl9uZVFBEAE  | Author 9  |            |                                                                                                                                                                                                                                                                              |      5 | Local Guide |            17 | 6 days ago    | 2022-12-10 09:08:38 GMT | 2022-12-16 09:08:38 |
| ChdDSUhNMG9nS0VJQ0FnSUQtNjlIdHh3RRAB | Author 10 |            |                                                                                                                                                                                                                                                                              |      5 | Local Guide |             4 | 6 days ago    | 2022-12-10 09:08:38 GMT | 2022-12-16 09:08:38 |
| ChZDSUhNMG9nS0VJQ0FnSURVbWZydlF3EAE  | Author 11 |            | Lovely walks around park with lots to show children as well. Ending up with tea in the Palm House.                                                                                                                                                                           |      5 | Local Guide |           174 | a week ago    | 2022-12-09 09:08:39 GMT | 2022-12-16 09:08:39 |
| ChZDSUhNMG9nS0VJQ0FnSUQtM2VYSmN3EAE  | Author 12 |            |                                                                                                                                                                                                                                                                              |      5 | Local Guide |             8 | a week ago    | 2022-12-09 09:08:39 GMT | 2022-12-16 09:08:39 |
| ChdDSUhNMG9nS0VJQ0FnSURNcDZEN21BRRAB | Author 13 |            |                                                                                                                                                                                                                                                                              |      5 | Local Guide |            10 | a week ago    | 2022-12-09 09:08:39 GMT | 2022-12-16 09:08:39 |
| ChZDSUhNMG9nS0VJQ0FnSUQtN2FqS0RBEAE  | Author 14 |            |                                                                                                                                                                                                                                                                              |      4 | Local Guide |            21 | a week ago    | 2022-12-09 09:08:39 GMT | 2022-12-16 09:08:39 |
| ChZDSUhNMG9nS0VJQ0FnSUQtdGVuTVBnEAE  | Author 15 |            |                                                                                                                                                                                                                                                                              |      5 | Local Guide |            35 | a week ago    | 2022-12-09 09:08:39 GMT | 2022-12-16 09:08:39 |
| ChZDSUhNMG9nS0VJQ0FnSUQteGNhcmZBEAE  | Author 16 |            |                                                                                                                                                                                                                                                                              |      5 | Local Guide |           463 | a week ago    | 2022-12-09 09:08:39 GMT | 2022-12-16 09:08:39 |
| ChZDSUhNMG9nS0VJQ0FnSUQtbWZ1QkZREAE  | Author 17 |            | Very nice park. Lots of space for family and play areas for kids.                                                                                                                                                                                                            |      5 | Local Guide |             2 | a week ago    | 2022-12-09 09:08:39 GMT | 2022-12-16 09:08:39 |
| ChZDSUhNMG9nS0VJQ0FnSUQtcVppTFl3EAE  | Author 18 |            |                                                                                                                                                                                                                                                                              |      5 | Local Guide |             2 | a week ago    | 2022-12-09 09:08:39 GMT | 2022-12-16 09:08:39 |
| ChZDSUhNMG9nS0VJQ0FnSUQtM3JiQVNBEAE  | Author 19 |            |                                                                                                                                                                                                                                                                              |      5 | Local Guide |            34 | 2 weeks ago   | 2022-12-02 09:08:39 GMT | 2022-12-16 09:08:39 |
| ChZDSUhNMG9nS0VJQ0FnSUQtem9qWkNBEAE  | Author 20 |            |                                                                                                                                                                                                                                                                              |      5 | Local Guide |            21 | 2 weeks ago   | 2022-12-02 09:08:39 GMT | 2022-12-16 09:08:39 |
