#' Retrieve data from NEWA at Cornell University
#'
#' Retrieve Weather data from the Network for Environment and Weather
#' Applications (NEWA) at Cornell University.
#'
#' @importFrom utils write.csv
#'
#' @param client \code{RSelenium} client.
#' @param year Numeric value with the year.
#' @param month Numeric value with the month.
#' @param station String with the station abbreviation. Check the
#' \url{http://newa.cornell.edu/index.php?page=station-pages} for a list.
#' @param base Base URL
#'     (default: \url{http://newa.nrcc.cornell.edu/newaLister}).
#' @param interval String with data interval (default: hly, hourly).
#' @param sleep Numeric value with the number of seconds to wait for the page
#'     to load the results (default: 6 seconds).
#' @param table_id String with the unique HTML ID assigned to the table
#'     containing the data (default: \code{#dtable})
#' @param path String with path to location where CSV files should be stored
#'     (default: \code{getwd()}).
#' @param save_file Boolean flag to indicate whether or not the output should
#'     be stored as a CSV file.
#'
#' @return Tibble with the data retrieved from the server.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Create RSelenium session
#' rD <- RSelenium::rsDriver(browser = "firefox", port = 4544L, verbose = FALSE)
#' # Retrieve data for the Geneva (Bejo) station on 2020/12
#' scrappy::newa_nrcc(rD$client, 2020, 12, "gbe")
#' # Stop server
#' rD$server$stop()
#' }
newa_nrcc <- function(client,
                      year,
                      month,
                      station,
                      base = "http://newa.nrcc.cornell.edu/newaLister",
                      interval = "hly",
                      sleep = 6,
                      table_id = "#dtable",
                      path = getwd(),
                      save_file = TRUE) {
  # Local binding
  . <- NULL
  # Navigate to website
  client$navigate(paste(base, interval, station, year, month, sep = "/"))
  # Wait for the website to load
  Sys.sleep(sleep)
  # Create output filename
  file <- paste0(station, "-", interval, "-", year, "-", month, ".csv")
  file <- file.path(path, file)
  # Create node ID
  node <- paste0("table", table_id)
  # Parse HTML code and save CSV file
  out <- client$getPageSource()[[1]] %>%
    xml2::read_html() %>% # parse HTML
    rvest::html_nodes(node) %>% # extract table node
    rvest::html_table(fill = TRUE)
  original_names <- c(names(out[[1]]), "Station")
  out <- as.data.frame(out)
  out$station <- station
  colnames(out) <- original_names
  if (save_file)
    write.csv(out, file, row.names = FALSE)
  invisible(out)
}

#' Retrieve data from NEWA v3.0 at Cornell University
#'
#' Retrieve Weather data from the Network for Environment and Weather
#' Applications (NEWA) version 3.0 at Cornell University.
#'
#' @param year Numeric value with the start year.
#' @param month Numeric value with the start month.
#' @param day Numeric value with the start day.
#' @param hour Numeric value with the start hour.
#' @param station String with the station abbreviation.
#' @param base Base URL
#'     (default: \url{https://hrly.nrcc.cornell.edu/stnHrly}).
# @param path String with path to location where CSV files should be stored
#     (default: \code{getwd()}).
# @param save_file Boolean flag to indicate whether or not the output should
#'     be stored as a CSV file.
#'
#' @return List of data frames with \code{hourly}, \code{daily},
#'     \code{forecast}, and daily forecast (\code{daily_forecast}) data.
#' @export
#'
#' @examples
#' newa_nrcc3(2021, 12, 01, 00, "gbe")
newa_nrcc3 <- function(year,
                       month,
                       day,
                       hour,
                       station,
                       base = "https://hrly.nrcc.cornell.edu/stnHrly"#,
                       # path = getwd(),
                       # save_file = TRUE
                       ) {
  # Local binding
  pad_zeros <- function(val, digits = 2) {
    if(nchar(val) == digits) return(val)
    return(pad_zeros(paste0("0", val), digits))
  }
  body <- paste0('{\n',
                 '"sid": "', station, ' newa",\n',
                 '"sdate": "',
                 pad_zeros(year, 4),
                 pad_zeros(month, 2),
                 pad_zeros(day, 2),
                 pad_zeros(hour, 2),
                 '",\n',
                 '"edate": "now"\n}\n\n')
  # cat(body)
  tryCatch({
    request <- httr::POST("https://hrly.nrcc.cornell.edu/stnHrly",
                          body = body)
    contents <- httr::content(request) %>%
      jsonlite::fromJSON()
    # Extract hourly data
    hrlyData <- contents$hrlyData %>%
      magrittr::set_colnames(contents$hrlyFields) %>%
      tibble::as_tibble()
    # Extract daily data
    dlyData <- contents$dlyData %>%
      magrittr::set_colnames(contents$dlyFields) %>%
      tibble::as_tibble()
    # Extract forecast data
    fcstData <- contents$fcstData %>%
      magrittr::set_colnames(contents$fcstFields) %>%
      tibble::as_tibble()
    # Extract daily forecast data
    dlyFcstData <- contents$dlyFcstData %>%
      magrittr::set_colnames(contents$dlyFcstFields) %>%
      tibble::as_tibble()
    return(list(hourly = hrlyData,
                daily = dlyData,
                forecast = fcstData,
                daily_forecast = dlyFcstData))
  }, error = function(e) {
    error(e)
  })
}
