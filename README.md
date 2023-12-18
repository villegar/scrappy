
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
rD <- RSelenium::rsDriver(browser = "firefox", port = 4549L, verbose = FALSE)

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
rD <- RSelenium::rsDriver(browser = "firefox", port = 4549L, verbose = FALSE)

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

| id                                   | author    | author_url | comment                                                                                                 | rating | locality    | total_reviews | date_relative | date_absolute           | date_downloaded     |
|:-------------------------------------|:----------|:-----------|:--------------------------------------------------------------------------------------------------------|-------:|:------------|--------------:|:--------------|:------------------------|:--------------------|
| ChZDSUhNMG9nS0VJQ0FnSURWdG9XSVJBEAE  | Author 1  |            | NA                                                                                                      |      5 |             |             2 | 5 days ago    | 2023-12-13 15:17:39 GMT | 2023-12-18 15:17:39 |
| ChZDSUhNMG9nS0VJQ0FnSURWcHZhNkJBEAE  | Author 2  |            | We had a baby shower in the cricket club which was great. Lovely park and good place to walk around in. |      5 |             |            26 | 5 days ago    | 2023-12-13 15:17:39 GMT | 2023-12-18 15:17:39 |
| ChZDSUhNMG9nS0VJQ0FnSUNWNzVhYUtREAE  | Author 3  |            | Great place to take the kids                                                                            |      5 | Local Guide |            22 | a week ago    | 2023-12-11 15:17:39 GMT | 2023-12-18 15:17:39 |
| ChZDSUhNMG9nS0VJQ0FnSUR5OTZ1RkJ3EAE  | Author 4  |            | This is such a lovely place to walk and chill out by the lakes.                                         |      5 | Local Guide |           381 | a week ago    | 2023-12-11 15:17:39 GMT | 2023-12-18 15:17:39 |
| ChZDSUhNMG9nS0VJQ0FnSUNWN2VuT2VREAE  | Author 5  |            | NA                                                                                                      |      5 |             |             9 | a week ago    | 2023-12-11 15:17:39 GMT | 2023-12-18 15:17:39 |
| ChdDSUhNMG9nS0VJQ0FnSUNWaHJXTGdRRRAB | Author 6  |            | Very clean. Lovely area.                                                                                |      5 |             |            26 | a week ago    | 2023-12-11 15:17:39 GMT | 2023-12-18 15:17:39 |
| ChdDSUhNMG9nS0VJQ0FnSUNWb3J5TGhBRRAB | Author 7  |            | NA                                                                                                      |      5 | Local Guide |           104 | a week ago    | 2023-12-11 15:17:39 GMT | 2023-12-18 15:17:39 |
| ChdDSUhNMG9nS0VJQ0FnSURsLS1UaHR3RRAB | Author 8  |            | NA                                                                                                      |      5 |             |            40 | 2 weeks ago   | 2023-12-04 15:17:39 GMT | 2023-12-18 15:17:39 |
| ChdDSUhNMG9nS0VJQ0FnSURsM1kzWndnRRAB | Author 9  |            | Beautiful histoical place and natural environment.                                                      |      5 | Local Guide |            21 | 2 weeks ago   | 2023-12-04 15:17:39 GMT | 2023-12-18 15:17:39 |
| ChZDSUhNMG9nS0VJQ0FnSURsaHNXbEhnEAE  | Author 10 |            | A park for everyone                                                                                     |      5 | Local Guide |            34 | 2 weeks ago   | 2023-12-04 15:17:39 GMT | 2023-12-18 15:17:39 |
| ChdDSUhNMG9nS0VJQ0FnSURsbW9LYWxnRRAB | Author 11 |            | Beautiful park very big and lots of space                                                               |      5 | Local Guide |            10 | 2 weeks ago   | 2023-12-04 15:17:43 GMT | 2023-12-18 15:17:43 |
| ChZDSUhNMG9nS0VJQ0FnSURsd3RydUdBEAE  | Author 12 |            | NA                                                                                                      |      5 |             |             8 | 2 weeks ago   | 2023-12-04 15:17:43 GMT | 2023-12-18 15:17:43 |
| ChdDSUhNMG9nS0VJQ0FnSURsdktUeS13RRAB | Author 13 |            | NA                                                                                                      |      5 | Local Guide |            31 | 2 weeks ago   | 2023-12-04 15:17:43 GMT | 2023-12-18 15:17:43 |
| ChZDSUhNMG9nS0VJQ0FnSURsdExxUmZBEAE  | Author 14 |            | NA                                                                                                      |      4 | NA          |            NA | 2 weeks ago   | 2023-12-04 15:17:43 GMT | 2023-12-18 15:17:43 |
| ChdDSUhNMG9nS0VJQ0FnSURsdUpxc2tRRRAB | Author 15 |            | NA                                                                                                      |      4 |             |             1 | 2 weeks ago   | 2023-12-04 15:17:43 GMT | 2023-12-18 15:17:43 |
| ChdDSUhNMG9nS0VJQ0FnSUNGbmNYRmh3RRAB | Author 16 |            | Lovely place for a walk                                                                                 |      5 | Local Guide |           159 | 2 weeks ago   | 2023-12-04 15:17:43 GMT | 2023-12-18 15:17:43 |
| ChdDSUhNMG9nS0VJQ0FnSUNscDd6VWxBRRAB | Author 17 |            | NA                                                                                                      |      5 |             |            22 | 2 weeks ago   | 2023-12-04 15:17:43 GMT | 2023-12-18 15:17:43 |
| ChdDSUhNMG9nS0VJQ0FnSUNsbV9QNGt3RRAB | Author 18 |            | NA                                                                                                      |      5 | Local Guide |           152 | 2 weeks ago   | 2023-12-04 15:17:43 GMT | 2023-12-18 15:17:43 |
| ChdDSUhNMG9nS0VJQ0FnSUNsNjZXVGdRRRAB | Author 19 |            | Never gets old!                                                                                         |      5 | Local Guide |           101 | 3 weeks ago   | 2023-11-27 15:17:43 GMT | 2023-12-18 15:17:43 |
| ChdDSUhNMG9nS0VJQ0FnSUNsNmVLNm1RRRAB | Author 20 |            | NA                                                                                                      |      3 | NA          |            NA | 3 weeks ago   | 2023-11-27 15:17:43 GMT | 2023-12-18 15:17:43 |

### NHS GP practices by postcode

``` r
# Create RSelenium session
rD <- RSelenium::rsDriver(browser = "firefox", port = 4549L, verbose = FALSE)

# Retrieve GP practices near L69 3GL
# (Waterhouse building, University of Liverpool)
out <- scrappy::find_a_gp(rD$client, postcode = "L69 3GL")

# Stop server
rD$server$stop()
```

| practice_code | org_type | distance | org_name                        | address                                                                        | phone         | map_link                                                                                                                                                                                          | list(coordinates)    | date_downloaded     |
|:--------------|:---------|---------:|:--------------------------------|:-------------------------------------------------------------------------------|:--------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------|:--------------------|
| N82117        | GPB      |      0.1 | Brownlow Group Practice         | Primary Care Resource Centre, 70 Pembroke Place, Liverpool, L69 3GF            | 01512854578   | <https://www.google.com/maps/dir/?api=1&origin=53.406736688787554%2c-2.9684465823857704&destination=Primary+Care+Resource+Centre%2c+70+Pembroke+Place%2c+Liverpool%2c+L69+3GF&t=m>                | 53.406737, -2.968447 | 2023-12-18 15:17:46 |
| N82082        | GPB      |      0.7 | St. James’ Health Centre        | 29 Great George Square, Liverpool, L1 5DZ                                      | 01512953800   | <https://www.google.com/maps/dir/?api=1&origin=53.406736688787554%2c-2.9684465823857704&destination=29+Great+George+Square%2c+Liverpool%2c+L1+5DZ&t=m>                                            | 53.406737, -2.968447 | 2023-12-18 15:17:46 |
| N82022        | GPB      |      0.8 | EDGE HILL HEALTH CENTRE         | 157 Edge Lane, Edge Hill, Liverpool, Merseyside, L7 2AB                        | 01512953600   | <https://www.google.com/maps/dir/?api=1&origin=53.406736688787554%2c-2.9684465823857704&destination=157+Edge+Lane%2c+Edge+Hill%2c+Liverpool%2c+Merseyside%2c+L7+2AB&t=m>                          | 53.406737, -2.968447 | 2023-12-18 15:17:46 |
| N82617        | GPB      |      0.9 | Brownlow at Marybone            | Marybone Health Centre, Unit 1, 2 Vauxhall Road, Liverpool, Merseyside, L3 2BG | 01513308200   | <https://www.google.com/maps/dir/?api=1&origin=53.406736688787554%2c-2.9684465823857704&destination=Marybone+Health+Centre%2c+Unit+1%2c+2+Vauxhall+Road%2c+Liverpool%2c+Merseyside%2c+L3+2BG&t=m> | 53.406737, -2.968447 | 2023-12-18 15:17:46 |
| N82115        | GPB      |      1.1 | Vauxhall Health Centre          | Limekiln Lane, Liverpool, Merseyside, L5 8XR                                   | 01512953737   | <https://www.google.com/maps/dir/?api=1&origin=53.406736688787554%2c-2.9684465823857704&destination=Limekiln+Lane%2c+Liverpool%2c+Merseyside%2c+L5+8XR&t=m>                                       | 53.406737, -2.968447 | 2023-12-18 15:17:46 |
| N82089        | GPB      |      1.2 | Picton Green                    | 137 Earle Road, Liverpool, L7 6HD                                              | 01512953377   | <https://www.google.com/maps/dir/?api=1&origin=53.406736688787554%2c-2.9684465823857704&destination=137+Earle+Road%2c+Liverpool%2c+L7+6HD&t=m>                                                    | 53.406737, -2.968447 | 2023-12-18 15:17:46 |
| N82662        | GPB      |      1.2 | Dunstan Village Group Practice  | Earle Road Medical Centre, 131 Earle Road, Liverpool, Merseyside, L7 6HD       | 01517343535   | <https://www.google.com/maps/dir/?api=1&origin=53.406736688787554%2c-2.9684465823857704&destination=Earle+Road+Medical+Centre%2c+131+Earle+Road%2c+Liverpool%2c+Merseyside%2c+L7+6HD&t=m>         | 53.406737, -2.968447 | 2023-12-18 15:17:46 |
| N82646        | GPB      |      1.4 | Dr Jude’s Practice - Riverside  | Riverside Centre For Health, Park Street, Liverpool, L8 6QP                    | 0151 295 9213 | <https://www.google.com/maps/dir/?api=1&origin=53.406736688787554%2c-2.9684465823857704&destination=Riverside+Centre+For+Health%2c+Park+Street%2c+Liverpool%2c+L8+6QP&t=m>                        | 53.406737, -2.968447 | 2023-12-18 15:17:46 |
| N82091        | GPB      |      1.4 | GP Practice Riverside (Dr Jude) | Riverside Ctr For Health, Park Street, Liverpool, Merseyside, L8 6QP           | 01512959239   | <https://www.google.com/maps/dir/?api=1&origin=53.406736688787554%2c-2.9684465823857704&destination=Riverside+Ctr+For+Health%2c+Park+Street%2c+Liverpool%2c+Merseyside%2c+L8+6QP&t=m>             | 53.406737, -2.968447 | 2023-12-18 15:17:46 |
| N84041        | GPB      |      5.6 | Kingsway Surgery                | 30 Kingsway, Waterloo, Liverpool, Merseyside, L22 4RQ                          | 01519288668   | <https://www.google.com/maps/dir/?api=1&origin=53.406736688787554%2c-2.9684465823857704&destination=30+Kingsway%2c+Waterloo%2c+Liverpool%2c+Merseyside%2c+L22+4RQ&t=m>                            | 53.406737, -2.968447 | 2023-12-18 15:17:46 |
