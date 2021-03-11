#' Reads forecast database
#' 
#' @return tibble of forecasted shellfish toxicity classifications along with their metadata
#' 
#' @export
read_forecast <- function() {
  
  file <- system.file("forecastdb/test_forecast_db.csv.gz", package="pspforecast")

  forecast <- suppressMessages(readr::read_csv(file))
  
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

