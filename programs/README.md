---
title: "Programs"
author: 
  1:
    name: "Lars Vilhuber"
date: "2019-05-07"
output: 
  html_document: 
    keep_md: yes
    number_sections: yes
---


# Program directory
This directory contains all programs necessary to run the cleaning, analysis, etc. They can be run separately, or in a single run. 

## Setup
Most parameters are set in the `config.R`:

```r
source(file.path(rprojroot::find_rstudio_root_file(),"pathconfig.R"),echo=TRUE)
```

```
## 
## > basepath <- rprojroot::find_rstudio_root_file()
## 
## > acquired <- file.path(basepath, "data", "acquired")
## 
## > interwrk <- file.path(basepath, "data", "interwrk")
## 
## > generated <- file.path(basepath, "data", "generated")
## 
## > outputs <- file.path(basepath, "analysis")
## 
## > programs <- file.path(basepath, "programs")
## 
## > for (dir in list(acquired, interwrk, generated, outputs)) {
## +     if (file.exists(dir)) {
## +     }
## +     else {
## +         dir.create(file.path(dir))
##  .... [TRUNCATED]
```

```r
source(file.path(programs,"config.R"), echo=TRUE)
```

```
## 
## > onet.src.base <- "https://www.onetcenter.org/dl_files/database/"
## 
## > onet.src.version <- "23_2"
## 
## > onet.src.file <- paste("db", onet.src.version, "excel.zip", 
## +     sep = "_")
```

Note that the path `interwrk` is transitory, and is only kept during processing. It will be empty in the replication archive.

Any libraries needed are called and if necessary installed through `libraries.R`:


```r
source(file.path(programs,"global-libraries.R"),echo=TRUE)
```

```
## 
## > pkgTest <- function(x) {
## +     if (!require(x, character.only = TRUE)) {
## +         install.packages(x, dep = TRUE)
## +         if (!require(x, charact .... [TRUNCATED] 
## 
## > global.libraries <- c("dplyr", "devtools", "rprojroot", 
## +     "tictoc")
## 
## > results <- sapply(as.list(global.libraries), pkgTest)
```

```
## Loading required package: dplyr
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```
## Loading required package: devtools
```

```
## Loading required package: rprojroot
```

```
## Loading required package: tictoc
```

```r
source(file.path(programs,"libraries.R"), echo=TRUE)
```

```
## 
## > libraries <- c("dplyr", "devtools", "tidyr")
## 
## > results <- sapply(as.list(libraries), pkgTest)
```

```
## Loading required package: tidyr
```

```
## 
## > cbind(libraries, results)
##      libraries  results
## [1,] "dplyr"    "OK"   
## [2,] "devtools" "OK"   
## [3,] "tidyr"    "OK"
```



## Download and unpack the O&ast;NET data

 - Input data: O&ast;NET 
 - Output data: path `acquired'
 

```r
source(file.path(programs,"01_download_onet.R"),echo=TRUE)
```
