#' Checks the most recent year in the forecast directory in github.com/pspforecast/inst/forecastdb
#' 
#' @param earliest numeric defining the earliest expected year in the directory
#' @return a character year of the most recent prediction file 
#'  
#' @export
get_recent_year <- function(earliest = 2021) {
  
  check_url =  function(x){
    !httr::http_error(httr::HEAD(x))
  }
  
  year <- as.numeric(format(Sys.Date(), format="%Y")) + 1
  
  ok <- FALSE
  
  while (ok == FALSE) {
    
    year <- year - 1
    
    if (year < earliest) {
      break()
    }
    
    url <- sprintf("%s%s%s",
                  "https://github.com/BigelowLab/pspforecast/raw/master/inst/forecastdb/psp_forecast_",
                  year,
                  ".csv.gz")
    
    ok <- check_url(url)
  }
  return(year)
}

