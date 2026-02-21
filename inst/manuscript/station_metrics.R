# Generates individual station metric plots for manuscript broken up by Eastern/Western Maine

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(ggrepel)
  library(sf)
  library(rnaturalearth)
  
  library(pspdata)
  library(pspforecast)
  
  library(ggspatial)
  library(gridExtra)
  library(grid)
})

st_metrics <- find_station_metrics() |>
  pspdata::add_lat_lon(station_col = "location", after_col = "location") |>
  dplyr::mutate(place = ifelse(lon < -69, "west", "east")) 

maine <- st_read("inst/manuscript/necoast/Northeast_Coast.shp")

## western maine staions

west <- filter(st_metrics, place=="west") |>
  mutate(st_num = seq(1,n(),1),
         st_lab = paste(st_num, ". ", name, sep=""))

#we're going to set the theme for our legend to have a blank white background with no row striping 
white_theme <- ttheme_default(
  core = list(
    fg_params = list(fontface = "plain",
                     fontsize = 7),
    bg_params = list(fill = "white", 
                     col = NA)))

#station_table <- as.data.frame(list(a = west$st_lab[1:17], b=west$st_lab[18:34], cc=c(west$st_lab[35:50],NA)))
station_table <- as.data.frame(list(a = west$st_lab[1:13], b=west$st_lab[14:26], cc=west$st_lab[27:39], cc=c(west$st_lab[40:50],"", "")))

#make a grob
grob_df <- tableGrob(station_table, rows = NULL, cols=NULL, theme = white_theme)

#add border to grob
grob_df <- gtable::gtable_add_grob(
  grob_df,
  grobs = rectGrob(gp = gpar(fill = NA, lwd = 1)),
  t = 1, 
  l = 1, 
  b = nrow(grob_df), 
  r = ncol(grob_df)
)

western_plot_label = tribble(
  ~text, ~lon, ~lat,
  "A",   -70.0,    44.1
)

western_labels = tribble(
  ~text, ~lon, ~lat,
  "Southern Maine",   -70.4,    43.1,
  "Casco Bay",        -70.0,    43.6,
  "Midcoast",         -69.1,    43.82
)


p_west <- ggplot2::ggplot(data = maine) +
  geom_sf(data=maine, 
          fill = "grey", 
          color = "black", 
          linewidth = 0.1) +
  ggplot2::theme_classic() +
  ggplot2::geom_point(data = west, 
                      aes(x = .data$lon, 
                          y = .data$lat, 
                          colour=.data$accuracy),
                      size=4) +
  geom_text(data = western_plot_label,
            aes(x = lon, 
                y = lat, 
                label = text),
            size = 10,
            family = "serif") +
  geom_text(data = western_labels,
            aes(x = lon, 
                y = lat, 
                label = text),
            size = 5,
            family = "serif") +
  geom_label_repel(data=west, 
                   aes(x=lon, 
                       y=lat, 
                       label=st_num),
                   label.padding = unit(0.1, "lines")) +
  coord_sf(expand = FALSE, 
           xlim = c(-71.0, -69.0), 
           ylim = c(43, 44.2), 
           crs = 4326) +
  scale_color_viridis_b(name = "Closure-level Accuracy") + 
  annotation_north_arrow(
    location = "tl", 
    which_north = "true") + 
  annotation_custom(
    grob = grob_df,
    xmin = -70.05, 
    xmax = -69.05,  
    ymin = 43.0, 
    ymax = 43.62) +
  ggplot2::theme(axis.title.x=element_blank(),
                 axis.title.y=element_blank(),
                 #axis.text = element_blank(),
                 legend.position = "bottom") 

#annotate(geom="text", x=-69.5, y=42.8, label=west$st_lab) 

p_west

# Save plot

ggsave(filename = "inst/manuscript/western_station_metrics_allyears.jpeg", plot=p_west, width=12, height=8)


## eastern Maine stations

east <- filter(st_metrics, place=="east") |>
  mutate(st_num = seq(51,74,1),
         st_lab = paste(st_num, ". ", name, sep=""))


#we're going to set the theme for our legend to have a blank white background with no row striping 
white_theme <- ttheme_default(
  core = list(
    fg_params = list(fontface = "plain",
                     fontsize = 7),
    bg_params = list(fill = "white", 
                     col = NA)))

#station_table <- as.data.frame(list(a = west$st_lab[1:17], b=west$st_lab[18:34], cc=c(west$st_lab[35:50],NA)))
station_table <- as.data.frame(list(a = east$st_lab[1:9], b = east$st_lab[10:18], cc=c(east$st_lab[19:24], "", "", "")))
#station_table <- as.data.frame(list(a = east$st_lab[1:12], cc=c(east$st_lab[13:23], NA)))

#make a grob
grob_df_east <- tableGrob(station_table, rows = NULL, cols=NULL, theme = white_theme) |>
  gtable::gtable_add_grob(
    grobs = rectGrob(gp = gpar(fill = NA, lwd = 1)),
    t = 1, 
    l = 1, 
    b = nrow(station_table), 
    r = ncol(station_table))


eastern_plot_label = tribble(
  ~text, ~lon, ~lat,
  "B",   -68.0,    44.9
)

eastern_labels = tribble(
  ~text, ~lon, ~lat,
  "Downeast",  -67.0,    44.7,
  "Penobscot Bay",  -68.8,    43.96
)

p_east <- ggplot2::ggplot(data = maine) +
  geom_sf(data=maine, 
          fill = "grey", 
          color = "black", 
          linewidth = 0.1) +
  ggplot2::theme_classic() +
  ggplot2::geom_point(data = east, 
                      aes(x = .data$lon, 
                          y = .data$lat, 
                          colour=.data$accuracy),
                      size=4) +
  geom_text(data = eastern_plot_label,
            aes(x = lon, 
                y = lat, 
                label = text),
            size = 10,
            family = "serif") +
  geom_text(data = eastern_labels,
            aes(x = lon, 
                y = lat, 
                label = text),
            size = 5,
            family = "serif") +
  scale_color_viridis_b(name = "Closure-level Accuracy") + 
  geom_label_repel(data=east, 
                   aes(x=lon, 
                       y=lat, 
                       label=st_num),
                   label.padding = unit(0.1, "lines")) +
  coord_sf(expand = FALSE, 
           xlim = c(-69.0, -66.75), 
           ylim = c(43.9, 45.1), 
           crs = 4326) +
  annotation_north_arrow(
    location = "tl", 
    which_north = "true") + 
  annotation_custom(
    grob = grob_df_east,
    xmin = -67.75, 
    xmax = -67.2,  
    ymin = 44.0, 
    ymax = 44.3) +
  ggplot2::theme(axis.title.x=element_blank(),
                 axis.title.y=element_blank(),
                 #axis.text = element_blank(),
                 legend.position = "bottom") 

p_east

ggsave(filename = "inst/manuscript/eastern_station_metrics_allyears.jpeg", plot=p_east, width=12, height=8)

