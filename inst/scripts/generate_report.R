## Write a weekly report then knit(path to markdown) or render() - NEW FUNCTION

d <- sprintf("%s_%s_%s.csv",
             format(Sys.Date(), format="%d"),
             format(Sys.Date(), format="%B"),
             format(Sys.Date(), format="%Y"))

weekly_file <- paste("inst/forecastdb/individual_forecasts/psp_forecast_", d, sep="")

weekly_file

ensemble$ensemble_forecast |> 
  dplyr::filter(date > as.Date(Sys.Date())-8) |> 
  dplyr::select(-version, -ensemble_n, -class_bins) |> 
  dplyr::arrange(desc(p_3)) |> 
  dplyr::mutate(p3_sd = round(p3_sd),
                p3_min = round(p_3_min),
                p3_max = round(p_3_max),
                .after = p3_sd) |> 
  dplyr::select(-p_3_min, -p_3_max) |> 
  dplyr::relocate(predicted_class, .after = p_3) |> 
  readr::write_csv(weekly_file)


