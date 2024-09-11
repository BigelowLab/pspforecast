

library(pspforecast)
library(pspdata)

library(readr)
library(dplyr)


psp <- read_psp_data() |> 
  dplyr::mutate(year = as.numeric(format(date, format="%Y")),
                doy = as.numeric(format(date, format="%j")),
                week = as.numeric(format(date, format="%U")))


## 2021 Season


predictions21 <- read_forecast(year = "2021") |>
  rename(p_0=prob_0,
         p_1=prob_1,
         p_2=prob_2,
         p_3=prob_3)
x <- add_forecast_results(predictions21, toxin_measurements = psp) 

summary(x)

write_csv(x, "inst/forecastdb/seasonal_results/psp_forecast_results_2021.csv.gz")

## 2022 Season

predictions22 <- read_forecast(year = "2022")
xx <- add_forecast_results(predictions22, toxin_measurements = psp) 

summary(xx)

write_csv(xx, "inst/forecastdb/seasonal_results/psp_forecast_results_2022.csv.gz")

## 2023

predictions23 <- read_forecast(year=2023)
xx <- add_forecast_results(predictions23, toxin_measurements = psp) 

summary(xx)

write_csv(xx, "inst/forecastdb/seasonal_results/psp_forecast_results_2023.csv.gz")

## 2024

predictions24 <- read_forecast(year=2024)
xx <- add_forecast_results(predictions24, toxin_measurements = psp) 

summary(xx)

write_csv(xx, "inst/forecastdb/seasonal_results/psp_forecast_results_2024.csv.gz")

