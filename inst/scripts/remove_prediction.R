# Remove a prediction from forecast db

library(readr)
library(dplyr)
library(devtools)


read_csv("inst/forecastdb/psp_forecast_2026.csv.gz") |>
  filter(!f_id == "PSP14.35_2026-06-30_mytilus") |>
  write_csv("inst/forecastdb/psp_forecast_2026.csv.gz")

read_csv("inst/forecastdb/psp_forecast_all_predictions_2026.csv.gz") |>
  filter(location == "PSP14.35", date == "2026-06-30")


read_csv("inst/forecastdb/psp_forecast_all_predictions_2026.csv.gz") |>
  filter(!f_id == "PSP14.35_2026-06-30_mytilus") |>
  write_csv("inst/forecastdb/psp_forecast_all_predictions_2026.csv.gz")



install()
