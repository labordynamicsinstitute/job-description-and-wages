# Download ONET data
# Data is about 50MB - depending on your connection, this might take a while.

source(file.path(rprojroot::find_rstudio_root_file(),"pathconfig.R"),echo=FALSE)
source(file.path(programs,"config.R"), echo=FALSE)

# load onet data
Alternate_Titles <- read_excel(file.path(generated,"Alternate Titles.xlsx"))

# load the jobtitle data (our own list)
job_titles <- read_excel(file.path(generated,"job_titles.xlsx"))
names(job_titles) <- c("Job Title")

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
                                 max_dist=0.05)
secondary <- stringdist_inner_join(y=soc_job_alttitles,
                                   x=job_titles,
                                   by = c("Job Title" = "Alternate Title"),
                                   method="jw",
                                   distance_col="jw_distance",
                                   max_dist=0.05)

# Still needs frequencies of relation alternate to primary
