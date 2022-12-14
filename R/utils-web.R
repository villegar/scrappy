#' Wait until page has finished loading
#'
#' Wait until page has finished loading the element with the tag `value`
#'
#' @param client \code{RSelenium} client.
#' @param using String with the property to use to find the element (e.g. "css",
#'     "xpath", etc.) (default: "css").
#' @param value String with the tag of the page element to wait to load
#'     (default: "body").
#' @param sleep Numeric value with the number of seconds to wait for the page
#'     to load the results (default: 1 second).
#'
#' @export
wait_to_load <- function(client, using = "css", value = "body", sleep = 1) {
  page_element <- NULL
  while (is.null(page_element)) {
    page_element <- tryCatch({
      find_element(client, using, value)
    },
    error = function(e) {
      NULL
    })
    Sys.sleep(sample(seq(0, sleep, by = 0.1), 1)) # wait a random number of sec.
  }
}
