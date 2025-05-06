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


t <- bind_rows(myt_test, arc_test, mya_test)

z <- t |>
  tidyr::pivot_longer(cols = dplyr::all_of(con)) |>
  dplyr::group_by(.data$species, .data$name, .data$period) |>
  dplyr::summarise(cont_mean = mean(.data$value, na.rm=TRUE)) |>
  dplyr::filter(dplyr::between(.data$period, -5, 5)) |>
  tidyr::pivot_longer(cols = dplyr::starts_with("cont_"),
                      names_to = "stat", 
                      values_to = "new_value")

f_labs <- c("Mean", "Median", "Standard Deviation")
names(f_labs) <- c("cont_mean", "cont_med", "cont_sd")


p <- ggplot2::ggplot(data = z, ggplot2::aes(x=.data$period, y=.data$name, fill=.data$new_value)) +
  ggplot2::geom_tile(color="black") +
  ggplot2::scale_fill_gradient(low = "white", 
                               high = "blue",
                               n.breaks=12,
                               name="Contribution") +
  ggplot2::labs(x = "Sample away from peak (P) toxicity period (before (-) and after (+))",
                y = "Congener") +
  ggplot2::scale_x_continuous(breaks = seq(from=-5, to=5, by=1), 
                              label = c("-5", "-4", "-3", "-2", "-1", "P", "1", "2", "3", "4", "5")) +
  ggplot2::theme_dark() +
  ggplot2::theme(axis.text = ggplot2::element_text(size=8)) +
  ggplot2::facet_wrap(ggplot2::vars(species)) +
  ggplot2::scale_fill_fermenter(name="Mean \nContribution",
                                breaks=c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1), 
                                palette="Spectral")

p


ggsave(filename = "inst/manuscript/congener_contribution.jpeg", plot=p, width=9, height=6)
