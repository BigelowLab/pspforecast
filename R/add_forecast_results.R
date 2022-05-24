#' After making predictions the week prior, add the actual toxicity classification to assess
#' 
#' @param predictions table of predictions (from pspforecast::read_forecast())
#' @param toxin_measurements table of psp data
#' @param tox_levels vector of toxicity classification bins
#' @return table of predictions with the closest matching toxicity measurement
#' 
#' @export
add_forecast_results <- function(predictions, 
                                 toxin_measurements,
                                 tox_levels = c(0,10,30,80)) {
  
  toxin_measurements <- toxin_measurements %>% 
    dplyr::mutate(classification = recode_classification(.data$total_toxicity, tox_levels)) %>% 
    dplyr::filter(date >= min(predictions$forecast_start_date))
  
  
  find_result <- function(tbl, key, tox=NULL) {
    
    db <- tox %>% 
      dplyr::filter(.data$location_id == key$location[1]) %>% #add break
      dplyr::filter(dplyr::between(date, tbl$forecast_start_date, tbl$forecast_end_date))
    
    if (nrow(db) == 0) {
      
      today=Sys.Date()
      
      empty_results <-   dplyr::tibble(version = character(),
                                       location = character(),
                                       date = today,
                                       measurement_date = today,
                                       toxicity = numeric(),
                                       class = numeric())
      
      return(empty_results)
    } else if (nrow(db) > 1) {
      
      db <- db %>% 
        dplyr::filter(.data$total_toxicity == max(.data$total_toxicity))
      
      forecast_results <- tbl %>% 
        dplyr::select(version, .data$location, date) %>% 
        dplyr::mutate(measurement_date = as.Date(db$date),
                      toxicity = db$total_toxicity,
                      class = db$classification)
    }
    
    forecast_results <- tbl %>% 
      dplyr::select(version, .data$location, date) %>% 
      dplyr::mutate(measurement_date = as.Date(db$date),
                    toxicity = db$total_toxicity,
                    class = db$classification)
    
    return(forecast_results)
  }
  
  results <- predictions %>%
    dplyr::group_by(.data$location, .data$date) %>% 
    dplyr::group_map(find_result, .keep=TRUE, tox=toxin_measurements) %>% 
    dplyr::bind_rows() %>% 
    dplyr::arrange(date)
  
  forecast_w_results <- dplyr::full_join(predictions, results, by=c("version", "location", "date")) %>% 
    tidyr::drop_na(.data$class)
  
  return(forecast_w_results)
}
