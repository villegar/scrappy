#' NEWA Weather Stations dataset
#'
#' A dataset containing information of 718 weather stations in the Network for
#' Environment and Weather Applications (NEWA) at Cornell University.
#'
#' @format A data frame with 718 rows and 3 variables:
#' \describe{
#'     \item{name}{Station's name.}
#'     \item{state}{State where the station is located.}
#'     \item{code}{Station's code.}
#' }
#' @author Network for Environment and Weather Applications
#' \email{support@newa.zendesk.com}
#' @usage data(newa_stations)
#' @keywords datasets
#' @source \url{http://newa.cornell.edu/index.php?page=station-pages}
"newa_stations"

#' NEWA v3 Weather Stations dataset
#'
#' A dataset containing information of 801 weather stations in the Network for
#' Environment and Weather Applications (NEWA) version 3 at Cornell University.
#'
#' @format A data frame with 801 rows and 10 variables:
#' \describe{
#'     \item{name}{Station's name.}
#'     \item{state}{State where the station is located.}
#'     \item{code}{Station's code.}
#'     \item{affiliation}{Entity to which the entity is affiliated.}
#'     \item{affiliation_url}{Entity's URL.}
#'     \item{latitude}{Station's latitude.}
#'     \item{longitude}{Station's longitude.}
#'     \item{elevation}{Station's elevation.}
#'     \item{start_year}{Start year (data available).}
#'     \item{is_icao}{Boolean flag to indicate if the station is part of the
#'     International Civil Aviation Organization (ICAO) (e.g is an airport).}
#' }
#' @author Network for Environment and Weather Applications
#' \email{support@newa.zendesk.com}
#' @usage data(newa3_stations)
#' @keywords datasets
#' @source \url{https://newa.cornell.edu}
"newa3_stations"
