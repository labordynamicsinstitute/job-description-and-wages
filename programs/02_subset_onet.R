# Match NLM job titles to O*Net data
# 

source(file.path(rprojroot::find_rstudio_root_file(),"pathconfig.R"),echo=FALSE)
source(file.path(programs,"config.R"), echo=FALSE)

# load onet data
Alternate_Titles <- read_excel(file.path(acquired,"Alternate Titles.xlsx"))
# merge in verbose job titles
Occupation_Data <- read_excel(file.path(acquired,"Occupation Data.xlsx")) %>% select(-Title)

# Possible merge in the Transition matrix, as a potential for alternate hires

# Read BLS earnings data
BLS.data <- read_excel(file.path(acquired,paste0("national_M",oes.src.version,"_dl.xlsx")))

# load the jobtitle data (our own list)
job_titles <- read_excel(file.path(generated,"job_titles.xlsx"))
names(job_titles) <- c("Job Title")
# we might want to add a few more to improve match probabilities
job_titles[nrow(job_titles)+1,] <- "Librarian"

# get both the official 
soc_job_titles <- Alternate_Titles %>% select("O*NET-SOC Code",Title) %>%
  distinct() 
soc_job_alttitles <- Alternate_Titles %>% select("O*NET-SOC Code","Alternate Title") %>%
  distinct() 

primary <- stringdist_inner_join(y=soc_job_titles,
                                 x=job_titles,
                                 by = c("Job Title" = "Title"),
                                 method="jw",
                                 distance_col="jw_distance",
                                 max_dist=0.05) %>% 
            mutate(Alternate = "0")
secondary <- stringdist_inner_join(y=soc_job_alttitles,
                                   x=job_titles,
                                   by = c("Job Title" = "Alternate Title"),
                                   method="jw",
                                   distance_col="jw_distance",
                                   max_dist=0.05) %>%
              left_join(soc_job_titles,by="O*NET-SOC Code")%>% 
              mutate(Alternate = "1") 
  

# Still needs frequencies of relation alternate to primary
nlm.titles <- bind_rows(primary,secondary) %>% 
  left_join(Occupation_Data,by="O*NET-SOC Code") %>%
  separate("O*NET-SOC Code",sep = 7,remove=FALSE,into = c("SOC","suffix")) %>%
  select(-suffix) %>%
  left_join(BLS.data,by=c("SOC" = "OCC_CODE")) %>%
  right_join(job_titles,by="Job Title")

saveRDS(nlm.titles,file = file.path(outputs,"nlm.titles.RDS"))
write.csv(nlm.titles,file=file.path(outputs,"nlm.titles.csv"))