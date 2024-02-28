## Makes a facet plot with a scatter of predicted probability of closure level toxicity vs actual measured toxicity during forecast period

library(pspforecast)
library(pspdata)
library(ggplot2)

pred_w_results <- read_all_results()

ggplot2::ggplot(data = pred_w_results, ggplot2::aes(x=.data$p_3, y=.data$toxicity)) +
  ggplot2::geom_point(alpha=0.7, size=3) +
  ggplot2::facet_grid(cols=vars(.data$year)) +
  ggplot2::labs(x = "Predicted Probability of Closure-level Toxicity",
                y = "Measured Toxicity") +
  ggplot2::geom_hline(yintercept=80, linetype="dashed") +
  ggplot2::theme_bw()
