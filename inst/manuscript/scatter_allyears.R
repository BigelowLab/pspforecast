
library(pspforecast)
library(pspdata)
library(ggplot2)

pred_w_results <- read_all_results()

plot2 <- ggplot2::ggplot(data = pred_w_results, ggplot2::aes(x=.data$p_3, y=.data$toxicity, colour = cl_correct)) +
  ggplot2::geom_point(alpha=0.7, size=3) +
  ggplot2::facet_grid(cols=vars(.data$year)) +
  ggplot2::labs(x = "Predicted Probability of Closure-level Toxicity (%)",
                y = "Measured Toxicity (μg STX eq/ 100 g shellfish)") +
  ggplot2::geom_hline(yintercept=80, linetype="dashed") +
  ggplot2::theme_bw() +
  theme(axis.text=  ggplot2::element_text(size=14),
        axis.title= ggplot2::element_text(size=14,face="bold"),
        title =     ggplot2::element_text(size = 14, face = "bold"),
        legend.position = "none",
        strip.text.x = element_text(size = 20))

ggplot2::ggplot(data = pred_w_results, ggplot2::aes(x=.data$p_3, y=.data$toxicity, colour = correct)) +
  ggplot2::geom_point(alpha=0.7, size=3) +
  ggplot2::facet_grid(cols=vars(.data$year)) +
  ggplot2::labs(x = "Predicted Probability of Closure-level Toxicity (%)",
                y = "Measured Toxicity (μg STX eq/ 100 g shellfish)") +
  ggplot2::geom_hline(yintercept=80, linetype="dashed") +
  ggplot2::theme_bw() +
  theme(axis.text=  ggplot2::element_text(size=14),
        axis.title= ggplot2::element_text(size=14,face="bold"),
        title =     ggplot2::element_text(size = 14, face = "bold"),
        legend.position = "none",
        strip.text.x = element_text(size = 20))

plot2

# Save plot

ggsave(filename = "inst/manuscript/scatter_allyears.jpeg", plot=plot2, width=12, height=8)
