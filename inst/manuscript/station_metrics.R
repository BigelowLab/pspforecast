
#' Finds skill metrics for each station included in the experimental forecast
#' @param results tibble of results with columns class for truth and predicted class for estimate
#' @returns tibble of metrics with one row per station
find_station_metrics <- function(results = read_all_results()) {
  
  check_station <- function(tbl, key) {
    dplyr::tibble(location = key$location[1],
                  lat = tbl$lat[1],
                  lon = tbl$lon[1],
                  accuracy = yardstick::accuracy_vec(truth = factor(tbl$class, levels = c(0,1,2,3)), estimate=factor(tbl$predicted_class, , levels = c(0,1,2,3))),
                  predictions = nrow(tbl))
  }
  
  r <- results |>
    dplyr::group_by(location) |>
    dplyr::group_map(check_station) |>
    dplyr::bind_rows()
  
  return(r)
}


plot_station_metrics <- function(st_metrics) {
  
  bb <- c(xmin = -71, ymin = 43, xmax = -66.5, ymax = 45.5)

  coast = rnaturalearth::ne_coastline(scale = "large", returnclass = 'sf') |>
    sf::st_crop(sf::st_bbox(bb))
  north_am <- rnaturalearth::ne_countries(scale = 10, returnclass = "sf", continent = "North America") |>
    sf::st_crop(sf::st_bbox(bb))
  
  states <- rnaturalearth::ne_states(country="united states of america", returnclass = "sf") |>
    sf::st_crop(sf::st_bbox(bb))
  
  p <- ggplot2::ggplot(data = north_am) +
    ggplot2::geom_sf(fill = "antiquewhite") +
    ggplot2::geom_sf(data = coast, color = "gray") +
    ggplot2::geom_sf(data = states, color="black") +
    ggplot2::theme_bw() +
    ggplot2::geom_point(data = st_metrics, 
                        ggplot2::aes(x = .data$lon, y = .data$lat, colour=.data$accuracy),
                        size=1) +
    #ggplot2::scale_color_gradient(low="black", high="red") + 
    ggplot2::scale_color_viridis_b()
  
  p
}


st_metrics <- find_station_metrics()

plot3 <- plot_station_metrics(st_metrics)


# Save plot

ggsave(filename = "inst/manuscript/station_metrics_allyears.jpeg", plot=plot3, width=6, height=4)
