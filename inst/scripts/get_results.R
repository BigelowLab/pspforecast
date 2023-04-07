

library(pspforecast)
library(pspdata)

library(readr)


psp <- read_psp_data() |> 
  dplyr::mutate(year = as.numeric(format(date, format="%Y")),
                doy = as.numeric(format(date, format="%j")),
                week = as.numeric(format(date, format="%U")))



## 2021 Season


predictions21 <- read_forecast(season = "2021")

x <- add_forecast_results(predictions21, toxin_measurements = psp) 

summary(x)

x |>
  write_csv("psp_forecast_results_2021.csv.gz")

## 2022 Season

predictions22 <- read_forecast(season = "2022")


xx <- add_forecast_results(predictions22, toxin_measurements = psp) 

summary(xx)

xx |>
  write_csv("psp_forecast_results_2022.csv.gz")
