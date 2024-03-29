% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-selenium.R
\name{find_elements}
\alias{find_elements}
\title{Search for multiple elements on the page}
\usage{
find_elements(client, using, value)
}
\arguments{
\item{client}{\code{RSelenium} client.}

\item{using}{String with "css" or "xpath".}

\item{value}{String with css tag or xpath.}
}
\value{
The located elements will be returned as an list of objects of
\code{WebElement} class.
}
\description{
Search for multiple elements on the page, starting from the document root.
}
\keyword{internal}
