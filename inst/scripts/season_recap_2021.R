
library(pspforecast)
library(dplyr)

predictions <- pspforecast::read_forecast()
summary(predictions)

source("~/Documents/Bigelow/CODE/psp_dev/confusion matrix/forecast_performance.R")

pred_w_results <- add_forecast_results(predictions)
View(pred_w_results)
summary(pred_w_results)



### Versions

# v0.1.0 - 2 weeks of toxin measurements, 6-10 day step, all 12 toxins
# v0.1.1 - 2 weeks of toxin measurements, 6-10 day step, all 12 toxins + sst_cum, doubled size of layers (16 -> 32 nodes)
# v0.1.3 - 2 weeks of toxin measurements, 4-10 day step, all 12 toxins + sst_cum
# v0.1.4 - 2 weeks of toxin measurements, 4-10 day step, all 12 toxins + sst_cum, increased first dropout (0.3 -> 0.4), increased first layer size (32 -> 64 nodes), weighted classes





### Closures missed and predicted

closures <- pred_w_results %>% 
  filter(actual_class == 3)

closure_predictions <- pred_w_results %>% 
  filter(predicted_class == 3)

