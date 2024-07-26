

library(dplyr)
library(ggplot2)

library(pspdata)
library(pspforecast)

devtools::load_all()

psp <- read_plone()

pred_w_results <- read_all_results()

num_levels <- 4
levels <- seq(from=0, to=(num_levels-1))

cm <- as.data.frame(table(predicted = factor(pred_w_results$predicted_class, levels), actual = factor(pred_w_results$class, levels), year=factor(pred_w_results$year, levels=2021:2024))) |> 
  dplyr::mutate(frac = round(Freq/sum(Freq)*100)) |> 
  dplyr::mutate(frac = sapply(.data$frac, function(x) if (x == "0") {x = "<1"} else {x}))

# res 1400x850

ggplot2::ggplot(data = cm, ggplot2::aes(x = .data$predicted, y = .data$actual)) +
  ggplot2::geom_tile(ggplot2::aes(fill = log(.data$Freq+1))) +
  ggplot2::geom_text(ggplot2::aes(label = sprintf("%1.0f", .data$Freq)), size=8) +
  ggplot2::facet_grid(cols=vars(.data$year)) +
  #ggplot2::geom_text(ggplot2::aes(label = paste(.data$frac, "%", sep="")), vjust = 3, size=4) +
  ggplot2::scale_fill_gradient(low = "white", 
                               high = "blue") +
  ggplot2::labs(x = "Predicted Classifications", 
                y = "Actual Classifications") +
  ggplot2::theme_linedraw() +
  ggplot2::theme(axis.text=  ggplot2::element_text(size=18),
                 axis.title= ggplot2::element_text(size=18,face="bold"),
                 title =     ggplot2::element_text(size = 14, face = "bold"),
                 legend.position = "none",
                 strip.text.x = element_text(size = 18)) +
  ggplot2::geom_rect(aes(xmin=0.5, xmax=3.5, ymin=0.5, ymax=3.5), alpha=0) +
  ggplot2::geom_rect(aes(xmin=3.5, xmax=4.5, ymin=3.5, ymax=4.5), alpha=0)


ggplot2::ggplot(data = pred_w_results, ggplot2::aes(x=.data$p_3, y=.data$toxicity)) +
  ggplot2::geom_point(alpha=0.7, size=3) +
  ggplot2::facet_grid(cols=vars(.data$year)) +
  ggplot2::labs(x = "Predicted Probability of Closure-level Toxicity (%)",
                y = "Measured Toxicity (μg STX 100g-1 shellfish)") +
  ggplot2::geom_hline(yintercept=80, linetype="dashed") +
  ggplot2::theme_bw() +
  ggplot2::theme(axis.text=  ggplot2::element_text(size=18),
                 axis.title= ggplot2::element_text(size=18,face="bold"),
                 title =     ggplot2::element_text(size = 14, face = "bold"),
                 legend.position = "none",
                 strip.text.x = element_text(size = 18))


# example_forecast

library(dplyr)

f <- read_results(year = 2022) |>
  filter(between(date, as.Date("2022-05-09"), as.Date("2022-05-10")))

