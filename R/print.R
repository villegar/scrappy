#' @title Print Values
#'
#' @param x an object used to select a method.
#' @param ... further arguments passed to or from other methods.
#' @rdname print
#' @export
#'
#' @name print
NULL

#' Print Google Maps' reviews
#' @rdname print
#' @export
print.gmaps_reviews <- function(x, ...) {
  name <- attr(x, "name")
  place_id <- attr(x, "place_id")
  stars <- attr(x, "stars")
  total_reviews <- attr(x, "total_reviews")

  if (is.na(total_reviews) || total_reviews == 0) {
    message("This place (", name, ") has no reviews.")
  } else {
    message("This place (",
            name,
            ") has an overall rating of ",
            stars,
            " stars and ",
            total_reviews,
            " total reviews.")
  }
  NextMethod()
}
