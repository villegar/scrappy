## code to prepare the `newa_stations` dataset
# Import pipe
`%>%` <- scrappy::`%>%`

# Create RSelenium session
rD <- RSelenium::rsDriver(browser = "firefox", port = 4548L, verbose = FALSE)

rD$client$navigate("http://newa.cornell.edu/index.php?page=station-pages")
Sys.sleep(5)
aux <- rD$client$getPageSource()[[1]] %>%
  xml2::read_html() %>% # parse HTML
  rvest::html_nodes("table.table")

station_code <- aux %>%
  rvest::html_nodes("a") %>%
  rvest::html_attr("href") %>%
  gsub(pattern = ".*=", replacement = "")

newa_stations <- aux %>%
  rvest::html_table(header = TRUE) %>%
  as.data.frame() %>%
  tidyr::separate(col = 1, into = c("name", "state"), sep = ",")
newa_stations$code <- station_code

# Stop server
rD$server$stop()

usethis::use_data(newa_stations, overwrite = TRUE)
