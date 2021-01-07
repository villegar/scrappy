install.packages("RSelenium")
rvest::`%>%`
xml2::read_html()
library(RSelenium)
# selenium proper
library(RSelenium)
# rvest to convert to xml for easier parsing
library(rvest)

# start a server and open a navigator (firefox by default)
driver <- rsDriver()
driver <- remoteDriver()
driver$open()

# go to google
driver$navigate("http://www.google.com")

# get source code
page <- driver$getPageSource()

# convert to xml for easier parsing
page_xml <- read_html(page[[1]])


######################################
# install.packages("RSelenium")
# install.packages("rvest")
# install.packages("xml2")

# `%>%` <- dplyr::`%>%`
# test_url <- "http://newa.nrcc.cornell.edu/newaLister/hly/gbe/2020/1"
rD <- RSelenium::rsDriver(browser = "firefox", port = 4547L, verbose = FALSE)
remDr <- rD[["client"]]
scrapeR <- function(remDr, year, month, station = "gbe") {
  remDr$navigate(paste0("http://newa.nrcc.cornell.edu/newaLister/hly/",
                        station, "/",
                        year, "/",
                        month))
  Sys.sleep(10)
  html <- remDr$getPageSource()[[1]]
  temps <- xml2::read_html(html) %>% # parse HTML
    rvest::html_nodes("table.dataTable") %>% # extract table nodes with class = "dataTable"
    .[2] %>% # keep the second of these tables
    .[[1]] %>% # keep the second element of this list
    rvest::html_table(fill = TRUE)
  write.csv(temps, paste0(station, "-", year, "-", month, ".csv"), row.names = FALSE)
}


scrapeR(rD[["client"]], 2020, 12)

scrappy::newa_nrcc(rD[["client"]], 2020, 11, "gbe")

