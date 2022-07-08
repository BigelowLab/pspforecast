
library(dplyr)
library(ggplot2)
library(pspdata)
library(pspforecast)
library(readr)

predictions22 <- read_forecast() #|> filter(lat <= 43.6)
predictions21 <- read_csv("inst/forecastdb/psp_forecast_2021.csv.gz")

psp <- read_psp_data()

p22 <- add_forecast_results(predictions22, psp)
p21 <- add_forecast_results(predictions21, psp)

p22 <- p22 %>% 
  select(location, date, p_3, measurement_date, toxicity)

p21 <- p21 %>% 
  select(location, date, prob_3, measurement_date, toxicity) %>% 
  rename(p_3 = prob_3)

plot_data <- bind_rows(p21, p22)

#plot_data <- p22


plot <- ggplot(data=plot_data, aes(x=p_3, y=toxicity)) +
  geom_point(alpha=0.7, size=4, color="dodgerblue4") +
  geom_hline(yintercept=80, linetype="dashed") +
  labs(x = "Predicted Probability of Closure-level Toxicity",
       y = "Measured Toxicity During Forecast Period")

plot

