#' Reads forecast database
#' 
#' @param format logical, if true, the forecast report will be formatted for stakeholders with rounded probabilities and 0 probabilities being changed to <1
#' @param new_only logical, if true, then only the newest observations from each station will be served
#' @param shiny logical, if true, forecast will be read from github csv rather than local; method used for deploying package in shiny app server
#' @param id logical if true the tibble of predictions returned will have an f_id column that is the location and date pasted together
#' @param year character string selecting which year's predictions to read
#' @return tibble of predicted shellfish toxicity classifications along with their metadata
#' 
#' @export
read_forecast <- function(format = FALSE, 
                          new_only=FALSE,
                          shiny=FALSE,
                          id = FALSE,
                          year=c("2021", "2022", "2023")[3]) {
  
  if (shiny) {
    #gh_file <- "https://github.com/BigelowLab/pspforecast/raw/master/inst/forecastdb/psp_forecast_2022.csv.gz"
    gh_file <- sprintf("%s%s%s",
                       "https://github.com/BigelowLab/pspforecast/raw/master/inst/forecastdb/psp_forecast_",
                       year,
                       ".csv.gz")
    
    temp_forecast <- tempfile()
    download.file(gh_file, temp_forecast, quiet=TRUE)
    
    forecast <- suppressMessages(readr::read_csv(temp_forecast))
    
    unlink(temp_forecast)
  } else {
    file_end <- sprintf("%s%s%s",
                        "forecastdb/psp_forecast_",
                        year,
                        ".csv.gz")
    
    file = system.file(file_end, package="pspforecast")
    
    forecast <- suppressMessages(readr::read_csv(file))
  }
  
  
  if (new_only) {
    #all_forecast <- suppressMessages(readr::read_csv(file))
    
    get_newest <- function(tbl, key) {
      newest <- tbl |> 
        tail(n=1) |> 
        dplyr::filter(.data$forecast_end_date > Sys.Date()-3)
      return(newest)
    }
    
    forecast <- forecast |> 
      dplyr::arrange(.data$date) |> 
      dplyr::group_by(.data$location) |> 
      dplyr::group_map(get_newest, .keep=TRUE) |> 
      dplyr::bind_rows() 

  } 
  
  if (format) {
    forecast <- forecast |> 
      dplyr::mutate(prob_0 = format_probs(.data$p_0),
                    prob_1 = format_probs(.data$p_1),
                    prob_2 = format_probs(.data$p_2),
                    prob_3 = format_probs(.data$p_3)) |> 
      dplyr::select(-.data$version,
                    -.data$class_bins,
                    -.data$ensemble_n,
                    -.data$p_0,
                    -.data$p_1,
                    -.data$p_2,
                    -.data$p_3)
  }
  
  if (id) {
    forecast <- forecast |>
      dplyr::mutate(f_id = paste(.data$location, .data$date, sep="_"))
  }
  
  return(forecast)
}


#' Adds or appends a new forecast file of predictions/data to the database 
#'
#' @param new_predictions list with two tibbles of new shellfish toxicity predictions
#' @param user_config character
#' @return NULL
#' 
#' @export
write_forecast <- function(new_predictions, user_config) {
  
  suppressMessages(readr::write_csv(new_predictions$ensemble_forecast, file.path(user_config$output$ensemble_path), append=TRUE))
  
  suppressMessages(readr::write_csv(new_predictions$ensemble_runs, file.path(user_config$output$all_path), append=TRUE))
  
}
