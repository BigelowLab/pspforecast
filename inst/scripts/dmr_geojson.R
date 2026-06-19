

library(readr)
library(sf)

read_csv("inst/forecastdb/dmr_webpage_table.csv") |>
  #rename(lat = Latitude,
  #       lon = Longitude) |>
  #add_lat_lon(station_col = "DMR Station ID") |>
  #rename(Latitude = lat,
  #       Longitude = lon) |>
  st_as_sf(coords = c('Longitude', 'Latitude'), crs = 4326) |>
  st_write('inst/forecastdb/dmr_webpage_table.geojson', delete_dsn=TRUE)

