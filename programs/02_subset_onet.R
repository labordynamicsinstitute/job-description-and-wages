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
BLS.data <- read_excel(file.path(acquired,paste0("national_M20",oes.src.version,"_dl.xlsx")))

# load the jobtitle data (our own list)
job_titles <- read_excel(file.path(generated,"job_titles.xlsx"),sheet = "Main")
names(job_titles) <- c("Job Title")

# we might want to add a few more to improve match probabilities
job_titles.plus <- read_excel(file.path(generated,"job_titles.xlsx"),
                              sheet="Inclusions",col_names = TRUE) %>%
  rename("Job Title" = "Title") %>%  
  mutate(tmp = "00") %>% 
  unite("O*NET-SOC Code",  "SOC",tmp,sep = ".",remove = FALSE) %>% 
  select(-tmp)

job_titles.minus <- read_excel(file.path(generated,"job_titles.xlsx"),
                               sheet="Exclusions",col_names = TRUE) %>%
  rename("Job Title" = "Title") 

# get both the official 
soc_job_titles <- Alternate_Titles %>% select("O*NET-SOC Code",Title) %>%
  distinct() 
soc_job_alttitles <- Alternate_Titles %>% select("O*NET-SOC Code","Alternate Title") %>%
  distinct() 
soc_job_alttitles <- bind_rows(soc_job_alttitles,job_titles.plus %>%
                                 select("Alternate Title","O*NET-SOC Code")
                              )

primary <- stringdist_inner_join(y=soc_job_titles,
                                 x=job_titles,
                                 by = c("Job Title" = "Title"),
                                 method="jw",
                                 distance_col="jw_distance",
                                 max_dist=0.05) %>% 
            mutate(Alternate = "0")
secondary.raw <- stringdist_inner_join(y=soc_job_alttitles,
                                   x=job_titles,
                                   by = c("Job Title" = "Alternate Title"),
                                   method="jw",
                                   distance_col="jw_distance",
                                   max_dist=0.05) %>%
              left_join(soc_job_titles,by="O*NET-SOC Code")%>% 
              mutate(Alternate = "1") 

# get back the augmented job titles
secondary <- secondary.raw %>%  left_join(job_titles.plus %>% 
  select(-"O*NET-SOC Code"),by=c("Alternate Title")) %>% 
  mutate(`Job Title` = if_else(is.na(SOC),`Job Title.x`,`Job Title.y`)) %>% 
  select(-`Job Title.x`,-`Job Title.y`,-SOC) 


# Still needs frequencies of relation alternate to primary
nlm.titles.raw <- bind_rows(primary,secondary) %>% 
  left_join(Occupation_Data,by="O*NET-SOC Code") %>%
  separate("O*NET-SOC Code",sep = 7,remove=FALSE,into = c("SOC","suffix")) %>%
  select(-suffix) %>%
  left_join(BLS.data,by=c("SOC" = "OCC_CODE")) %>%
  right_join(job_titles,by="Job Title")

# Filter out the ones we know to be wrong
nlm.titles <- anti_join(nlm.titles.raw,job_titles.minus %>% select(SOC))


saveRDS(nlm.titles,file = file.path(outputs,"nlm.titles.RDS"))
write.csv(nlm.titles,file=file.path(outputs,"nlm.titles.csv"))