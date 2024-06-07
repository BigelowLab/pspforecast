

library(readr)
library(sf)

read_csv("inst/forecastdb/dmr_webpage_table.csv") |>
  st_as_sf(coords = c('Longitude', 'Latitude'), crs = 4326) |>
  st_write('inst/forecastdb/dmr_webpage_table.geojson')

