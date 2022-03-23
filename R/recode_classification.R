#' Set classification values 
#' 
#' @param v vector of numbers (x$total_toxicity)
#' @param lut ordered vector of toxicity levels (tox_levels)
#' @param na_value value to replace missing values in v
#' @return ix vector closure codes
#' 
#' @export
recode_classification <- function(v, 
                                  lut = c(0,10,30,80), 
                                  na_value = 0){
  na <- is.na(v)
  v[na] <- na_value
  
  ix <- findInterval(v, lut) -1
  
  return(ix)
} 
