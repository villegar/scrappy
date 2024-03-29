% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/scrape-google.R
\name{sort_reviews}
\alias{sort_reviews}
\title{Sort reviews}
\usage{
sort_reviews(
  client,
  using = "xpath",
  value_sort_btn = "//button[@data-value='Sort']",
  value_sort_options = "//div[@role='menuitemradio']",
  sleep = 1,
  sort_index = 2
)
}
\arguments{
\item{client}{\code{RSelenium} client.}

\item{using}{String with "css" or "xpath".}

\item{value_sort_btn}{String with css tag or xpath for the Sort button.}

\item{value_sort_options}{String with css tag or xpath for the Sort options.}

\item{sleep}{Integer with number of seconds to use as pause between actions
on the web page.}

\item{sort_index}{Integer with the index of the sorting order of the reviews:
\code{1} ("Most Relevant"),
\code{2} ("Newest"),
\code{3} ("Highest rating"),
\code{4} ("Lowest rating")}
}
\description{
Sort reviews
}
\keyword{internal}
