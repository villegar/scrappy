
## NEWA @ Cornell

Create all possible combinations of station-year-month:

``` r
stations <- c("acc", "kalb", "alb")
years <- 2015:2020
months <- 1:12

combinations <- data.frame(station = rep(stations, each = length(years) * length(months)),
                           year = rep(years, each = length(months)),
                           month = months,
                           downloaded = FALSE)

knitr::kable(head(combinations, 10))
```

| station | year | month | downloaded |
| :------ | ---: | ----: | :--------- |
| acc     | 2015 |     1 | FALSE      |
| acc     | 2015 |     2 | FALSE      |
| acc     | 2015 |     3 | FALSE      |
| acc     | 2015 |     4 | FALSE      |
| acc     | 2015 |     5 | FALSE      |
| acc     | 2015 |     6 | FALSE      |
| acc     | 2015 |     7 | FALSE      |
| acc     | 2015 |     8 | FALSE      |
| acc     | 2015 |     9 | FALSE      |
| acc     | 2015 |    10 | FALSE      |

Create RSelenium session

``` r
# Create RSelenium session
rD <- RSelenium::rsDriver(browser = "firefox", port = 4548L, verbose = FALSE)
```

Retrieve data

``` r
# Path to the output directory
outputdir <- getwd()

# Create progress bar
pb <- progress::progress_bar$new(
    format = "(:current/:total) [:bar] :percent",
    total = nrow(combinations), clear = FALSE, width = 80)
for (i in seq_len(nrow(combinations))) {
  tryCatch({
    # Check if the data has been downloaded
    if (!combinations$downloaded[i]) {
      # Call scrappy
      scrappy::newa_nrcc(client = rD$client, 
                         year = combinations$year[i],
                         month = combinations$month[i],
                         station = combinations$station[i], 
                         path = outputdir)
      combinations$downloaded[i] <- TRUE
    }
  }, error = function(e) {
    message("Error processing combination with index ", i)
    warning(e)
  })
  # Update progress bar
  pb$tick()
}

# Stop server
rD$server$stop()
```
