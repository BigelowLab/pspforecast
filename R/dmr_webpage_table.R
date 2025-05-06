#' Formats a psp forecast table for the DMR closure map webpage
#' @param f tibble of psp forecast predictions
#' @returns formatted tibble
#' @export
format_webpage_table <- function(f) {
  levels <- c("Low", "Medium", "High", "Closure-level")
  names(levels) <- c(0,1,2,3)
  
  lut <- c(Location = "name",
           `DMR Station ID` = "location",
           `Predicted Class` = "predicted_class",
           `Forecast Initialized Date` = "date",
           `Forecast Start Date` = "forecast_start_date",
           `Forecast End Date` = "forecast_end_date",
           `Closure-level PSP Probability` = "p_3",
           Latitude = "lat",
           Longitude = "lon")
  
  r <- f |>
    dplyr::select(-dplyr::all_of(c("version", "ensemble_n", "class_bins", "p_0", "p_1", "p_2", "p3_sd", "p_3_min", "p_3_max", "f_id"))) |>
    dplyr::mutate(predicted_class = levels[.data$predicted_class+1]) |>
    dplyr::rename(dplyr::all_of(lut))
  
  return(r)
}


#' Writes two table containing the current forecast. One is formatted for the Interactive Shellfish Closure 
#' Map and the other has all columns and no formatting.
#' 
#' @param user_config list of pspforecast user configuration containing paths to users local copies of both tables
#' @returns NULL
#' @export
write_forecast_tables <- function(user_config) {
  
  t_1 <- read_forecast(new_only=TRUE, id=FALSE) |> 
    dplyr::arrange(dplyr::desc(.data$p_3))
  
  suppressMessages(readr::write_csv(t_1, file.path(user_config$output$current_forecast)))
  
  t_2 <- read_forecast(new_only=TRUE, id=FALSE, format=TRUE) |> 
    format_webpage_table() 
    
  
  suppressMessages(readr::write_csv(t_2, file.path(user_config$output$dmr_webpage_table)))
  
}
