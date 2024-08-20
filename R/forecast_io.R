#' Reads forecast database
#' 
#' @param format logical, if true, the forecast report will be formatted for stakeholders with rounded probabilities and 0 probabilities being changed to <1
#' @param new_only logical, if true, then only the newest observations from each station will be served
#' @param shiny logical, if true, forecast will be read from github csv rather than local; method used for deploying package in shiny app server
#' @param id logical if true the tibble of predictions returned will have an f_id column that is the location and date pasted together
#' @param year character string selecting which year's predictions to read - default is to find the most recent year in the forecastdb directory
#' @return tibble of predicted shellfish toxicity classifications along with their metadata
#' 
#' @export
read_forecast <- function(format = FALSE, 
                          new_only=FALSE,
                          shiny=FALSE,
                          id = FALSE,
                          year=get_recent_year()) {
  
  if (shiny) {
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
      dplyr::mutate(p_0 = format_probs(.data$p_0),
                    p_1 = format_probs(.data$p_1),
                    p_2 = format_probs(.data$p_2),
                    p_3 = format_probs(.data$p_3)) 
  }
  
  if (id) {
    forecast <- forecast |>
      dplyr::mutate(f_id = paste(.data$location, .data$date, sep="_"))
  }
  
  return(forecast)
}


#' Reads all predictions from all years into one tibble
#' @param years numeric vector of years
#' @returns tibble with all predictions made
#' @export
read_all_predictions <- function(years=2021:2023) {
  
  all_predictions <- dplyr::tibble()
  for (year in years) {
    r <- read_forecast(year=year)
    
    if ("p_0" %in% colnames(r)) {
      r <- r |>
        dplyr::rename(prob_0 = .data$p_0,
                      prob_1 = .data$p_1,
                      prob_2 = .data$p_2,
                      prob_3 = .data$p_3)
    }
    
    all_predictions <- all_predictions |>
      dplyr::bind_rows(r) |>
      dplyr::mutate(year = as.numeric(format(date, format="%Y")))
  }
  return(all_predictions)
  
}


#' Adds or appends a new forecast file of predictions/data to the database 
#'
#' @param new_predictions list with two tibbles of new shellfish toxicity predictions
#' @param user_config list of user configurations including paths to forecastdb files. use `write_user_config()` to generate one
#' @return NULL
#' 
#' @export
write_forecast <- function(new_predictions, user_config) {
  
  suppressMessages(readr::write_csv(new_predictions$ensemble_forecast, file.path(user_config$output$ensemble_path), append=TRUE))
  
  suppressMessages(readr::write_csv(new_predictions$ensemble_runs, file.path(user_config$output$all_path), append=TRUE))
}


