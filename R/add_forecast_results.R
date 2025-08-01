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
  
  toxin_measurements <- toxin_measurements |> 
    dplyr::mutate(classification = recode_classification(.data$total_toxicity, tox_levels)) |> 
    dplyr::filter(date >= min(predictions$forecast_start_date))
  
  
  find_result <- function(tbl, key, tox=NULL) {
    
    db <- tox |> 
      dplyr::filter(.data$location_id == key$location[1] &
                      .data$species == key$species[1]) |> #add break
      dplyr::filter(dplyr::between(date, tbl$forecast_start_date[1], tbl$forecast_end_date[1]))
    
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
      
      db <- db |> 
        dplyr::filter(.data$total_toxicity == max(.data$total_toxicity)) |> 
        head(n=1)
      
      forecast_results <- tbl |> 
        dplyr::select(version, .data$location, date) |> 
        dplyr::mutate(measurement_date = as.Date(db$date),
                      toxicity = db$total_toxicity,
                      class = db$classification)
    } 
    
    forecast_results <- tbl |> 
      dplyr::select(version, .data$location, date) |> 
      dplyr::mutate(measurement_date = as.Date(db$date),
                    toxicity = db$total_toxicity,
                    class = db$classification)
    
    return(forecast_results)
  }
  
  
  is_correct <- function(x, y) {
    if (x$predicted_class == x$class) {
      x <- x |> 
        dplyr::mutate(correct = TRUE)
    } else {
      x <- x |> 
        dplyr::mutate(correct=FALSE)
    }
  }
  
  
  is_cl_correct <- function(x,y) {
    if ((x$predicted_class == 3 & x$class == 3) || (x$predicted_class != 3 & x$class != 3)) {
      x <- x |> 
        dplyr::mutate(cl_correct = TRUE)
    } else {
      x <- x |> 
        dplyr::mutate(cl_correct=FALSE)
    }
  }
    
  
  results <- predictions |>
    dplyr::group_by(.data$location, .data$date, .data$species) |> 
    dplyr::group_map(find_result, .keep=TRUE, tox=toxin_measurements) |> 
    dplyr::bind_rows() |> 
    dplyr::arrange(date)
  
  forecast_w_results <- dplyr::full_join(predictions, results, by=c("version", "location", "date")) |> 
    tidyr::drop_na("class") |> 
    dplyr::rowwise() |> 
    dplyr::group_map(is_correct, .keep=TRUE) |> 
    dplyr::bind_rows() |>
    dplyr::rowwise() |> 
    dplyr::group_map(is_cl_correct, .keep=TRUE) |> 
    dplyr::bind_rows()

  return(forecast_w_results)
}

