


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
                y = "Measured Toxicity") +
  ggplot2::geom_hline(yintercept=80, linetype="dashed") +
  ggplot2::theme_bw() +
  ggplot2::theme(axis.text=  ggplot2::element_text(size=18),
                 axis.title= ggplot2::element_text(size=18,face="bold"),
                 title =     ggplot2::element_text(size = 14, face = "bold"),
                 legend.position = "none",
                 strip.text.x = element_text(size = 18))
