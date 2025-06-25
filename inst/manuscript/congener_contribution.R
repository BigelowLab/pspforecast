# Runs the congener contribution test for mytilus, mya and arctica for periods before, during and after peak toxicity


library(pspdata)
library(ctoxin)
library(dplyr)
library(ggplot2)


psp <- read_psp_data(fix_species = TRUE) |>
  mutate(year = format(date, format="%Y"))


# mytilus
myt <- filter(psp, species=="mytilus")

myt_test <- pre_peak_post_test(myt)

plot_pre_peak_post(myt_test)

# mya
mya <- filter(psp, species=="mya")

mya_test <- pre_peak_post_test(mya)

plot_pre_peak_post(mya_test)

# arctica
arc <- filter(psp, species=="arctica")

arc_test <- pre_peak_post_test(arc)

plot_pre_peak_post(arc_test)

# crassostrea

crs <- filter(psp, species=="crassostrea")

crs_test <- pre_peak_post_test(crs)

plot_pre_peak_post(crs_test)


t <- bind_rows(myt_test, arc_test, mya_test)

con <- get_congeners()

f_labs <- c("Mean", "Median", "Standard Deviation")
names(f_labs) <- c("cont_mean", "cont_med", "cont_sd")

spec_labs <- c("Arctica", "Mya", "Mytilus")
names(spec_labs) <- c("arctica", "mya", "mytilus")

z <- t |>
  tidyr::pivot_longer(cols = dplyr::all_of(con)) |>
  dplyr::group_by(.data$species, .data$name, .data$period) |>
  dplyr::summarise(cont_mean = mean(.data$value, na.rm=TRUE)*100) |>
  dplyr::filter(dplyr::between(.data$period, -5, 5)) |>
  tidyr::pivot_longer(cols = dplyr::starts_with("cont_"),
                      names_to = "stat", 
                      values_to = "new_value") |>
  mutate(new_value = round(new_value))


p <- ggplot2::ggplot(data = z, ggplot2::aes(x=.data$period, y=.data$name, fill=.data$new_value)) +
  ggplot2::geom_tile(color="black") +
  geom_text(aes(label = new_value)) +
  ggplot2::scale_fill_gradient(low = "white", 
                               high = "blue",
                               n.breaks=12,
                               name="Contribution") +
  ggplot2::labs(x = "Sample(s) away from peak (P) toxicity period (before (-) and after (+))",
                y = "Congener") +
  ggplot2::scale_x_continuous(breaks = seq(from=-5, to=5, by=1), 
                              label = c("-5", "-4", "-3", "-2", "-1", "P", "1", "2", "3", "4", "5")) +
  ggplot2::theme_dark() +
  ggplot2::theme(axis.text = ggplot2::element_text(size=14),
                 axis.title= ggplot2::element_text(size=14,face="bold"),
                 title =     ggplot2::element_text(size = 14, face = "bold"),
                 strip.text.x = element_text(size = 20),
                 legend.position = "none") +
  ggplot2::facet_grid(cols=ggplot2::vars(species),
                      labeller = labeller(species = spec_labs)) +
  ggplot2::scale_fill_fermenter(name="Mean \nContribution",
                                #breaks=seq(0,100,10), 
                                #breaks = c(0,0.999, seq(10,100,10)),
                                breaks = seq(9,99,10),
                                palette="Spectral")

p


ggsave(filename = "inst/manuscript/congener_contribution_2.jpeg", plot=p, width=12, height=8)
