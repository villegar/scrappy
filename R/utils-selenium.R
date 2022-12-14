#' Click the element
#'
#' @param element HTML element.
#'
#' @return Returns the status of the action.
#' @keywords internal
click_element <- function(element) {
  tryCatch({
    element$clickElement()
    TRUE
  },
  warning = function(w) {
    FALSE
  },
  error = function(e) {
    FALSE
  },
  finally = {
  })
}

#' Inject a snippet of JavaScript
#'
#' Inject a snippet of JavaScript into the page for execution in the context
#' of the currently selected frame. The executed script is assumed to be
#' synchronous and the result of evaluating the script is returned to the
#' client. The script argument defines the script to execute in the form of a
#' function body.
#'
#' @param client \code{RSelenium} client.
#' @param script String with the JavaScript to be executed.
#' @param args List of arguments for the `script`.
#'
#' @return Returns the status of the action.
#' @keywords internal
execute_script <- function(client, script, args) {
  tryCatch({
    client$executeScript(script, args)
    TRUE
  },
  warning = function(w) {
    FALSE
  },
  error = function(e) {
    FALSE
  },
  finally = {
  })
}

#' Search for an element on the page
#'
#' Search for an element on the page, starting from the document root.
#'
#' @param client \code{RSelenium} client.
#' @param using String with "css" or "xpath".
#' @param value String with css tag or xpath.
#'
#' @return The located element will be returned as an object of `webElement`
#'     class.
#' @keywords internal
find_element <- function(client, using, value) {
  tryCatch({
    suppressMessages({
      client$findElement(using = using, value = value)
    })
  },
  warning = function(w) {
    return(NA)
  },
  error = function(e) {
    return(NA)
  })
}

#' Search for multiple elements on the page
#'
#' Search for multiple elements on the page, starting from the document root.
#'
#' @param client \code{RSelenium} client.
#' @param using String with "css" or "xpath".
#' @param value String with css tag or xpath.
#'
#' @return The located elements will be returned as an list of objects of
#'     `WebElement` class.
#' @keywords internal
find_elements <- function(client, using, value) {
  tryCatch({
    suppressMessages({
      client$findElements(using = using, value = value)
    })
  },
  warning = function(w) {
    return(NULL)
  },
  error = function(e) {
    return(NULL)
  })
}


#' Navigate to a given url
#'
#' @param client \code{RSelenium} client.
#' @param url String with a URL.
#'
#' @return Returns the status of the action.
#' @keywords internal
navigate <- function(client, url) {
  tryCatch({
    client$navigate(url)
    TRUE
  },
  warning = function(w) {
    FALSE
  },
  error = function(e) {
    FALSE
  },
  finally = {
  })
}
