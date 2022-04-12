
library(dplyr)
library(ggplot2)


pred <- pspforecast::read_forecast() %>% 
  dplyr::mutate(week = format(date, format="%V"),
                id = paste(location, week, sep="_"))

psp <- pspdata::read_psp_data() %>% 
  dplyr::filter(location_id %in% pred$location,
                date > as.Date("2021-01-01"),
                date < as.Date("2021-12-31")) %>% 
  dplyr::mutate(week = format(date, format="%V"),
                id = paste(location_id, week, sep="_")) 





plot <- ggplot2::ggplot() +
  #ggplot2::geom_point(data = psp, shape=1, ggplot2::aes(x=date, y=location_id)) +
  ggplot2::geom_point(data= pred, shape=15, ggplot2::aes(x=forecast_start_date, y=name)) +
  ggplot2::labs(x = "Date",
                y = "PSP Sampling Station")



plot
