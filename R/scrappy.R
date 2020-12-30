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
#'
#' @export
#'
#' @examples
#' \dontrun{
#' scrappy::newa_nrcc(my_client, 2020, 12, "gbe")
#' }
newa_nrcc <- function(client,
                      year,
                      month,
                      station,
                      base = "http://newa.nrcc.cornell.edu/newaLister",
                      interval = "hly",
                      sleep = 6) {
  # Local binding
  . <- NULL
  # Navigate to website
  client$navigate(paste(base, interval, station, year, month, sep = "/"))
  # Wait for the website to load
  Sys.sleep(sleep)
  # Create output filename
  file <- paste0(station, "-", interval, "-", year, "-", month, ".csv")
  # Parse HTML code and save CSV file
  client$getPageSource()[[1]] %>%
    xml2::read_html() %>% # parse HTML
    rvest::html_nodes("table.dataTable") %>% # extract table nodes, "dataTable"
    .[2] %>% # keep the second of these tables
    .[[1]] %>% # keep the second element of this list
    rvest::html_table(fill = TRUE) %>%
    write.csv(file, row.names = FALSE)
}
