#' (Assisted) request of EDINA's Digimap data from the Ordnance Survey
#'
#' Digimap’s Ordnance Survey collection provides a full range of topographic
#' Ordnance Survey data for the UK.
#' Note that this function helps you to request the data, once your request
#' has been processed, you will have to manually download the data (email
#' instructions will be provided by Digimap).
#'
#' @param client \code{RSelenium} client.
#' @param area_name String with UK national grid name (e.g., 'SD', 'SD20'). See
#'     \url{ordnancesurvey.co.uk/documents/resources/guide-to-nationalgrid.pdf}.
#' @param dataset String with the name of the data set to download (e.g.,
#'     'NTM' for National Tree Map or 'Terrain-5 DTM' for the OS Terrain 5
#'     Digital Terrain Model). See
#'     \url{https://digimap.edina.ac.uk/help/our-maps-and-data/os_products/}.
#' @param format String with the data format (e.g., 'SHAPE'). See
#'     \url{https://digimap.edina.ac.uk/help/our-maps-and-data/os_products/}.
#' @param version String with the version of the data set (e.g., 'July 2023').
#'     See
#'     \url{https://digimap.edina.ac.uk/help/our-maps-and-data/os_products/}.
#' @param org String with your organisation name (for login purposes, this
#'     can be done manually). Done only once per session.
#' @param sleep Integer with number of seconds to use as pause between actions
#'     on the web page.
#'
#' @return Logic value with the status of the data request.
#' @export
#'
#' @source https://digimap.edina.ac.uk/os
digimap_os <- function(client,
                       area_name = NULL,
                       dataset = NULL,
                       format = NULL,
                       version = NULL,
                       org = Sys.getenv("ORG"),
                       sleep = 1) {
  # check if key variables are NULL
  if (is.null(area_name) & is.null(dataset)) {
    message("[ERROR] Both the `area_name` and `dataset` are required!")
    return(FALSE)
  }

  # navigate to the target web page
  navigate(client, "https://digimap.edina.ac.uk/roam/map/os")

  # check if current URL is login page
  if (grepl("ukfederation", client$getCurrentUrl()[[1]])) {
    # NOTE (15-12-2023): Manual log-in still required
    message("You need to login first with your institutional account!")
    # attempt login
    org_search_txt <-
      find_element(client, "xpath", '//*[@id="SearchInput"]')
    org_search_txt$clickElement()
    org_search_txt$sendKeysToElement(list(org))
    client$findElement("partial link text", "Sign In")$clickElement()
    return(FALSE)
  }

  # download data section
  xpath_download_data <- '//button[normalize-space()="Download Data"]'
  # wait for the page to load
  wait_to_load(client, "xpath", xpath_download_data, sleep)
  find_and_click(client, "xpath", xpath_download_data)

  # use tile name
  ## open sub-menu
  xpath_tile_btn <- '//button[normalize-space()="Use Tile Name"]'
  find_and_click(client, "xpath", xpath_tile_btn)
  random_wait(sleep) # sleep for a random time
  ## enter area name, `area_name`
  tile_txt <- find_element(client, "xpath", '//*[@id="mat-input-1"]')
  tile_txt$sendKeysToElement(list(area_name, key = "enter"))
  random_wait(sleep) # sleep for a random time

  download_suffix <- ""
  if (grepl("OS MM Topography", dataset)) { # OS MasterMap Topography
    select_dataset(client, "OS MasterMap", "Topography", sleep)
    download_suffix <- "OS MM Topo"
  } else if (grepl("OS MM Greenspace", dataset)) { # OS MasterMap Greenspace
    select_dataset(client, "OS MasterMap", "Greenspace", sleep)
    download_suffix <- "OS MM GS"
  } else if (grepl("OS MM Water|Water Network", dataset)) {# OS-MM Water Network
    select_dataset(client, "OS MasterMap", "Water Network", sleep)
    download_suffix <- "OS MM Water"
  } else if ("OS Terrain-5" %in% dataset) { # OS Terrain 5 Contours
    select_dataset(client, "Land and Height Data", "OS Terrain 5 Contours",
                   sleep)
    download_suffix <- "OS Terrain-5"
  } else if ("OS Terrain-5 DTM" %in% dataset) { # OS Terrain 5 DTM
    select_dataset(client, "Land and Height Data", "OS Terrain 5 DTM", sleep)
    download_suffix <- "OS Terrain-5 DTM"
  } else if (grepl("NTM|National Tree Map", dataset)) { # National Tree Map
    select_dataset(client, "National Tree Map", "National Tree Map", sleep)
    download_suffix <- "NTM"
  }

  # add to basket
  find_and_click(client, "xpath", "//button[contains(., 'Add To Basket')]")
  random_wait(sleep) # sleep for a random time

  # version drop-down
  if (!is.null(version)) {
    xpath_version_dd <-
      "//div[@class='basket-container']/*//mat-row/mat-cell[2]"
    find_and_click(client, "xpath", xpath_version_dd)
    random_wait(sleep) # sleep for a random time

    # get versions
    versions <- find_elements(client, "xpath", '//*[@role="option"]')
    if (length(versions) > 0) {
      versions_txt <- purrr::map_chr(versions, function(v) {
        v$getElementAttribute("innerHTML")[[1]] |>
          xml2::read_html() |>
          rvest::html_text() |>
          stringr::str_squish()
      })
      # match version to available versions
      idx <- version == versions_txt
      if (sum(idx) < 1) {
        message("The chosen version is not available, `", version, "`.")
        message("Please, choose one of the following: \n",
                paste0("- ", versions_txt, collapse = "\n"))
        return(FALSE)
      }
      versions[idx][[1]]$clickElement()
    }
  }

  # format drop-down
  xpath_format_dd <- "//div[@class='basket-container']/*//mat-row/mat-cell[3]"
  find_and_click(client, "xpath", xpath_format_dd)
  random_wait(sleep) # sleep for a random time
  # get versions
  formats <- find_elements(client, "xpath", '//*[@role="option"]')
  formats_txt <- purrr::map_chr(formats, function(v) {
    v$getElementAttribute("innerHTML")[[1]] |>
      xml2::read_html() |>
      rvest::html_text() |>
      stringr::str_squish()
  })
  if (is.null(format)) {
    message("Please choose one of the following formats: \n",
            paste0("- ", formats_txt[-1], collapse = "\n"))
    return(FALSE)
  } else {
    # match version to available versions
    idx <- format == formats_txt
    if (sum(idx) < 0) {
      message("The chosen format is not available, `", format, "`.")
      message("Please, choose one of the following: \n",
              paste0("- ", formats_txt, collapse = "\n"))
      return(FALSE)
    }
    formats[idx][[1]]$clickElement()
  }
  # xpath_format_dd_opt <- paste0('//*[@data-test="', format ,'"]')
  # find_and_click(client, "xpath", xpath_format_dd_opt)
  random_wait(sleep) # sleep for a random time

  # update download name
  xpath_download_name_txt <- '//*[@id="mat-input-2"]'
  download_name_txt <- find_element(client, "xpath", xpath_download_name_txt)
  download_name_txt$sendKeysToElement(
    list(paste0(download_suffix, " - ", area_name), key = "enter"))
  random_wait(sleep) # sleep for a random time

  # request download
  find_and_click(client, "xpath", "//button[contains(., 'Request Download')]")
  # find_and_click(client, "xpath", xpath_request_download_btn)
  random_wait(sleep) # sleep for a random time

  # close pop-up message
  find_and_click(client, "xpath", "//button[contains(., 'Ok')]")
  # find_and_click(client, "xpath", xpath_okay_btn)
  random_wait(sleep) # sleep for a random time

  return(TRUE)
}

select_dataset <- function(client, category, dataset, sleep) {
  ## expand sub-menu
  xpath_sub_menu <- sprintf("//mat-row[contains(., '%s')]/mat-cell", category)
  find_and_click(client, "xpath", xpath_sub_menu)
  random_wait(sleep) # sleep for a random time
  ## select dataset
  xpath_sub_select_cell <-
    sprintf("//mat-row[contains(., '%s')]/mat-cell/mat-checkbox", dataset)
  find_and_click(client, "xpath", xpath_sub_select_cell)
  random_wait(sleep) # sleep for a random time
  # collapse sub-menu
  find_and_click(client, "xpath", xpath_sub_menu)
  random_wait(sleep) # sleep for a random time
}

digimap_os_products <- function(client) {
  # xpath_sub_menu <- "//mat-row[contains(., 'National Tree Map')]/mat-cell"
  # xpath_sub_select_cell <- paste0(xpath_sub_menu, "/mat-checkbox")
  # retrieve table with data products [TO-DO]
  # data_products_tbl <- find_element(client, "xpath", '//*[contains(text(), "OS Master Map")]')
  # data_products_tbl <- find_elements(client, "xpath", '//*[@data-test="product-name"]')
  # purrr::map_chr(data_products_tbl, function(v) {
  #   v$getElementAttribute("innerHTML")[[1]] |>
  #     xml2::read_html() |>
  #     rvest::html_text() |>
  #     stringr::str_squish()
  # })
  # data_products_tbl$getElementAttribute("innerHTML")[[1]] |>
  #   xml2::read_html() |>
  #   rvest::html_children()
  #   rvest::html_text()
}
