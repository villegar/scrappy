#' Scrape GP practices
#'
#' Scrape GP practices near a given postcode
#'
#'
#' @param client \code{RSelenium} client.
#' @param postcode String with the target postcode.
#' @param base String with the base URL for Google Maps website.
#' @param sleep Integer with number of seconds to use as pause between actions
#'     on the web page.
#'
#' @return Data frame with GP practices near the given `postcode`.
#'
#' @export
#'
#' @importFrom utils URLdecode
#'
#' @examples
#' \dontrun{
#' # Create RSelenium session
#' rD <- RSelenium::rsDriver(browser = "firefox", port = 4544L, verbose = FALSE)
#'
#' # Retrieve GP practices near L69 3GL
#' # (Waterhouse building, University of Liverpool)
#' wh_gps_tb <- scrappy::find_a_gp(rD$client, postcode = "L69 3GL")
#'
#' # Stop server
#' rD$server$stop()
#' }
find_a_gp <- function(client,
                      postcode,
                      base = "https://www.nhs.uk/service-search/find-a-gp",
                      sleep = 1) {
  # create URL by appending the postcode of the GP practice to the base URL
  URL <- paste0(base, "/results/", URLencode(postcode, reserved = TRUE))

  # navigate to the target web page
  navigate(client, URL)

  # wait for the page to load
  wait_to_load(client = client, sleep = sleep)

  # retrieve all the results
  gpp <- find_elements(client, "css", "#catchment_gps_list > li")
  gpp_tb <- parse_gpp(gpp)
  gpp_tb
}

#' Parse list of GP practices
#'
#' @param gpp List of GP practices (`webElement` class)
#'
#' @return Tibble with the GP practices
#' @keywords internal
parse_gpp <- function(gpp) {
  # local bindings
  . <- NULL
  seq_along(gpp) |>
    purrr::map_df(function(idx) {
      item <- gpp[[idx]]
      i <- idx - 1
      item_html <- item$getElementAttribute("innerHTML")[[1]] |>
        xml2::read_html()
      practice_code <- item_html |>
        rvest::html_element(xpath = paste0("//*[@id='item_id_", i, "']")) |>
        rvest::html_text()
      org_type <- item_html |>
        rvest::html_element(xpath = paste0("//*[@id='item_org_type_id_", i, "']")) |>
        rvest::html_text()
      distance <- item_html |>
        rvest::html_element(xpath = paste0("//*[@id='distance_", i, "']")) |>
        rvest::html_text() |>
        stringr::str_extract("is [0-9.]*") |>
        stringr::str_remove_all("is|\\s") |>
        as.numeric()
      org_name <- item_html |>
        rvest::html_element(xpath = paste0("//*[@id='orgname_", i, "']")) |>
        rvest::html_text()
      address <- item_html |>
        rvest::html_element(xpath = paste0("//*[@id='address_", i, "']")) |>
        rvest::html_text()
      phone <- item_html |>
        rvest::html_element(xpath = paste0("//*[@id='phone_", i, "']")) |>
        rvest::html_text()
      map_link <- item_html |>
        rvest::html_element(xpath = paste0("//*[@id='map_link_", i, "']")) |>
        rvest::html_attr("href")
      coordinates <- map_link |>
        URLdecode() |>
        stringr::str_extract("origin=[0-9,-.]*") |>
        stringr::str_remove_all("origin=") |>
        stringr::str_split_fixed(",", n = 2) |>
        as.numeric()
      date_downloaded <- Sys.time()
      tibble::tibble(
        practice_code,
        org_type,
        distance,
        org_name,
        address,
        phone,
        map_link,
        list(coordinates),
        date_downloaded
      )
    })
}
