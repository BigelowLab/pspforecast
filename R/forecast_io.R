#' Reads forecast database
#' 
#' @param new_only logical, if true then only the newest observations from each station will be served
#' @return tibble of predicted shellfish toxicity classifications along with their metadata
#' 
#' @export
read_forecast <- function(new_only=FALSE) {
  
  file <- system.file("forecastdb/test_forecast_db.csv.gz", package="pspforecast")
  
  if (new_only == TRUE) {
    all_forecast <- suppressMessages(readr::read_csv(file))
    
    get_newest <- function(tbl, key) {
      newest <- tbl %>% tail(n=1)
      return(newest)
    }
    
    forecast <- all_forecast %>% 
      dplyr::group_by(.data$location) %>% 
      dplyr::group_map(get_newest, .keep=TRUE) %>% 
      dplyr::bind_rows()
    
  } else {
    forecast <- suppressMessages(readr::read_csv(file))
  }
  
  return(forecast)
}


#' Adds a new forecast file of predictions/data to the database 
#'
#' @param predictions tibble of new shellfish toxicity classification predictions
#' 
write_forecast <- function(predictions) {
  
  file <- file.path("inst/forecastdb/test_forecast_db.csv.gz")
  
  predictions %>% suppressMessages(readr::write_csv(file))
  
}


#' Adds new forecast data to the database
#' 
#' @param predictions tibble of new shellfish toxicity classification predictions
#' 
append_forecast <- function(predictions) {
  
  file <- file.path("inst/forecastdb/test_forecast_db.csv.gz")
  
  forecast_db <- read_forecast() %>% 
    rbind(predictions) %>% 
    dplyr::distinct() %>% 
    suppressMessages(readr::write_csv(file))
  
}

