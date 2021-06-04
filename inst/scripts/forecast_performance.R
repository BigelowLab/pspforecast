
library(dplyr)

#' After making predictions the week prior, add the actual toxicity classification to assess
#' 
#' @param predictions table of predictions (from pspforecast::read_forecast())
#' @param tox_levels vector of toxicity classification bins
#' @return table of predictions with the closest matching toxicity measurement
#' 
add_forecast_results <- function(predictions, 
                                 tox_levels = c(0,10,30,80)) {
  
  toxin_measurements <- pspdata::read_psp_data(model_ready=TRUE) %>% 
    dplyr::mutate(classification = psptools::recode_classification(.data$total_toxicity, tox_levels)) %>% 
    dplyr::filter(date >= min(predictions$forecast_start_date))
  
  
  find_result <- function(tbl, key, tox=NULL) {
    
    db <- tox %>% 
      dplyr::filter(location_id == key$location[1]) %>% #add break
      dplyr::filter(dplyr::between(date, tbl$forecast_start_date, tbl$forecast_end_date))
    
    if (nrow(db) == 0) {
      
      today=Sys.Date()
      
      empty_results <-   dplyr::tibble(version = character(),
                                       location = character(),
                                       date = today,
                                       measurement_date = today,
                                       toxicity = numeric(),
                                       actual_class = numeric())
      
      return(empty_results)
    }
    
    forecast_results <- tbl %>% 
      dplyr::select(version, location, date) %>% 
      dplyr::mutate(measurement_date = as.Date(db$date),
                    toxicity = db$total_toxicity,
                    actual_class = db$classification)
    
    return(forecast_results)
  }
  
  results <- predictions %>%
    dplyr::group_by(location, date) %>% 
    dplyr::group_map(find_result, .keep=TRUE, tox=toxin_measurements) %>% 
    dplyr::bind_rows() %>% 
    dplyr::arrange(date)
  
  forecast_w_results <- dplyr::full_join(predictions, results, by=c("version", "location", "date")) %>% 
    tidyr::drop_na(.data$actual_class)
  
  return(forecast_w_results)
}



#' Make a confusion matrix for predictions made during experimental forecast season
#' 
#' @param results a list of predictions from the season matched with actual measurements
#' @return confusion matrix
#' 
#' 
plot_season <- function(results) {
  
  total_predictions <- nrow(results)
  
  correct <- results %>% 
    dplyr::filter(predicted_class == actual_class) %>% 
    nrow()
  
  accuracy <- round(correct/total_predictions, digits=3) *100
  
  closures <- results %>% 
    dplyr::filter(actual_class == 3) %>% 
    nrow()
  
  correct_closures <- results %>% 
    dplyr::filter(predicted_class == 3 & actual_class == 3) %>% 
    nrow()
  
  fn <- results %>% 
    dplyr::filter(actual_class !=3 & predicted_class == 3) %>% 
    nrow()
  
  fp <- results %>% 
    dplyr::filter(actual_class == 3 & predicted_class != 3) %>% 
    nrow()
  
  tp <- correct_closures
  
  tn <- results %>% 
    dplyr::filter(actual_class != 3 & predicted_class != 3) %>% 
    nrow()
  
  sensitivity <- tp/tp+fn
  
  specificity <- tn/tn+fp
  
  closure_accuracy <- (tp+tn)/(tp+tn+fp+fn)
  
  num_levels <- 4
  levels <- seq(from=0, to=(num_levels-1))
  
  cm <- as.data.frame(table(predicted = factor(results$predicted_class, levels), actual = factor(results$actual_class, levels)))
  
  confusion_matrix <- ggplot2::ggplot(data = cm,
                                      mapping = ggplot2::aes(x = .data$predicted, y = .data$actual)) +
    ggplot2::geom_tile(ggplot2::aes(fill = log(.data$Freq+1))) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%1.0f", .data$Freq)), vjust = 1, size=8) +
    ggplot2::scale_fill_gradient(low = "white", 
                                 high = "blue") +
    ggplot2::labs(x = "Predicted Classifications", 
                  y = "Actual Classifications", 
                  title=paste("2021 PSP Forecast Performance"),
                  subtitle=paste("Accuracy:", accuracy, "%", sep = " "),
                  caption=paste(Sys.Date())) +
    ggplot2::theme_linedraw() +
    ggplot2::theme(axis.text=  ggplot2::element_text(size=14),
                   axis.title= ggplot2::element_text(size=14,face="bold"),
                   title =     ggplot2::element_text(size = 14, face = "bold"),
                   legend.position = "none") 
  
  return(confusion_matrix)
}



predictions <- pspforecast::read_forecast()

results <- add_forecast_results(predictions)

confusion_matrix <- plot_season(results)

confusion_matrix
