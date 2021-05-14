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
      dplyr::filter(location_id == key$location[1]) %>% 
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
      dplyr::select(version, location, date) %>% 
      dplyr::mutate(measurement_date = as.Date(db$date),
                    toxicity = db$total_toxicity,
                    actual_class = db$classification)
    
    return(forecast_results)
  }
  
  results <- predictions %>%
    dplyr::group_by(location, date) %>% 
    dplyr::group_map(find_result, .keep=TRUE) %>% 
    dplyr::bind_rows() %>% 
    dplyr::arrange(date)
  
  forecast_w_results <- dplyr::full_join(predictions, results, by=c("version", "location", "date")) %>% tidyr::drop_na()
  return(results)
}



num_levels <- 4
levels <- seq(from=0, to=(num_levels-1))

cm <- as.data.frame(table(predicted = factor(forecast_w_results$predicted_class, levels), actual = factor(forecast_w_results$actual_class, levels)))

confusion_matrix <- ggplot2::ggplot(data = cm,
                                    mapping = ggplot2::aes(x = .data$predicted, y = .data$actual)) +
  ggplot2::geom_tile(ggplot2::aes(fill = log(.data$Freq+1))) +
  ggplot2::geom_text(ggplot2::aes(label = sprintf("%1.0f", .data$Freq)), vjust = 1, size=8) +
  ggplot2::scale_fill_gradient(low = "white", 
                               high = "blue") +
  ggplot2::labs(x = "Predicted Classifications", 
                y = "Actual Classifications", 
                title=paste("Forecast Results as of 14 May 2021"),
                subtitle=paste("Accuracy: 82.1%"),
                caption=paste(Sys.Date())) +
  ggplot2::theme_linedraw() +
  ggplot2::theme(axis.text=  ggplot2::element_text(size=14),
                 axis.title= ggplot2::element_text(size=14,face="bold"),
                 title =     ggplot2::element_text(size = 14, face = "bold"),
                 legend.position = "none") 

