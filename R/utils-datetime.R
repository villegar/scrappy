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
#' duration2datetime("a day ago")
#' duration2datetime("an hour ago")
#' duration2datetime("2 days ago")
#' duration2datetime("2 hours ago")
duration2datetime <- function(str,
                              ref_time = Sys.time(),
                              output_format = "%Y-%m-%d %H:%M:%S %Z") {
  if (str == "a day ago")  {
    time_diff <- as.difftime(1, units = "days")
  } else if (str == "an hour ago") {
    time_diff <- as.difftime(1, units = "hours")
  } else if (stringr::str_detect(str, "hours")) {
    hours_ago <- str %>%
      stringr::str_remove_all("hour[s]* ago") %>%
      stringr::str_squish() %>%
      as.integer()
    time_diff <- as.difftime(hours_ago, units = "hours")
  } else if (stringr::str_detect(str, "days")) {
    days_ago <- str %>%
      stringr::str_remove_all("day[s]* ago") %>%
      stringr::str_squish() %>%
      as.integer()
    time_diff <- as.difftime(days_ago, units = "days")
  } else {
    return(NA)
  }
  format(ref_time - time_diff, output_format)
}
