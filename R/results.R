#' Reads experimental predictions matched with their outcome for one year
#' @param year integer year to read
#' @returns tibble of results
#' @export
read_results <- function(year=c(2021,2022,2023)[1]) {
  file_end <- sprintf("%s%s%s",
                      "forecastdb/seasonal_results/psp_forecast_results_",
                      year,
                      ".csv.gz")
  
  file = system.file(file_end, package="pspforecast")
  
  suppressMessages(readr::read_csv(file))
}

#' Reads all results in seasonal_results directory
#' @param years vector of integer years
#' @return tibble of results
#' @export
read_all_results <- function(years=2021:2023) {
  all_results <- dplyr::tibble()
  for (year in years) {
    r <- read_results(year)
    
    all_results <- all_results |>
      dplyr::bind_rows(r) |>
      dplyr::mutate(year = as.numeric(format(date, format="%Y")))
  }
  return(all_results)
}