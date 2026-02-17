#' Finds metrics from a table of forecast predictions
#' @param fc tibble of predictions
#' @param predicted_col character string of predicted classification column name
#' @param measured_col character string of measured classification column
#' @param positive_col character stirng of positive (closure-level) class column
#' @returns one row tibble of metrics
#' @export
forecast_metrics <- function(fc, 
                             predicted_col = "predicted_class", 
                             measured_col = "actual_class",
                             positive_col = "prob_3") {
  correct <- fc |>
    dplyr::filter(.data[[predicted_col]] == .data[[measured_col]]) |>
    nrow()
  tn <- fc |>
    dplyr::filter(.data[[predicted_col]] != 3 & .data[[measured_col]] != 3) |>
    nrow()
  tp <- fc |> 
    dplyr::filter(.data[[predicted_col]] == 3 & .data[[measured_col]] == 3) |> 
    nrow()
  fp <- fc |> 
    dplyr::filter(.data[[predicted_col]] == 3 & .data[[measured_col]] != 3) |> 
    nrow()
  fn <- fc |> 
    dplyr::filter(.data[[predicted_col]] != 3 & .data[[measured_col]] == 3) |> 
    nrow()
  
  precision <- tp/(tp+fp)
  recall <- tp/(tp+fn)
  sensitivity <- tp/(tp+fn)
  specificity <- tn/(tn+fp)
  
  f_1 <- (2)*(precision*recall)/(precision+recall)
  cl_accuracy <- (tn+tp)/nrow(fc)
  accuracy <- correct/nrow(fc)
  
  fc <- dplyr::mutate(fc,
                      brier_outcome = ifelse(.data[[measured_col]] == 3, 1, 0),
                      brier_score = ((.data[[positive_col]]/100) - .data$brier_outcome)^2)
  
  metrics_c3 <- dplyr::tibble(tp = tp,
                              fp = fp,
                              tn = tn,
                              fn = fn,
                              accuracy = round(accuracy, 3),
                              cl_accuracy = round(cl_accuracy, 3),
                              brier = round(mean(fc$brier_score), 3),
                              f_1=f_1,
                              precision = precision,
                              sensitivity = sensitivity,
                              specificity = specificity)
  
  return(metrics_c3)
}

#' Finds skill metrics for each station included in the experimental forecast
#' @param results tibble of results with columns class for truth and predicted class for estimate
#' @returns tibble of metrics with one row per station
#' @export
find_station_metrics <- function(results = read_all_results()) {
  
  check_station <- function(tbl, key) {
    dplyr::tibble(location = key$location[1],
                  lat = tbl$lat[1],
                  lon = tbl$lon[1],
                  accuracy = yardstick::accuracy_vec(truth = factor(tbl$class, levels = c(0,1,2,3)), estimate=factor(tbl$predicted_class, , levels = c(0,1,2,3))),
                  predictions = nrow(tbl))
  }
  
  r <- results |>
    dplyr::group_by(.data$location) |>
    dplyr::group_map(check_station) |>
    dplyr::bind_rows()
  
  return(r)
}
