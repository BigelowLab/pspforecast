#' Finds metrics from a table of forecast predictions
#' @param fc tibble of predictions
#' @param predicted_col character string of predicted classification column name
#' @param measured_col character string of measured classification column
#' @export
forecast_metrics <- function(fc, 
                             predicted_col = "predicted_class", 
                             measured_col = "actual_class") {
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
  
  metrics_c3 <- dplyr::tibble(tp = tp,
                              fp = fp,
                              tn = tn,
                              fn = fn,
                              accuracy = accuracy,
                              cl_accuracy = cl_accuracy,
                              f_1=f_1,
                              precision = precision,
                              sensitivity = sensitivity,
                              specificity = specificity)
  
  return(metrics_c3)
}