#' ---
#' local libraries


#' Define the list of libraries
libraries <- c("dplyr","knitr","scales","R.utils")

results <- sapply(as.list(libraries), pkgTest)
cbind(libraries,results)
