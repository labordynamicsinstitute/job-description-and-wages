# Download ONET and BLS OES data
# Data is about 50MB - depending on your connection, this might take a while.

source(file.path(rprojroot::find_rstudio_root_file(),"pathconfig.R"),echo=FALSE)
source(file.path(programs,"global-libraries.R"),echo=FALSE)
source(file.path(programs,"libraries.R"), echo=FALSE)
source(file.path(programs,"config.R"), echo=FALSE)

# store metadata
metadata <- as.data.frame(matrix(nrow=2,ncol = 2))
names(metadata) <- c("Filename","Date")

# download O*net data
download.file(paste0(onet.src.base,onet.src.file),destfile = file.path(acquired,onet.src.file))
unzip(file.path(acquired,onet.src.file),
      file.path(tools::file_path_sans_ext(onet.src.file),onet.file1),
      junkpaths = TRUE,exdir = acquired)
unzip(file.path(acquired,onet.src.file),
      file.path(tools::file_path_sans_ext(onet.src.file),onet.file2),
      junkpaths = TRUE,exdir = acquired)
metadata$Filename[1] <- onet.src.file
metadata$Date[1] <- format(Sys.Date())
  
# download bls OES data
download.file(paste0(oes.src.base,oes.src.file),destfile = file.path(acquired,oes.src.file))
unzip(file.path(acquired,oes.src.file),
      file.path(paste0("oesm",oes.src.version,"nat"),oes.internal.file),
      junkpaths = TRUE,exdir = acquired)

metadata$Filename[2] <- oes.src.file
metadata$Date[2] <- format(Sys.Date())

saveRDS(metadata,file.path(acquired,"metadata.Rds"))

