#' Finds the date of the date of the peak toxicity measurement and the date it was predicted by the forecast
#' 
#' @param psp tibble of psp observations
#' @param predictions tibble of psp forecast predictions
#' @return a table with one row per site
#' 
#' @export
find_closures <- function(psp, predictions) {
  
  find_predicted_closure <- function(tbl, key) {
    
    closure_predictions <- tbl |>
      dplyr::filter(.data$predicted_class == 3)
    
    if (nrow(closure_predictions) > 0) {
      r <- dplyr::tibble(location = key$location[1],
                         predicted_date = min(closure_predictions$date) + 7) |>
        dplyr::mutate(predicted_week = format(.data$predicted_date, format = "%W"))
    } else {
      r <- dplyr::tibble(location = key$location[1],
                         predicted_date = NA,
                         predicted_week = NA)
    }
  }
  
  find_actual_closure <- function(tbl, key) {
    
    closure_measurements <- tbl |>
      dplyr::filter(.data$total_toxicity >= 80)
    
    if (nrow(closure_measurements) > 0) {
      r <- dplyr::tibble(location = key$location_id[1],
                         actual_date = min(closure_measurements$date)) |>
        dplyr::mutate(actual_week = format(.data$actual_date, format = "%W"))
    } else {
      r <- dplyr::tibble(location = key$location_id[1],
                         actual_date = NA,
                         actual_week = NA)
    }
  }
  
  predicted_closures <- predictions |>
    dplyr::arrange(.data$date) |>
    dplyr::group_by(.data$location) |>
    dplyr::group_map(find_predicted_closure, .keep=TRUE) |>
    dplyr::bind_rows()
  
  actual_closures <- psp |>
    dplyr::filter(.data$location_id %in% predictions$location,
                  dplyr::between(.data$date, min(predictions$date), max(predictions$date))) |>
    dplyr::arrange(.data$date) |>
    dplyr::group_by(.data$location_id) |>
    dplyr::group_map(find_actual_closure, .keep=TRUE) |>
    dplyr::bind_rows()
  
  r <- dplyr::left_join(predicted_closures, actual_closures)
}


