

#num_levels <- length(cfg$image_list$tox_levels)
num_levels <- 4
levels <- seq(from=0, to=(num_levels-1))


cm <- as.data.frame(table(predicted = factor(pred_w_results$predicted_class, levels), actual = factor(pred_w_results$actual_class, levels))) %>% 
  mutate(frac = round(Freq/sum(Freq)*100)) %>% 
  mutate(frac = sapply(frac, function(x) if (x == "0") {x = "<1"} else {x}))

confusion_matrix <- ggplot2::ggplot(data = cm,
                                    mapping = ggplot2::aes(x = .data$predicted, y = .data$actual)) +
  ggplot2::geom_tile(ggplot2::aes(fill = log(.data$Freq+1))) +
  ggplot2::geom_text(ggplot2::aes(label = sprintf("%1.0f", .data$Freq)), vjust = 1, size=8) +
  #ggplot2::geom_text(ggplot2::aes(label = sprintf("%1.0f%%", .data$frac)), vjust = -1, hjust=1, size=5) +
  ggplot2::geom_text(ggplot2::aes(label = paste(.data$frac, "%", sep="")), vjust = 4, size=5)+
  ggplot2::scale_fill_gradient(low = "white", 
                               high = "blue") +
  ggplot2::labs(x = "Predicted Classifications", 
                y = "Actual Classifications", 
                #title=paste("Confusion Matrix -", cfg$train_test$test, sep=""),
                #subtitle=paste("Loss:", round(model$metrics[1], 3), "Accuracy:", round(model$metrics[2], 3), "Version:", cfg$configuration, sep=" "),
                caption=paste(Sys.Date())) +
  ggplot2::theme_linedraw() +
  ggplot2::theme(axis.text=  ggplot2::element_text(size=14),
                 axis.title= ggplot2::element_text(size=14,face="bold"),
                 title =     ggplot2::element_text(size = 14, face = "bold"),
                 legend.position = "none") 

confusion_matrix
