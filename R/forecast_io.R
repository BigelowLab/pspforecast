#' Reads forecast database
#' 
#' @param new_only logical, if true then only the newest observations from each station will be served
#' @return tibble of predicted shellfish toxicity classifications along with their metadata
#' 
#' @export
read_forecast <- function(new_only=FALSE) {
  
  file <- system.file("forecastdb/psp_forecast_2021.csv.gz", package="pspforecast")
  
  if (new_only == TRUE) {
    all_forecast <- suppressMessages(readr::read_csv(file))
    
    get_newest <- function(tbl, key) {
      newest <- tbl %>% tail(n=1)
      return(newest)
    }
    
    forecast <- all_forecast %>% 
      dplyr::arrange(.data$date) %>% 
      dplyr::group_by(.data$location) %>% 
      dplyr::group_map(get_newest, .keep=TRUE) %>% 
      dplyr::bind_rows() %>% 
      dplyr::filter(.data$forecast_end_date > as.Date(Sys.Date()))
    
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
  
  file <- file.path("inst/forecastdb/psp_forecast_2021.csv.gz")
  
  forecast_list %>% readr::write_csv(file, append=TRUE)
  
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


#' After making predictions the week prior, add the actual toxicity classification to assess
#' 
#' 
add_forecast_results <- function() {
  
  predictions <- pspforecast::read_forecast()
  
  tox_levels <- c(0,10,30,80)
  
  toxin_measurements <- pspdata::read_psp_data(model_ready=TRUE) %>% 
    dplyr::mutate(classification = psptools::recode_classification(.data$total_toxicity, tox_levels)) %>% 
    dplyr::filter(date >= min(predictions$forecast_start_date))
  
  
  find_result <- function(tbl, key) {
    
    db <- toxin_measurements %>% 
      dplyr::filter(.data$location_id == key$location[1]) %>% 
      dplyr::filter(dplyr::between(date, tbl$forecast_start_date, tbl$forecast_end_date))
    
    if (nrow(db) == 0) {
      
      empty_results <-   dplyr::tibble(version = character(),
                                       location = character(),
                                       date = Sys.Date(),
                                       measurement_date = Sys.Date(),
                                       toxicity = numeric(),
                                       actual_class = numeric())
      
      return(empty_results)
    }
    
    forecast_results <- tbl %>% 
      dplyr::select(.data$version, 
                    .data$location, 
                    .data$date) %>% 
      dplyr::mutate(measurement_date = as.Date(db$date),
                    toxicity = db$total_toxicity,
                    actual_class = db$classification)
    
    return(forecast_results)
    
  }
  
  results <- predictions %>%
    dplyr::group_by(.data$location, 
                    date) %>% 
    dplyr::group_map(find_result, .keep=TRUE) %>% 
    dplyr::bind_rows() %>% 
    dplyr::arrange(date)
  
  return(results)
}

