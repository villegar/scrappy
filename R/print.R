#' @title Print Values
#'
#' @param x an object used to select a method.
#' @param ... further arguments passed to or from other methods.
#' @rdname print
#' @export
print <- function(x, ...) {
  print(x, ...)
}

#' @rdname print
#' @export
print.gmaps_reviews <- function(x, ...) {
  message("This place has an overall rating of ",
          attr(x, "stars"),
          " stars and ",
          attr(x, "total_reviews"),
          " total reviews.")
  NextMethod()
}
