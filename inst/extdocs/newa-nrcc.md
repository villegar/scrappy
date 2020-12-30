
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

Post-processing: combine individual CSV files by station name:

``` r
stations <- c("acc", "kalb", "alb")
states <- c("NY", "NY", "NY")
for (s in seq_len(length(stations))) {
  st <- stations[s]
  message("Processing: ", st)
  files <- list.files(outputdir, pattern = st, full.names = TRUE)
  if (length(files) > 0) {
    message(length(files), " files found...")
    combined_data <- NULL
    for(f in files) {
      aux <- read.csv(f)
      if (is.null(combined_data)) {
        combined_data <- aux
      } else {
        combined_data <- rbind(combined_data, aux)
      }
    }
    combined_data$State <- states[s]
    write.csv(combined_data, paste0(st, ".csv"), row.names = FALSE)
  }
}
```

#### Bonus

List the station names:

``` r
# Import pipe
`%>%` <- scrappy::`%>%`

# Create RSelenium session
rD <- RSelenium::rsDriver(browser = "firefox", port = 4548L, verbose = FALSE)

rD$client$navigate("http://newa.cornell.edu/index.php?page=station-pages")
Sys.sleep(5)
aux <- rD$client$getPageSource()[[1]] %>%
    xml2::read_html() %>% # parse HTML
    rvest::html_nodes("table.table") 

station_code <- aux %>% 
  rvest::html_nodes("a") %>%
  rvest::html_attr("href") %>%
  gsub(pattern = ".*=", replacement = "")

stations <- aux %>%
  rvest::html_table(header = TRUE) %>%
  as.data.frame() %>%
  tidyr::separate(col = 1, into = c("name", "state"), sep = ",")
stations$code <- station_code

# Stop server
rD$server$stop()
```

    ## [1] TRUE

| name          | state | code    |
| :------------ | :---- | :------ |
| Accord        | NY    | acc     |
| Aetna/Fremont | MI    | ew\_aet |
| Afton         | MN    | mn\_aft |
| Akron/Canton  | OH    | kcak    |
| Albany        | NY    | kalb    |
| Albion        | NY    | alb     |
| Albion        | MI    | ew\_alb |
| Allegan       | MI    | ew\_alg |
| Allentown     | PA    | kabe    |
| Alpena (AP)   | MI    | kapn    |
