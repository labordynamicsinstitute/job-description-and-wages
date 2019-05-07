#' ---
#' local libraries


#' Define the list of libraries
libraries <- c("dplyr","devtools","tidyr","readxl","fuzzyjoin")

results <- sapply(as.list(libraries), pkgTest)
cbind(libraries,results)
