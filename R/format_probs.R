#' Takes a column of probabilities and formats them for stakeholder delivery (rounds to integer and adds percent symbol)
#' 
#' @param probs vector of probabilities
#' @return formatted vector of probabilities
#' 
#' @export
format_probs <- function(probs) {
  
  rounded <- sapply(probs, round)
  
  to_char <- sapply(rounded, as.character)
  
  no_zero <- sapply(to_char, function(x) if (x == "0") {x = "<1"} else {x})
  
  no_hundred <- sapply(no_zero, function(x) if (x == "100") {x = ">99"} else {x})
  
  r <- sapply(no_zero, function(x) {return(paste(x, "%", sep=""))})
  
  return(r)
}
