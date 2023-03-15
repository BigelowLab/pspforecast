

hline <- function(y = 0, color = "black") {
  list(
    type = "line",
    x0 = 0,
    x1 = 1,
    xref = "paper",
    y0 = y,
    y1 = y,
    line = list(color = color)
  )
}






plot_ly(data=results, 
        x=~prob_3, 
        y=~toxicity,
        #color=~correct,
        #colors = pal,
        type="scatter",
        mode="markers",
        text=~paste("Location:", location, "<br>", "Date:", date, "<br>", "Predicted Class:", predicted_class, "<br>", "Actual Class", class)) |>
  layout(shapes=hline(80),
         #legend=list(title=list(text='<b> Prediction was correct </b>')),
         xaxis = list(title = list(text ='<b>Predicted Probability of Closure-level Toxicity (%)</b>')),
         yaxis = list(title = list(text ='<b>Toxicity Measured During Forecast Period (units)</b>')))




ggplot2::ggplot() +
  ggplot2::geom_rect(xmin=2014,
                     xmax=2022,
                     ymin=-Inf,
                     ymax=Inf,
                     fill="pink",
                     alpha=0.1) +
  #ggplot2::geom_point(data=toxin_counts, ggplot2::aes(x=.data$year, y=.data$samples)) +
  geom_rect(aes(xmin=2014, xmax=Inf, ymin=0, ymax=Inf), alpha=0.4, color="blue") +
  ggplot2::geom_line(data=toxin_counts, ggplot2::aes(x=.data$year, y=.data$samples)) + 
  labs(x = "Year", y = "Toxicity Measurements") +
  theme(text = element_text(size=15))
