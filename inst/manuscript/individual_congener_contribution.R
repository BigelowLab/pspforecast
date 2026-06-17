# Runs the congener contribution test for mytilus, mya and arctica for periods before, during and after peak toxicity

library(pspforecast)
library(pspdata)
library(ctoxin)
library(dplyr)
library(ggplot2)
library(tidyr)


psp <- read_psp_data(fix_species = TRUE) |>
  mutate(year = format(date, format="%Y"),
         f_id = paste(location_id, date, sep="_")) |>
  filter(date < as.Date("2026-01-01"),
         species == "mytilus")

predictions = read_all_results() |>
  mutate(f_id = paste(location, date, sep="_"))


# mytilus

myt_test <- pre_peak_post_test(psp)

plot_pre_peak_post(myt_test)

con <- get_congeners()

a = select(myt_test, f_id, location_id, date, stx, gtx3, gtx2, gtx1, period)

b = select(predictions, f_id, location, date, p_3, toxicity) |>
  rename(location_id = location)

z = left_join(a,b) |>
  filter(!is.na(p_3)) |>
  pivot_longer(cols = c(4:7, 9:10)) |>
  mutate(year = format(date, format = "%Y"), .after = date)


z

# PSP10.11, 2022
# PSP12.13, 2022

p = filter(z, 
           location_id == "PSP12.13", 
           year == 2022,
           period %in% seq(-5, 5)) |>
  mutate(name = factor(name, 
                       levels = c("gtx1", "gtx2", "gtx3", "stx", "p_3", "toxicity"),
                       labels = c("GTX1", "GTX2", "GTX3", "STX", "Predicted probability", "Measured toxicity"))) |>
  ggplot(aes(x=period, y=value)) +
  geom_line() + 
  facet_grid(rows = vars(name), scales = "free") +
  theme_linedraw()



ggsave(filename = "inst/manuscript/individual_congener_contribution.jpeg", plot=p, width=12, height=8)
