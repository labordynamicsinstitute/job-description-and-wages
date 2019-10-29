# Match NLM job titles to O*Net data
# 

source(file.path(rprojroot::find_rstudio_root_file(),"pathconfig.R"),echo=FALSE)
source(file.path(programs,"config.R"), echo=FALSE)

# ========= load onet data ============
Alternate_Titles <- read_excel(file.path(acquired,"Alternate Titles.xlsx"))
# merge in verbose job titles
Occupation_Data <- read_excel(file.path(acquired,"Occupation Data.xlsx")) %>% select(-Title)

# Possible merge in the Transition matrix, as a potential for alternate hires

# ============ Read BLS earnings data ===============
BLS.data <- read_excel(file.path(acquired,paste0("national_M20",oes.src.version,"_dl.xlsx")))

# ============ load the jobtitle data (our own list) ==================
job_titles.main <- read_excel(file.path(generated,"job_titles.xlsx"),sheet = "Main",col_names = TRUE)

# we might want to add a few more to improve match probabilities. These augment the "official list"
job_titles.plus <- read_excel(file.path(generated,"job_titles.xlsx"),
                              sheet="Inclusions",col_names = TRUE) %>%
  rename("Job Title" = "Title") %>%  
  mutate(tmp = "00") %>% 
  unite("O*NET-SOC Code",  "SOC",tmp,sep = ".",remove = FALSE) %>% 
  select(-tmp)

job_titles <- bind_rows(job_titles.main,
                        job_titles.plus %>% select("Alternate Title") 
                           %>% rename("Job Title" = "Alternate Title")) %>%
              distinct()

job_titles.minus <- read_excel(file.path(generated,"job_titles.xlsx"),
                               sheet="Exclusions",col_names = TRUE) %>%
  rename("Job Title" = "Title") 

# =========== Processing ======================
# get both the official and the alternate
soc_job_titles <- Alternate_Titles %>% select("O*NET-SOC Code",Title) %>%
  distinct() 
soc_job_alttitles <- Alternate_Titles %>% select("O*NET-SOC Code","Alternate Title") %>%
  distinct() 

primary <- stringdist_inner_join(y=soc_job_titles,
                                 x=job_titles %>% select("Job Title"),
                                 by = c("Job Title" = "Title"),
                                 method="jw",
                                 distance_col="jw_distance",
                                 max_dist=0.05) %>% 
            mutate(Alternate = "0")
secondary.raw <- stringdist_inner_join(y=soc_job_alttitles,
                                   x=job_titles %>% select("Job Title"),
                                   by = c("Job Title" = "Alternate Title"),
                                   method="jw",
                                   distance_col="jw_distance",
                                   max_dist=0.05) %>%
              left_join(soc_job_titles,by="O*NET-SOC Code")%>% 
              mutate(Alternate = "1") 

# get back the augmented job titles
secondary <- secondary.raw 


# Still needs frequencies of relation alternate to primary
nlm.titles.raw <- bind_rows(primary,secondary) %>% 
  left_join(Occupation_Data,by="O*NET-SOC Code") %>%
  separate("O*NET-SOC Code",sep = 7,remove=FALSE,into = c("SOC","suffix")) %>%
  select(-suffix) %>%
  left_join(BLS.data,by=c("SOC" = "OCC_CODE"))

# We have a few in there that are our alternates
nlm.titles.raw2 <-  nlm.titles.raw %>%
  left_join(job_titles.plus %>% select(-`O*NET-SOC Code`,-SOC),by=c("Job Title" = "Alternate Title")) %>%
  mutate("Job Title" = if_else(is.na(`Job Title.y`),`Job Title`,`Job Title.y`)) %>%
  right_join(job_titles.main,by="Job Title")

# Filter out the ones we know to be wrong
nlm.titles <- anti_join(nlm.titles.raw2,job_titles.minus %>% select(SOC),by="SOC")


saveRDS(nlm.titles,file = file.path(outputs,"nlm.titles.RDS"))
write.csv(nlm.titles,file=file.path(outputs,"nlm.titles.csv"))