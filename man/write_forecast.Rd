% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/forecast_io.R
\name{write_forecast}
\alias{write_forecast}
\title{Adds or appends a new forecast file of predictions/data to the database}
\usage{
write_forecast(new_predictions, user_config)
}
\arguments{
\item{new_predictions}{list with two tibbles of new shellfish toxicity predictions}

\item{user_config}{list of user configurations including paths to forecastdb files. use `write_user_config()` to generate one}
}
\description{
Adds or appends a new forecast file of predictions/data to the database
}
