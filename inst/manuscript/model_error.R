# Produces mdoel error figure for manuscript
# error defined as predicted class - actual (measured) class

suppressPackageStartupMessages({
  library(pspforecast)
  library(dplyr)
  library(ggplot2)
  library(pspdata)
  library(tidyr)
})

psp <- read_psp_data()

p <- read_all_results() |>
  mutate(error = as.factor(.data$predicted_class -.data$class),
         day = as.numeric(format(date, format="%j")),
         week = as.numeric(format(date, format="%U")),
         season = as.factor(format(date, format="%Y")),
         id = paste(location, season, sep="_")) |> 
  group_by(year) |>
  group_map(.keep=TRUE,
            function(tbl, key) {
              first_week <- as.numeric(format(min(tbl$date), format="%U"))
              first_day <-  as.numeric(format(min(tbl$date), format="%j"))
              
              tbl <- tbl |>
                mutate(sweek=(as.numeric(format(.data$date, format="%U"))-first_week)+1,
                       sday=as.numeric(format(.data$date, format="%j"))-first_day)
            }) |>
  bind_rows()

ggplot(p, aes(x=sweek, y=error)) +
  geom_jitter() +
  theme_bw()

ggplot(p, aes(x=lon, y=error)) +
  geom_point() +
  theme_bw()



t <- p |>
  select(location, date, year, lon, sweek, error) |>
  pivot_longer(cols = c(lon, sweek), names_to="name", values_to = "value")

test.labs <- c("Longitude", "Season-week")
names(test.labs) <- c("lon", "sweek")



error_plot <- ggplot(data=t, aes(x=value, y=error)) +
  geom_jitter() +
  facet_grid(cols=vars(name), 
             scales="free_x",
             labeller = labeller(name = test.labs)) +
  theme_bw() +
  theme(axis.title.x=element_blank(),
        axis.title.y=element_text(size = 14,face="bold"),
        axis.text = ggplot2::element_text(size=14),
        strip.text.x = element_text(size = 20))

ggsave(filename = "inst/manuscript/model_error.jpeg", plot=error_plot, width=12, height=8)
