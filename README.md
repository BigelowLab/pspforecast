pspforecast
================

Shellfish toxicity (PSP) forecast serving package

For the current 2026 Maine PSP predictions, click
[here](https://github.com/BigelowLab/pspforecast/blob/master/inst/forecastdb/dmr_webpage_table.csv)

For past season results, check out this [shiny
application](https://eco.bigelow.org/pspforecast/)

## Installation

    remotes::install_github("BigelowLab/pspforecast")

## Reading the forecast database

``` r
library(pspforecast)
fc = read_forecast()
glimpse(fc)
```

    ## Rows: 644
    ## Columns: 20
    ## $ version             <chr> "v0.4.0", "v0.4.0", "v0.4.0", "v0.4.0", "v0.4.0", …
    ## $ ensemble_n          <dbl> 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10…
    ## $ location            <chr> "PSP10.11", "PSP10.33", "PSP12.01", "PSP12.03", "P…
    ## $ date                <date> 2026-04-13, 2026-04-13, 2026-04-14, 2026-04-14, 2…
    ## $ species             <chr> "mytilus", "mytilus", "mytilus", "mytilus", "mytil…
    ## $ name                <chr> "Ogunquit River", "Spurwink River", "Basin Pt.", "…
    ## $ lat                 <dbl> 43.25030, 43.56632, 43.73848, 43.73064, 43.79553, …
    ## $ lon                 <dbl> -70.59540, -70.27305, -70.04343, -70.02556, -69.94…
    ## $ class_bins          <chr> "0,10,30,80", "0,10,30,80", "0,10,30,80", "0,10,30…
    ## $ forecast_start_date <date> 2026-04-17, 2026-04-17, 2026-04-18, 2026-04-18, 2…
    ## $ forecast_end_date   <date> 2026-04-23, 2026-04-23, 2026-04-24, 2026-04-24, 2…
    ## $ p_0                 <dbl> 99, 99, 98, 98, 94, 93, 94, 98, 81, 96, 81, 98, 98…
    ## $ p_1                 <dbl> 1, 1, 2, 2, 6, 6, 6, 2, 16, 3, 16, 2, 2, 3, 1, 1, …
    ## $ p_2                 <dbl> 0, 0, 0, 0, 0, 1, 0, 0, 3, 0, 2, 0, 0, 0, 0, 0, 0,…
    ## $ p_3                 <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ p3_sd               <dbl> 0.0012371945, 0.0023733521, 0.0024041385, 0.004171…
    ## $ p_3_min             <dbl> 0.0005414331, 0.0009854686, 0.0019742312, 0.001221…
    ## $ p_3_max             <dbl> 0.004035514, 0.007677227, 0.009584654, 0.014105438…
    ## $ predicted_class     <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ f_id                <chr> "PSP10.11_2026-04-13_mytilus", "PSP10.33_2026-04-1…

Forecast Variables:

- version - the version/configuration of the model used to make the
  prediction
- ensemble_n - number of ensemble members used to generate prediction
- location - the sampling station the forecast is for
- date - the date the forecast was made on
- name - site name
- lat - latitude
- lon - longitude
- class_bins - the bins used to classify shellfish total toxicity
  (i.e. 0: 0-10, 1: 10-30, 2: 30-80, 3: \>80)
- forecast_date - the date the forecast is valid for (i.e. one week
  ahead of when it was made)
- predicted_class - the predicted classification at the location listed
  on the forecast_date (in this case 0-3)
- p_0 - class 0 probability
- p_1 - class 1 probability
- p_2 - class 2 probability
- p_3 - class 3 probability
- p3_sd - class 3 probability standard deviation
- p_3_min - class 3 minimum probability (from ensemble run)
- p_3_max - class 3 maximum probability (from ensemble run)
- predicted_class - the predicted classification

## Results

Metrics:

- tp - The model predicted class 3 and the following week’s measurement
  was class 3
- fp - The model predicted class 3 and the following week’s measurement
  was not class 3
- tn - The model predicted class 0,1,2 and the following week’s
  measurement was in class 0,1,2
- fn - The model predicted class 0,1,2 and the following week’s
  measurement was class 3
- accuracy - Measure of how many correct classifications were predicted
- cl_accuracy - Considering predictions are those that correctly
  predicted toxicity above or below the closure limit or not
- precision - TP/(TP+FP)
- sensitivity - TP/(TP+FN)
- specificity - TN/(TN+FP)
- f_1 - (2TP)/(2TP-FP+FN)

Predictions evaluated:

    ## [1] 2634

Metrics (overall):

    ## # A tibble: 1 × 11
    ##      tp    fp    tn    fn cl_accuracy accuracy brier   f_1 precision sensitivity
    ##   <int> <int> <int> <int>       <dbl>    <dbl> <dbl> <dbl>     <dbl>       <dbl>
    ## 1    69    65  2449    51       0.956    0.806 0.028 0.543     0.515       0.575
    ## # ℹ 1 more variable: specificity <dbl>

Individual seasons:

    ## # A tibble: 5 × 12
    ##    year    tp    fp    tn    fn cl_accuracy accuracy brier     f_1 precision
    ##   <int> <int> <int> <int> <int>       <dbl>    <dbl> <dbl>   <dbl>     <dbl>
    ## 1  2021     2     3   463     0       0.994    0.938 0.005   0.571     0.4  
    ## 2  2022    16    20   603    12       0.951    0.799 0.03    0.5       0.444
    ## 3  2023     0     0   405     0       1        0.99  0     NaN       NaN    
    ## 4  2024     2     4   397     7       0.973    0.717 0.017   0.267     0.333
    ## 5  2025    49    38   581    32       0.9      0.671 0.066   0.583     0.563
    ## # ℹ 2 more variables: sensitivity <dbl>, specificity <dbl>

## 2026 (current season) Results

![](README_files/figure-gfm/cm26-1.png)<!-- -->

![](README_files/figure-gfm/scatter26-1.png)<!-- -->

### Predictions evaluated

    ## [1] 565

### Metrics

    ## # A tibble: 1 × 11
    ##      tp    fp    tn    fn cl_accuracy accuracy brier   f_1 precision sensitivity
    ##   <int> <int> <int> <int>       <dbl>    <dbl> <dbl> <dbl>     <dbl>       <dbl>
    ## 1    13    10   531    11       0.963    0.612 0.025 0.553     0.565       0.542
    ## # ℹ 1 more variable: specificity <dbl>

### Last Updated

    ## [1] "2026-08-12"

## Requirements

- [R v4+](https://www.r-project.org/)

- [rlang](https://CRAN.R-project.org/package=rlang)

- [dplyr](https://CRAN.R-project.org/package=dplyr)

- [readr](https://CRAN.R-project.org/package=readr)

- [tidyr](https://CRAN.R-project.org/package=tidyr)

- [httr](https://CRAN.R-project.org/package=httr)
