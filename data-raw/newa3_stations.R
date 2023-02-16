## code to prepare the `newa3_stations` dataset
# Import pipe
`%>%` <- scrappy::`%>%`

newa3_stations <-
  jsonlite::read_json("data-raw/newa3_stations.json") %>%
  purrr::map_df(~.x)

usethis::use_data(newa3_stations, overwrite = TRUE)
