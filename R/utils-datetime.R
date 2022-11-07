#' Convert duration to date-time
#' Convert a string with a duration (e.g. 'an hour ago') to a date-time string,
#' based on a reference time
#'
#' @param str String with a duration (see examples)
#' @param ref_time Reference time (default: `Sys.time()`, current time)
#' @param output_format String with the format of the output (default:
#'     `"%Y-%m-%d %H:%M:%S %Z"`)
#'
#' @return Date-time object based on the input string, `str`, and the reference
#'     time `ref_time`.
#' @export
#'
#' @examples
#' duration2datetime("a minute ago")
#' duration2datetime("an hour ago")
#' duration2datetime("a day ago")
#' duration2datetime("a week ago")
#' duration2datetime("a month ago")
#' duration2datetime("a year ago")
#' duration2datetime("2 minutes ago")
#' duration2datetime("2 hours ago")
#' duration2datetime("2 days ago")
#' duration2datetime("2 weeks ago")
#' duration2datetime("2 months ago")
#' duration2datetime("2 years ago")
duration2datetime <- function(str,
                              ref_time = Sys.time(),
                              output_format = "%Y-%m-%d %H:%M:%S %Z") {
  tryCatch({
    if (stringr::str_detect(str, "month")) {
      value <- str %>%
        stringr::str_remove("month[s]* ago$") %>%
        stringr::str_replace("an|a", "1") %>%
        stringr::str_squish() %>%
        as.integer()
      time_diff <- months(value)
    } else if (stringr::str_detect(str, "year")) {
      value <- str %>%
        stringr::str_remove("year[s]* ago$") %>%
        stringr::str_replace("an|a", "1") %>%
        stringr::str_squish() %>%
        as.integer()
      time_diff <- months(12 * value)
    } else if (stringr::str_detect(str, "^an|^a")) {
      units <- str %>%
        stringr::str_remove_all("^an|^a") %>%
        stringr::str_remove("ago$") %>%
        stringr::str_squish() %>%
        stringr::str_replace("minute", "min")
      time_diff <- as.difftime(1, units = stringr::str_c(units, "s"))
    } else if (stringr::str_detect(str, "minute|hour|day|week")) {
      units <- str %>%
        stringr::str_remove_all("ago") %>%
        stringr::str_squish() %>%
        stringr::str_extract("[a-zA-Z]+$")
      value <- str %>%
        stringr::str_remove("ago$") %>%
        stringr::str_remove(units) %>%
        stringr::str_squish() %>%
        as.integer()
      time_diff <- as.difftime(value,
                               units = units %>%
                                 stringr::str_replace("minute", "min"))
    } else {
      return(NA)
    }
    format(ref_time - time_diff, output_format)
  }, error = function(e) {
    NA
  })
}
