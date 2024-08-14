

find_cl_metrics <- function() {
  tn <- pred_w_results |>
    dplyr::filter(predicted_class != 3 & class != 3) |>
    nrow()
  
  tp <- pred_w_results |> 
    dplyr::filter(.data$predicted_class == 3 & .data$class == 3) |> 
    nrow()
  
  fp <- pred_w_results |> 
    dplyr::filter(.data$predicted_class == 3 & .data$class != 3) |> 
    nrow()
  
  precision = tp/(tp+fp)
  
  fn = pred_w_results |> 
    dplyr::filter(.data$predicted_class != 3 & .data$class == 3) |> 
    nrow()
  
  recall = tp/(tp+fn)
  
  f_1 = (2)*(precision*recall)/(precision+recall)
  
  sensitivity = tp/(tp+fn)
  
  specificity = tn/(tn+fp)
  
  cl_accuracy = (tn+tp)/nrow(pred_w_results)
  
  metrics_c3 <- tibble(tp = tp,
                       fp = fp,
                       tn = tn,
                       fn = fn,
                       cl_accuracy = cl_accuracy,
                       precision = precision,
                       sensitivity = sensitivity,
                       specificity = specificity)
  
  return(metrics_c3)
}