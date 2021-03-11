# pspforecast

Shellfish toxicity forecast serving package


## Requirements

  + [R v4+](https://www.r-project.org/)
  
  + [rlang](https://CRAN.R-project.org/package=rlang)
  
  + [dplyr](https://CRAN.R-project.org/package=dplyr)
  
  + [readr](https://CRAN.R-project.org/package=readr)

## Installation

```
remotes::install_github("BigelowLab/pspforecast")
```

## Reading the forecast database 
#### (currently a dummy database for the 2020 season is loaded)

### Variables:
 + version - the version/configuration of the model used to make the prediction
 
 + location - the sampling station the forecast is for
 
 + date - the date the forecast was made on
 
 + name - site name
 
 + lat - latitude
 
 + lon - longitude
 
 + class_bins - the bins used to classify shellfish total toxicity (i.e. 0: 0-10, 1: 10-30, 2: 30-80, 3: >80)
 
 + forecast_date - the date the forecast is valid for (i.e. one week ahead of when it was made)
 
 + predicted_class - the predicted classification at the location listed on the forecast_date (in this case 0-3)


```
x <- pspforecast::read_forecast()

## A tibble: 407 x 9
#   version location  date       name                   lat   lon class_bins forecast_date predicted_class
#   <chr>   <chr>     <date>     <chr>                <dbl> <dbl> <chr>      <date>                  <int>
# 1 v0.0002 PSP11.110 2020-04-20 CAS BA2 Bangs island  43.7 -70.1 0,10,30,80 2020-04-27                  0
# 2 v0.0002 PSP11.115 2020-04-20 CAS BASK              43.7 -70.2 0,10,30,80 2020-04-27                  0
# 3 v0.0002 PSP13.03  2020-04-21 Pinkham Pt.           43.8 -69.9 0,10,30,80 2020-04-28                  0
# 4 v0.0002 PSP12.11  2020-04-21 Ewin Narrows          43.8 -70.0 0,10,30,80 2020-04-28                  0
# 5 v0.0002 PSP12.01  2020-04-21 Basin Pt.             43.7 -70.0 0,10,30,80 2020-04-28                  0
# 6 v0.0002 PSP12.13  2020-04-21 Lumbos Hole           43.8 -69.9 0,10,30,80 2020-04-28                  0
# 7 v0.0002 PSP16.41  2020-04-21 Port Clyde            43.9 -69.3 0,10,30,80 2020-04-28                  0
# 8 v0.0002 PSP12.28  2020-04-21 Bear Island           43.8 -69.9 0,10,30,80 2020-04-28                  0
# 9 v0.0002 PSP12.15  2020-04-21 Gurnet                43.9 -69.9 0,10,30,80 2020-04-28                  0
#10 v0.0002 PSP10.11  2020-04-21 Ogunquit River        43.3 -70.6 0,10,30,80 2020-04-28                  0
## … with 397 more rows
```

## Subset the table by sampling station (location)

```
x %>% dplyr::filter(location == "PSP12.13")

## A tibble: 14 x 9
#   version location date       name          lat   lon class_bins forecast_date predicted_class
#   <chr>   <chr>    <date>     <chr>       <dbl> <dbl> <chr>      <date>                  <int>
# 1 v0.0002 PSP12.13 2020-04-21 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-04-28                  0
# 2 v0.0002 PSP12.13 2020-04-27 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-05-04                  1
# 3 v0.0002 PSP12.13 2020-05-04 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-05-11                  1
# 4 v0.0002 PSP12.13 2020-05-11 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-05-18                  1
# 5 v0.0002 PSP12.13 2020-05-18 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-05-25                  0
# 6 v0.0002 PSP12.13 2020-05-26 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-06-02                  0
# 7 v0.0002 PSP12.13 2020-06-01 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-06-08                  0
# 8 v0.0002 PSP12.13 2020-06-08 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-06-15                  0
# 9 v0.0002 PSP12.13 2020-06-15 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-06-22                  0
#10 v0.0002 PSP12.13 2020-06-22 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-06-29                  0
#11 v0.0002 PSP12.13 2020-06-29 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-07-06                  0
#12 v0.0002 PSP12.13 2020-07-06 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-07-13                  0
#13 v0.0002 PSP12.13 2020-07-13 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-07-20                  0
#14 v0.0002 PSP12.13 2020-07-21 Lumbos Hole  43.8 -69.9 0,10,30,80 2020-07-28                  0
```

## Subset the table by a single date

```
x %>% dplyr::filter(date == as.Date("2020-06-01"))

## A tibble: 24 x 9
#   version location  date       name                lat   lon class_bins forecast_date predicted_class
#   <chr>   <chr>     <date>     <chr>             <dbl> <dbl> <chr>      <date>                  <int>
# 1 v0.0002 PSP14.08  2020-06-01 Five Islands       43.8 -69.7 0,10,30,80 2020-06-08                  0
# 2 v0.0002 PSP10.33  2020-06-01 Spurwink River     43.6 -70.3 0,10,30,80 2020-06-08                  0
# 3 v0.0002 PSP12.03  2020-06-01 Potts Pt.          43.7 -70.0 0,10,30,80 2020-06-08                  0
# 4 v0.0002 PSP12.11  2020-06-01 Ewin Narrows       43.8 -70.0 0,10,30,80 2020-06-08                  0
# 5 v0.0002 PSP12.06  2020-06-01 Wills Gut          43.7 -70.0 0,10,30,80 2020-06-08                  0
# 6 v0.0002 PSP12.243 2020-06-01 Dingley Starboard  43.8 -69.9 0,10,30,80 2020-06-08                  0
# 7 v0.0002 PSP14.02  2020-06-01 Indian Pt.         43.8 -69.8 0,10,30,80 2020-06-08                  0
# 8 v0.0002 PSP12.21  2020-06-01 Fort St. George    43.8 -69.8 0,10,30,80 2020-06-08                  0
# 9 v0.0002 PSP12.28  2020-06-01 Bear Island        43.8 -69.9 0,10,30,80 2020-06-08                  0
#10 v0.0002 PSP12.15  2020-06-01 Gurnet             43.9 -69.9 0,10,30,80 2020-06-08                  0
## … with 14 more rows
```

## Subset by multiple dates

```
dates <- c(as.Date("2020-06-01"), as.Date("2020-06-02"), as.Date("2020-06-03"))
x %>% dplyr::filter(date %in% dates)

## A tibble: 41 x 9
#   version location  date       name                lat   lon class_bins forecast_date predicted_class
#   <chr>   <chr>     <date>     <chr>             <dbl> <dbl> <chr>      <date>                  <int>
# 1 v0.0002 PSP14.08  2020-06-01 Five Islands       43.8 -69.7 0,10,30,80 2020-06-08                  0
# 2 v0.0002 PSP10.33  2020-06-01 Spurwink River     43.6 -70.3 0,10,30,80 2020-06-08                  0
# 3 v0.0002 PSP12.03  2020-06-01 Potts Pt.          43.7 -70.0 0,10,30,80 2020-06-08                  0
# 4 v0.0002 PSP12.11  2020-06-01 Ewin Narrows       43.8 -70.0 0,10,30,80 2020-06-08                  0
# 5 v0.0002 PSP12.06  2020-06-01 Wills Gut          43.7 -70.0 0,10,30,80 2020-06-08                  0
# 6 v0.0002 PSP12.243 2020-06-01 Dingley Starboard  43.8 -69.9 0,10,30,80 2020-06-08                  0
# 7 v0.0002 PSP14.02  2020-06-01 Indian Pt.         43.8 -69.8 0,10,30,80 2020-06-08                  0
# 8 v0.0002 PSP12.21  2020-06-01 Fort St. George    43.8 -69.8 0,10,30,80 2020-06-08                  0
# 9 v0.0002 PSP12.28  2020-06-01 Bear Island        43.8 -69.9 0,10,30,80 2020-06-08                  0
#10 v0.0002 PSP12.15  2020-06-01 Gurnet             43.9 -69.9 0,10,30,80 2020-06-08                  0
## … with 31 more rows
```