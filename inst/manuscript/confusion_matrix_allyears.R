## Makes a facet grid of confusion matrices from all experimental forecast years

library(pspforecast)
library(pspdata)
library(ggplot2)

pred_w_results <- read_all_results()

num_levels <- 4
levels <- seq(from=0, to=(num_levels-1))


cm <- as.data.frame(table(predicted = factor(pred_w_results$predicted_class, levels), 
                          actual = factor(pred_w_results$class, levels), 
                          year=factor(pred_w_results$year, levels=2021:2024))) |> 
  dplyr::mutate(frac = round(Freq/sum(Freq)*100)) |> 
  dplyr::mutate(frac = sapply(.data$frac, function(x) if (x == "0") {x = "<1"} else {x}))

plot1 <- ggplot2::ggplot(data = cm, ggplot2::aes(x=.data$predicted, y=.data$actual)) +
  ggplot2::geom_tile(ggplot2::aes(fill = log(.data$Freq+1))) +
  ggplot2::geom_text(ggplot2::aes(label = sprintf("%1.0f", .data$Freq)), size=8) +
  ggplot2::facet_grid(cols=vars(.data$year)) +
  #ggplot2::geom_text(ggplot2::aes(label = paste(.data$frac, "%", sep="")), vjust = 3, size=4) +
  ggplot2::scale_fill_gradient(low = "white", 
                               high = "blue") +
  ggplot2::labs(x = "Predicted Classifications", 
                y = "Actual Classifications") +
  ggplot2::theme_linedraw() +
  ggplot2::theme(axis.text=  ggplot2::element_text(size=14),
                 axis.title= ggplot2::element_text(size=14,face="bold"),
                 title =     ggplot2::element_text(size = 14, face = "bold"),
                 legend.position = "none") +
  ggplot2::geom_rect(aes(xmin=0.5, xmax=3.5, ymin=0.5, ymax=3.5), alpha=0) +
  ggplot2::geom_rect(aes(xmin=3.5, xmax=4.5, ymin=3.5, ymax=4.5), alpha=0)

ggsave(filename = "inst/manuscript/cm_allyears.jpeg", plot=plot1, width=12, height=8)


