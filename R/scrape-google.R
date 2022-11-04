#' Expand reviews
#'
#' Expand long reviews to capture all the comment
#'
#' @param using String with "css" or "xpath".
#' @param value String with css tag or xpath.
#' @inheritParams google_maps
#'
#' @keywords internal
expand_reviews <-
  function(client,
           using = "xpath",
           value = "//button[@jsaction='pane.review.expandReview']") {
  client$findElements(using, value) %>%
    purrr::walk(~.x$clickElement())
}

#' Scrape Google Maps' reviews
#'
#' @param client \code{RSelenium} client.
#' @param name String with the name of the target place.
#' @param place_id String with the unique ID of the target place, useful when
#'     more than one place has the same name.
#' @param base String with the base URL for Google Maps website.
#' @param sleep Integer with number of seconds to use as pause between actions
#'     on the web page.
#' @param max_reviews Integer with the maximum number of reviews to scrape. The
#'     number of existing reviews will define the actual number of reviews
#'     returned.
#' @param with_text Boolean value to indicate if the `max_reviews` should only
#'     account for those reviews with a comment.
#'
#' @return Tibble with the reviews extracted from Google Maps.
#' @export
#'
#' @examples
#' #' \dontrun{
#' # Create RSelenium session
#' rD <- RSelenium::rsDriver(browser = "firefox", port = 4544L, verbose = FALSE)
#' # Retrieve reviews for Sefton Park in Liverpool
#' sefton_park_reviews_tb <-
#'   scrappy::google_maps(client = rD$client,
#'                        name = "Sefton Park",
#'                        place_id = "ChIJrTCHJVkge0gRm1LWF0fSPgw",
#'                        max_reviews = 20)
#'
#' sefton_park_reviews_tb_with_text <-
#'   scrappy::google_maps(client = rD$client,
#'                        name = "Sefton Park",
#'                        place_id = "ChIJrTCHJVkge0gRm1LWF0fSPgw",
#'                        max_reviews = 20,
#'                        with_text = TRUE)
#' # Stop server
#' rD$server$stop()
#' }
google_maps <-
  function(client,
           name,
           place_id = NULL,
           base = "https://www.google.com/maps/search/?api=1&query=",
           sleep = 1,
           max_reviews = 100,
           with_text = FALSE) {
  # create URL by appending the name of the place to the base URL
  URL <- paste0(base, URLencode(name, reserved = TRUE))
  # check if place_id was passed to the function call, if so, append to the URL
  if (!missing(place_id))
    URL <- paste0(URL, "&query_place_id=", URLencode(place_id, reserved = TRUE))

  # navigate to the target web page
  client$navigate(URL)

  # wait for the page to load
  scrappy::wait_to_load(client = client, sleep = sleep)

  # handle cookies page
  handle_cookies(client, sleep = sleep)

  # get overall rating for the place
  overall_rating <- overall_rating(client)

  # sort reviews by most recent
  sort_reviews(client, sleep = sleep)

  # scrape reviews
  n_reviews <- 0
  parsed_reviews <- tibble::tibble()
  while (n_reviews < min(max_reviews,
                                    overall_rating$total_reviews)) {
    expand_reviews(client) # expand long reviews
    # retrieve all the reviews
    reviews <- client$findElements("css",
                                   "div.jftiEf.fontBodyMedium")
    # extract the unique identifier for the reviews HTML elements
    reviews_id <- reviews %>%
      purrr::map_chr(~.x$elementId)
    # parse reviews
    if (nrow(parsed_reviews) > 0 ) {
      # parse only new reviews
      idx <- reviews_id %in% parsed_reviews$html_el_id
      new_reviews <- reviews[!idx] %>%
        parse_reviews() %>%
        dplyr::mutate(html_el_id = reviews_id[!idx])
    } else {
      new_reviews <- reviews %>%
        parse_reviews() %>%
        dplyr::mutate(html_el_id = reviews_id)
    }
    parsed_reviews <- parsed_reviews %>%
      dplyr::bind_rows(new_reviews)
    if (with_text) {
      n_reviews <- parsed_reviews %>%
        dplyr::filter(stringr::str_length(comment) > 0) %>%
        nrow()
    } else {
      n_reviews <- nrow(parsed_reviews)
    }
    scroll_reviews(client)
  }
  parsed_reviews %>%
    dplyr::select(-parsed_reviews)
}

#' Handle cookies
#'
#' Handle cookies page
#'
#' @param accept_cookies Not used (to be implemented).
#'
#' @inheritParams expand_reviews
#' @inheritParams google_maps
#'
#' @keywords internal
handle_cookies <- function(client,
                           using = "xpath",
                           value = "//button[@aria-label=\'Reject all\']",
                           accept_cookies = FALSE,
                           sleep = 1) {
  tryCatch({
    suppressMessages({
      reject_all_btn <-
        client$findElement(using, value)
      reject_all_btn$clickElement()
      scrappy::wait_to_load(client = client, sleep = sleep)
    })
  }, error = function(e) {})
}

#' Overall rating of the place
#'
#' @inheritParams google_maps
#'
#' @return Tibble with average number of stars and total reviews
#'
#' @keywords internal
overall_rating <- function(client) {
  main_div <- client$findElement("css",
                                 "div.F7nice.mmu3tf")
  main_div_html <- main_div$getElementAttribute("innerHTML")[[1]] %>%
    rvest::read_html()
  stars <- main_div_html %>%
    rvest::html_element(xpath = "/html/body/span[1]/span/span[1]") %>%
    rvest::html_text() %>%
    as.numeric()
  total_reviews <- main_div_html %>%
    rvest::html_element(xpath = "/html/body/span[2]/span[1]/button") %>%
    rvest::html_text() %>%
    stringr::str_remove_all("review[s]*|,") %>%
    as.numeric()
  tibble::tibble(
    stars,
    total_reviews
  )
}

#' Parse list of reviews
#'
#' @param reviews List of reviews (`webElement` class)
#'
#' @return Tibble with the reviews
#' @keywords internal
parse_reviews <- function(reviews) {
  reviews %>%
    purrr::map_df(function(item) {
    item_html <- item$getElementAttribute("innerHTML")[[1]] %>%
      # item$getElementAttribute("outerHTML")[[1]] %>%
      xml2::read_html()
    review_id <- item_html %>%
      rvest::html_element(xpath = "//div") %>%
      rvest::html_attr("data-review-id")
    review_locality <- item_html %>%
      rvest::html_element(xpath = "/html/body/div/div[3]/div[2]/div[2]/div[1]/a/div[2]/span[1]") %>%
      rvest::html_text() %>%
      stringr::str_squish()
    review_total_reviews <- item_html %>%
      rvest::html_element(xpath = "/html/body/div/div[3]/div[2]/div[2]/div[1]/a/div[2]/span[2]") %>%
      rvest::html_text() %>%
      stringr::str_extract("[0-9]+") %>%
      as.integer()
    review_author <- item_html %>%
      rvest::html_element(".d4r55") %>%
      rvest::html_text() %>%
      stringr::str_squish()
    review_author_url <- item_html %>%
      rvest::html_element(xpath = "/html/body/div/div[3]/div[2]/div[2]/div[1]/a") %>%
      rvest::html_attr("href") %>%
      stringr::str_squish()
    review_comment <- item_html %>%
      # rvest::html_element(".MyEned") %>%
      rvest::html_element(".wiI7pd") %>%
      rvest::html_text() %>%
      stringr::str_squish()
    review_rating <- item_html %>%
      rvest::html_element(".kvMYJc") %>%
      rvest::html_attr("aria-label") %>%
      stringr::str_remove_all("star[s]*") %>%
      stringr::str_squish() %>%
      as.integer()
    review_date_relative <- item_html %>%
      rvest::html_element(".rsqaWe") %>%
      rvest::html_text() %>%
      stringr::str_squish()
    review_date_downloaded <- Sys.Date()
    review_date_absolute <- review_date_relative %>%
      scrappy::duration2datetime(ref_time = review_date_downloaded)
    tibble::tibble(
      review_id,
      review_author,
      review_author_url,
      review_comment,
      review_rating,
      review_locality,
      review_total_reviews,
      review_date_relative,
      review_date_absolute,
      review_date_downloaded
    ) %>%
      magrittr::set_names(names(.) %>% stringr::str_remove_all("review_"))
  })
}

#' Scroll reviews
#'
#' Scroll reviews container and load more reviews
#'
#' @param scroll_px Integer with the number of pixels to scroll.
#' @inheritParams expand_reviews
#' @inheritParams google_maps
#'
#' @keywords internal
scroll_reviews <- function(client,
                           using = "css",
                           value = "div.m6QErb.DxyBCb.kA9KIf.dS8AEf",
                           scroll_px = 1000,
                           sleep = 1) {
  scrollable_div <- client$findElement(using, scroll_ele_tag)
  client$executeScript(paste0("arguments[0].scrollBy(0,", scroll_px, ");"),
                       args = list(scrollable_div))
  Sys.sleep(sleep)
}

#' Sort reviews
#'
#' @param value_sort_btn String with css tag or xpath for the Sort button.
#' @param value_sort_option String with css tag or xpath for the Sort options.
#' @param sort_index Integer with the index of the sorting order of the reviews:
#'     `1` ("Most Relevant"),
#'     `2` ("Newest"),
#'     `3` ("Highest rating"),
#'     `4` ("Lowest rating")
#' @inheritParams expand_reviews
#' @inheritParams google_maps
#'
#' @keywords internal
sort_reviews <- function(client,
                         using = "xpath",
                         value_sort_btn = "//button[@data-value=\'Sort\']",
                         value_sort_option = "//li[@role=\'menuitemradio\']",
                         sleep = 1,
                         sort_index = 2) {
  menu_bt <- client$findElement(using, value_sort_btn)
  menu_bt$clickElement()
  Sys.sleep(sleep)
  sort_options <- client$findElements(using, value_sort_options)
  sort_options[[sort_index]]$clickElement()
  Sys.sleep(sleep)
}
