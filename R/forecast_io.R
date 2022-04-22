#' Takes a column of probabilities and formats them for stakeholder delivery (rounds to integer and adds percent symbol)
#' 
#' @param probs vector of probabilities
#' @return formatted vector of probabilities
#' 
#' @export
format_probs <- function(probs) {
  
  rounded <- sapply(probs, round)
  
  to_char <- sapply(rounded, as.character)
  
  no_zero <- sapply(to_char, function(x) if (x == "0") {x = "<1"} else {x})
  
  r <- sapply(no_zero, function(x) {return(paste(x, "%", sep=""))})
  
  return(r)
}


#' Reads forecast database
#' 
#' @param format logical, if true, the forecast report will be formatted for stakeholders with rounded probabilities and 0 probabilities being changed to <1
#' @param new_only logical, if true, then only the newest observations from each station will be served
#' @param shiny logical, if true, forecast will be read from github csv rather than local; method used for deploying package in shiny app server
#' @return tibble of predicted shellfish toxicity classifications along with their metadata
#' 
#' @export
read_forecast <- function(format = FALSE, 
                          new_only=FALSE,
                          shiny=FALSE) {
  
  if (shiny) {
    gh_file <- "https://github.com/BigelowLab/pspforecast/raw/master/inst/forecastdb/psp_forecast_2022.csv.gz"
    
    temp_forecast <- tempfile()
    download.file(gh_file, temp_forecast)
    
    forecast <- readr::read_csv(temp_forecast)
    
    unlink(temp_forecast)
  } else {
    file = system.file("forecastdb/psp_forecast_2022.csv.gz", package="pspforecast")
    
    forecast <- suppressMessages(readr::read_csv(file))
  }
  
  
  if (new_only) {
    #all_forecast <- suppressMessages(readr::read_csv(file))
    
    get_newest <- function(tbl, key) {
      newest <- tbl %>% 
        tail(n=1)
      return(newest)
    }
    
    forecast <- forecast %>% 
      dplyr::arrange(.data$date) %>% 
      dplyr::group_by(.data$location) %>% 
      dplyr::group_map(get_newest, .keep=TRUE) %>% 
      dplyr::bind_rows() 

  } 
  
  if (format) {
    forecast <- forecast %>% 
      dplyr::mutate(prob_0 = format_probs(.data$p_0),
                    prob_1 = format_probs(.data$p_1),
                    prob_2 = format_probs(.data$p_2),
                    prob_3 = format_probs(.data$p_3)) %>% 
      dplyr::select(-.data$version,
                    -.data$class_bins,
                    -.data$ensemble_n,
                    -.data$p_0,
                    -.data$p_1,
                    -.data$p_2,
                    -.data$p_3)
  }
  return(forecast)
}


#' Adds a new forecast file of predictions/data to the database 
#'
#' @param predictions tibble of new shellfish toxicity classification predictions
#' 
write_forecast <- function(predictions) {
  
  file <- file.path("inst/forecastdb/psp_forecast_2021.csv.gz")
  
  predictions %>% readr::write_csv(file, append=TRUE)
  
}


#' Adds new forecast data to the database
#' 
#' @param predictions tibble of new shellfish toxicity classification predictions
#' 
append_forecast <- function(predictions) {
  
  file <- file.path("inst/forecastdb/test_forecast_db.csv.gz")
  
  forecast_db <- read_forecast() %>% 
    rbind(predictions) %>% 
    dplyr::distinct() %>% 
    suppressMessages(readr::write_csv(file))
  
}

