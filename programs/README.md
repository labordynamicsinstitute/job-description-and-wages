---
title: "Programs"
author:
  '1':
    name: Lars Vilhuber
date: "2019-09-17"
output:
  html_document:
    keep_md: yes
    number_sections: yes
  pdf_document: default
editor_options:
  chunk_output_type: console
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
## > source(file.path(programs, "global-libraries.R"), 
## +     echo = FALSE)
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

```
## 
## > source(file.path(programs, "libraries.R"), echo = FALSE)
```

```
## Loading required package: tidyr
```

```
## Loading required package: readxl
```

```
## Loading required package: fuzzyjoin
```

```
## Loading required package: knitr
```

```
## 
## > onet.src.base <- "https://www.onetcenter.org/dl_files/database/"
## 
## > onet.src.version <- "23_2"
## 
## > onet.src.file <- paste("db", onet.src.version, "excel.zip", 
## +     sep = "_")
## 
## > oes.src.base <- "https://www.bls.gov/oes/special.requests/"
## 
## > oes.src.version <- "2018"
## 
## > oes.src.file <- paste("oesm", oes.src.version, "nat.zip", 
## +     sep = "")
## 
## > soc_definitions_loc <- "https://www.bls.gov/soc/soc_structure_2010.xls"
```

Note that the path `interwrk` is transitory, and is only kept during processing. It will be empty in the replication archive.




## Download and unpack the O&ast;NET data

 - Input data: O&ast;NET 
 - Output data: path `acquired'
 - this part is only run on-demand (manually)
 

```r
source(file.path(programs,"01_download_onet.R"),echo=TRUE)
```
## Download SOC data
We can download definitions from https://www.bls.gov/soc/soc_structure_2010.xls. In particular, we might be interested in the major groupings. (not done yet)


## Mapping job titles to SOC

We merge the alternate titles (as defined by O&ast;Net) and the BLS data (merged in via occupational code).
We keep all observations in our normative list of NLM-state related occupations.


```
## 
## > source(file.path(rprojroot::find_rstudio_root_file(), 
## +     "pathconfig.R"), echo = FALSE)
## 
## > source(file.path(programs, "config.R"), echo = FALSE)
## 
## > Alternate_Titles <- read_excel(file.path(acquired, 
## +     "Alternate Titles.xlsx"))
## 
## > Occupation_Data <- read_excel(file.path(acquired, 
## +     "Occupation Data.xlsx")) %>% select(-Title)
## 
## > BLS.data <- read_excel(file.path(acquired, paste0("national_M", 
## +     oes.src.version, "_dl.xlsx")))
## 
## > job_titles <- read_excel(file.path(generated, "job_titles.xlsx"))
## 
## > names(job_titles) <- c("Job Title")
## 
## > job_titles[nrow(job_titles) + 1, ] <- "Librarian"
## 
## > soc_job_titles <- Alternate_Titles %>% select("O*NET-SOC Code", 
## +     Title) %>% distinct()
## 
## > soc_job_alttitles <- Alternate_Titles %>% select("O*NET-SOC Code", 
## +     "Alternate Title") %>% distinct()
## 
## > primary <- stringdist_inner_join(y = soc_job_titles, 
## +     x = job_titles, by = c(`Job Title` = "Title"), method = "jw", 
## +     distance_col = "jw_ ..." ... [TRUNCATED] 
## 
## > secondary <- stringdist_inner_join(y = soc_job_alttitles, 
## +     x = job_titles, by = c(`Job Title` = "Alternate Title"), 
## +     method = "jw", dist .... [TRUNCATED] 
## 
## > nlm.titles <- bind_rows(primary, secondary) %>% left_join(Occupation_Data, 
## +     by = "O*NET-SOC Code") %>% separate("O*NET-SOC Code", sep = 7, 
## +  .... [TRUNCATED] 
## 
## > saveRDS(nlm.titles, file = file.path(outputs, "nlm.titles.RDS"))
## 
## > write.csv(nlm.titles, file = file.path(outputs, "nlm.titles.csv"))
```

## Results

The following table lists the annual salaries by job title (median, and the 25% and 75% percentile). Blank salaries indicate that no occupation code could be found on O&ast;Net based on the normative description. We only print one line per normative job title - these might map to the same occupation code (SOC).


```r
nlm.extract <- nlm.titles %>% 
  distinct(`Job Title`,SOC,.keep_all = TRUE) %>% 
  select("Job Title","Title","SOC", "Alternate Title","A_PCT25","A_MEDIAN","A_PCT75")
kable(nlm.extract)
```



Job Title            Title                                                                  SOC       Alternate Title     A_PCT25   A_MEDIAN   A_PCT75 
-------------------  ---------------------------------------------------------------------  --------  ------------------  --------  ---------  --------
Archivists           Archivists                                                             25-4011   NA                  38090     52240      71250   
Curators             Curators                                                               25-4012   NA                  39580     53780      72830   
Curators             Archeologists                                                          19-3091   Curator             48020     62410      80230   
Curators             Archivists                                                             25-4011   Curator             38090     52240      71250   
Data Librarians      NA                                                                     NA        NA                  NA        NA         NA      
Scientists           Biofuels/Biodiesel Technology and Product Development Managers         11-9041   Scientist           112400    140760     173180  
Scientists           Mathematicians                                                         15-2021   Scientist           73490     101900     126070  
Scientists           Chemical Engineers                                                     17-2041   Scientist           81900     104910     133320  
Scientists           Nuclear Engineers                                                      17-2161   Scientist           85840     107600     129000  
Scientists           Nanosystems Engineers                                                  17-2199   Scientist           69890     96980      126200  
Scientists           Manufacturing Engineering Technologists                                17-3029   Scientist           47500     63200      80670   
Scientists           Biologists                                                             19-1020   Scientist           56730     77550      103540  
Scientists           Biochemists and Biophysicists                                          19-1021   Scientist           64230     93280      129950  
Scientists           Bioinformatics Scientists                                              19-1029   Scientist           60250     79590      98040   
Scientists           Medical Scientists, Except Epidemiologists                             19-1042   Scientist           59580     84810      118040  
Scientists           Astronomers                                                            19-2011   Scientist           74300     105680     147710  
Scientists           Physicists                                                             19-2012   Scientist           85090     120950     158350  
Scientists           Chemists                                                               19-2031   Scientist           56290     76890      103820  
Scientists           Climate Change Analysts                                                19-2041   Scientist           53580     71130      94590   
Scientists           Hydrologists                                                           19-2043   Scientist           61280     79370      100090  
Scientists           Remote Sensing Scientists and Technologists                            19-2099   Scientist           75830     107230     136930  
Scientists           Anthropologists                                                        19-3091   Scientist           48020     62410      80230   
Scientists           Geographers                                                            19-3092   Scientist           63270     80300      96980   
Policy Specialists   NA                                                                     NA        NA                  NA        NA         NA      
Project Managers     Construction Managers                                                  11-9021   Project Manager     70670     93370      123720  
Project Managers     Architectural and Engineering Managers                                 11-9041   Project Manager     112400    140760     173180  
Project Managers     Managers, All Other                                                    11-9199   Project Manager     75460     107480     143230  
Project Managers     Information Technology Project Managers                                15-1199   Project Manager     66410     90270      117070  
Project Managers     Environmental Engineers                                                17-2081   Project Manager     66590     87620      112230  
Project Managers     Wind Energy Engineers                                                  17-2199   Project Manager     69890     96980      126200  
Project Managers     Architectural Drafters                                                 17-3011   Project Manager     43660     54920      67120   
Project Managers     Environmental Restoration Planners                                     19-2041   Project Manager     53580     71130      94590   
Project Managers     Social Science Research Assistants                                     19-4061   Project Manager     35450     46640      60830   
Project Managers     Remote Sensing Technicians                                             19-4099   Project Manager     37940     49670      63340   
Project Managers     Technical Directors/Managers                                           27-2012   Project Manager     48520     71680      110350  
Project Managers     Intelligence Analysts                                                  33-3021   Project Manager     57560     81920      107000  
Project Managers     First-Line Supervisors of Construction Trades and Extraction Workers   47-1011   Project Manager     52380     65230      84240   
Researchers          Industrial Ecologists                                                  19-2041   Researcher          53580     71130      94590   
Researchers          Anthropologists                                                        19-3091   Researcher          48020     62410      80230   
Researchers          Historians                                                             19-3093   Researcher          40670     61140      85700   
Senior Staffs        NA                                                                     NA        NA                  NA        NA         NA      
Software Engineers   Computer and Information Research Scientists                           15-1111   Software Engineer   91650     118370     149470  
Software Engineers   Software Developers, Applications                                      15-1132   Software Engineer   79340     103620     130460  
Software Engineers   Software Developers, Systems Software                                  15-1133   Software Engineer   85610     110000     139550  
Librarian            Librarians                                                             25-4021   NA                  46130     59050      74740   
Librarian            Library Science Teachers, Postsecondary                                25-1082   Librarian           56550     71560      90550   
Librarian            Archivists                                                             25-4011   Librarian           38090     52240      71250   
Librarian            File Clerks                                                            43-4071   Librarian           25420     31700      39670   

```r
saveRDS(nlm.extract,file = file.path(outputs,"nlm.extract.RDS"))
write.csv(nlm.extract,file=file.path(outputs,"nlm.extract.csv"))
```

