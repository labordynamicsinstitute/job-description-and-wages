#' ---
#' local libraries


#' Define the list of libraries
libraries <- c("dplyr","devtools","tidyr","readxl","fuzzyjoin","knitr")

results <- sapply(as.list(libraries), pkgTest)
cbind(libraries,results)
