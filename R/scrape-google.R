#' Expand reviews
#'
#' Expand long reviews to capture all the comment
#'
#' @param using String with "css" or "xpath".
#' @param value String with css tag or xpath.
#' @inheritParams google_maps
#'
#' @keywords internal
expand_reviews <- function(client,
                           using = "xpath",
                           value = "//button[@jsaction='pane.review.expandReview']") {
  find_elements(client, using, value) %>%
    purrr::walk(click_element)
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
#' @param result_id Integer with the result position to use, only relevant when
#'     multiple matches for the given `name` are found.
#'
#' @return Tibble with the reviews extracted from Google Maps.
#' @export
#'
#' @importFrom utils URLencode
#'
#' @examples
#' \dontrun{
#' # Create RSelenium session
#' rD <- RSelenium::rsDriver(browser = "firefox", port = 4544L, verbose = FALSE)
#' # Retrieve reviews for Sefton Park in Liverpool
#' sefton_park_reviews_tb <-
#'   scrappy::google_maps(
#'     client = rD$client,
#'     name = "Sefton Park",
#'     place_id = "ChIJrTCHJVkge0gRm1LWF0fSPgw",
#'     max_reviews = 20
#'   )
#'
#' sefton_park_reviews_tb_with_text <-
#'   scrappy::google_maps(
#'     client = rD$client,
#'     name = "Sefton Park",
#'     place_id = "ChIJrTCHJVkge0gRm1LWF0fSPgw",
#'     max_reviews = 20,
#'     with_text = TRUE
#'   )
#' # Stop server
#' rD$server$stop()
#' }
google_maps <- function(client,
                        name,
                        place_id = NULL,
                        base = "https://www.google.com/maps/search/?api=1&query=",
                        sleep = 1,
                        max_reviews = 100,
                        result_id = 1,
                        with_text = FALSE) {
  # local bindings
  . <- html_el_id <- NULL
  # create URL by appending the name of the place to the base URL
  URL <- paste0(base, URLencode(name, reserved = TRUE))
  # check if place_id was passed to the function call, if so, append to the URL
  if (!missing(place_id)) {
    URL <- paste0(URL, "&query_place_id=", URLencode(place_id, reserved = TRUE))
  }

  # navigate to the target web page
  navigate(client, URL)

  # wait for the page to load
  scrappy::wait_to_load(client = client, sleep = sleep)

  # handle cookies page
  handle_cookies(client, sleep = sleep)

  # check if there are multiple results
  value <- sprintf("//div[@aria-label='Results for %s']/div/div/a", name)
  search_results <- find_elements(client, "xpath", value)

  if (length(search_results) > 1) {
    message(sprintf(
      "%d results were found, using result %d!",
      length(search_results),
      result_id
    ))

    # extract new URL
    new_url <- search_results[result_id][[1]]$getElementAttribute("href")[[1]]
    navigate(client, new_url)
  }

  # get overall rating for the place
  overall_rating <- overall_rating(client)
  if (is.na(getElement(overall_rating, "total_reviews"))) {
    message("Warning: Failed to determine the total number reviews.")
    zero_reviews <- tibble::tibble() %>%
      magrittr::set_attr("name", name) %>%
      magrittr::set_attr(
        "place_id",
        ifelse(is.null(place_id), NA, place_id)
      ) %>%
      magrittr::set_attr("stars", overall_rating$stars) %>%
      magrittr::set_attr("total_reviews", overall_rating$total_reviews) %>%
      magrittr::set_class(c("gmaps_reviews", class(.)))
    return(zero_reviews)
  }

  # sort reviews by most recent
  sort_reviews(client, sleep = sleep)

  # scrape reviews
  n_reviews <- 0
  parsed_reviews <- tibble::tibble()
  min_num_reviews <-
    min(max_reviews, overall_rating$total_reviews, na.rm = TRUE)
  while (n_reviews < min_num_reviews) {
    expand_reviews(client) # expand long reviews
    # retrieve all the reviews
    reviews <- find_elements(client, "css", "div.jftiEf.fontBodyMedium")
    # extract the unique identifier for the reviews HTML elements
    reviews_id <- reviews %>%
      purrr::map_chr(~ .x$elementId)
    # parse reviews
    if (nrow(parsed_reviews) > 0) {
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
    dplyr::select(-html_el_id) %>%
    magrittr::set_attr("name", name) %>%
    magrittr::set_attr("place_id", ifelse(is.null(place_id), NA, place_id)) %>%
    magrittr::set_attr("stars", overall_rating$stars) %>%
    magrittr::set_attr("total_reviews", overall_rating$total_reviews) %>%
    magrittr::set_class(c("gmaps_reviews", class(.)))
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
  tryCatch(
    {
      suppressMessages({
        reject_all_btn <- find_element(client, using, value)
        click_element(reject_all_btn)
        scrappy::wait_to_load(client = client, sleep = sleep)
      })
    },
    error = function(e) {

    }
  )
}

#' Overall rating of the place
#'
#' @inheritParams expand_reviews
#' @inheritParams google_maps
#'
#' @return Tibble with average number of stars and total reviews
#'
#' @keywords internal
overall_rating <- function(client,
                           using = "xpath",
                           value = "//div[@jsaction=\'pane.reviewChart.moreReviews\']") {
  # Initialise outputs
  stars <- NA_real_
  total_reviews <- NA_integer_

  # Extract HTML element with the reviews overview
  overall_reviews_stars <- find_element(client, using = using, value = value)
  if (is.null(overall_reviews_stars)) {
    return(tibble::tibble(
      stars = NA_real_,
      total_reviews = NA_integer_
    ))
  }
  overall_reviews_stars_html <-
    tryCatch(
      {
        overall_reviews_stars$getElementAttribute("innerHTML")[[1]] %>%
          rvest::read_html()
      },
      error = function(e) {
        NA
      }
    )

  # Extract the total number of stars
  stars <- tryCatch(
    {
      overall_reviews_stars_html %>%
        rvest::html_element(xpath = "/html/body/div[2]/div[1]") %>%
        rvest::html_text() %>%
        as.numeric()
    },
    error = function(e) {
      NA_real_
    }
  )

  # Extract the total number of reviews
  total_reviews <- tryCatch(
    {
      overall_reviews_stars_html %>%
        rvest::html_element(xpath = "/html/body/div[2]/button") %>%
        rvest::html_text() %>%
        stringr::str_remove_all("review[s]*|,") %>%
        as.numeric()
    },
    error = function(e) {
      NA_integer_
    }
  )

  # Alternative to find the total number of reviews
  if (is.na(total_reviews)) {
    total_reviews <- tryCatch(
      {
        more_reviews_link <- find_elements(
          client,
          using = using,
          value = "//button[@jsaction=\'pane.reviewChart.moreReviews\']"
        )
        more_reviews_link[[1]]$getElementAttribute("innerHTML")[[1]] %>%
          stringr::str_extract_all("[0-9,]+\\s*review[s]*") %>%
          stringr::str_remove_all("review[s]*|,") %>%
          as.numeric()
      },
      error = function(e) {
        NA_integer_
      }
    )
  }

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
  # local bindings
  . <- NULL
  reviews %>%
    purrr::map_df(function(item) {
      item_html <- item$getElementAttribute("innerHTML")[[1]] %>%
        xml2::read_html()
      review_id <- item_html %>%
        rvest::html_element(xpath = "//div") %>%
        rvest::html_attr("data-review-id")
      review_local_and_count <- item_html %>%
        rvest::html_element(xpath = "/html/body/div/div/div[2]/div[2]/div[1]/button/div[2]") %>%
        rvest::html_text() %>%
        stringr::str_squish()
      review_locality <- review_local_and_count %>%
        stringr::str_extract_all("^[a-zA-Z\\s]*") %>%
        stringr::str_squish()
      review_total_reviews <- review_local_and_count %>%
        stringr::str_extract_all("[0-9]+[a-zA-Z\\s]*$") %>%
        stringr::str_squish() %>%
        stringr::str_extract("[0-9]+") %>%
        as.integer()
      review_author <- item_html %>%
        rvest::html_element(".d4r55") %>%
        rvest::html_text() %>%
        stringr::str_squish()
      review_author_url <- item_html %>%
        rvest::html_element(xpath = "/html/body/div/div/div[2]/div[2]/div[1]/button") %>%
        rvest::html_attr("data-href") %>%
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
      review_date_downloaded <- Sys.time()
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
  scrollable_div <- find_element(client, using, value)
  execute_script(client,
    script = paste0("arguments[0].scrollBy(0,", scroll_px, ");"),
    args = list(scrollable_div)
  )
  Sys.sleep(sleep)
}

#' Sort reviews
#'
#' @param value_sort_btn String with css tag or xpath for the Sort button.
#' @param value_sort_options String with css tag or xpath for the Sort options.
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
                         value_sort_options = "//div[@role=\'menuitemradio\']",
                         sleep = 1,
                         sort_index = 2) {
  menu_bt <- find_element(client, using, value_sort_btn)
  click_element(menu_bt)
  Sys.sleep(sleep)
  sort_options <- find_elements(client, using, value_sort_options)
  click_element(sort_options[[sort_index]])
  Sys.sleep(sleep)
}
