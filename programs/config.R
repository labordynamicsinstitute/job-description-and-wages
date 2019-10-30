#Any libraries needed are called and if necessary installed through `libraries.R`:


onet.src.base <- "https://www.onetcenter.org/dl_files/database/"
onet.src.version <- "23_2"
onet.src.file <- paste("db",onet.src.version,"excel.zip",sep="_")
onet.file1 <- "Occupation Data.xlsx"
onet.file2 <- "Alternate Titles.xlsx"

oes.src.base <- "https://www.bls.gov/oes/special.requests/"
oes.src.version <- "18"
oes.src.file <- paste("oesm",oes.src.version,"nat.zip",sep="")
oes.internal.file <- paste0("national_M20",oes.src.version,"_dl.xlsx")

soc_definitions_loc <- "https://www.bls.gov/soc/soc_structure_2010.xls"

jw.max <- 0.05