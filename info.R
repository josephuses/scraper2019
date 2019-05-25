# Make a function to process each file
library(jsonlite)
library(tidyverse)
library(data.table)


processsrs <- function(f){
  df <- fromJSON(f, flatten = TRUE)
  info <- as_tibble(t(df))
}

# scan for all info.son files
info_files <- dir("./scraper2019/data/results/", 
                  recursive = TRUE, 
                  full.names = TRUE, 
                  pattern = "\\info.json$")
# import all infor.json files
info <- lapply(info_files, processsrs)

# clean the srs column and convert list elements into data.frame
srsclean <- function(x) {
  stopifnot(is.list(x))
  if (length(x)>0) {
  rbindlist(x)
} else {data.table(rc = integer(),
            rcc = character(),
            rn = character(),
            can = character(),
            cll = character(),
            cl = integer(),
            url = character())}
}

# byte-compile the functions for faster list operations
library(compiler)
srsclean <- cmpfun(srsclean)

info2 <- rbindlist(info)
info2[, srs:= map(srs, srsclean)]
info2[, rc:= unlist(rc)]
info2[, rcc:= unlist(rcc)]
info2[, rn:= unlist(rn)]
info2[, can:= unlist(can)]
info2[, cll:= unlist(cll)]
info2[, cl:= unlist(cl)]
info2[, url:= unlist(url)]
info2[, `total-vb`:= unlist(`total-vb`)]
info2[, `total-voters`:= unlist(`total-voters`)]


ppsclean <- function(x) {
  stopifnot(is.list(x))
  if (length(x)>0) {
    data.table(ppc = x$ppc,
               ppcc = x$ppcc,
               ppn = x$ppn,
               vbc = x$vbs[[1]]$vbc,
               pre = x$vbs[[1]]$pre,
               cpre = x$vbs[[1]]$cpre,
               url = x$vbs[[1]]$url,
               type = x$vbs[[1]]$type,
               cs = x$vbs[[1]]$cs
    )
  } else {data.table(ppc = integer(),
                     ppcc = character(),
                     ppn = character(),
                     vbc = integer(),
                     pre = character(),
                     cpre = character(),
                     url = character(),
                     type = character(),
                     cs = list()
                     )}
}

ppsclean <- cmpfun(ppsclean)

info2[,pps:=map(pps, ppsclean)]

# saveRDS(info_data2, "./data/processed/info.RData")
# info <- readRDS("./data/processed/info.RData")

info3 <- info2
info3$pps <- NULL
info3$srs <- NULL
info3$cs <- NULL
info_final <- info2 %>% unnest(pps) %>% left_join(info3, by = c("rc", "rcc", "rn", "can", "cll", "cl", "url", "total-voters", "total-vb"))
setDT(info_final)

table(info_final$can)

info_mun <- info_final[can=="City/Municipality"]
info_brgy <- info_final[can=="Barangay"]
info_prov <- info_final[can=="Province"]
info_country <- info_final[can=="Country"]

info_brgy[,rccm := substr(rcc,start=1,stop=4)]
info_brgy[,rccp := paste0(substr(rcc,start=1,stop=2), "00")]

# Use code from https://psa.gov.ph/classification/psgc/
code <- fread("./data/processed/Code.csv", sep = ";")
code[,Code:=case_when(nchar(Code)<9~paste0("0",Code),TRUE~as.character(Code))]
setDT(code)

reg <- data.table(region = code$Name[code$`Inter-Level`=="Reg"],
                  rccr = substr(code$Code[code$`Inter-Level`=="Reg"], start = 1, stop=2)
)

code[,`:=`(rccr = substr(Code, start = 1, stop = 2),
           rccp = paste0(substr(Code, start = 3, stop = 4),"00"),
           rccm = substr(Code, start = 3, stop = 6),
           rcc = substr(Code, start = 3, stop = 9),
           Code=NULL)]

mun <- data.table(municipality = info_mun$rn,
                  rccm = info_mun$rcc)

prov <- data.table(province = info_prov$rn,
                   rccp = info_prov$rcc)


info_brgy <- left_join(info_brgy, mun)
info_brgy <- left_join(info_brgy, prov)

info_mun[,rccp:= paste0(substr(rcc, start = 1, stop = 2),"00")]
info_mun[,rcc2:= paste0(substr(rcc, start = 1, stop = 2) ,"00000")]
info_mun <- left_join(info_mun, code)
setDT(info_brgy)

brgy_master <- left_join(info_brgy, code)

brgy_master <- left_join(brgy_master, reg)
mun_master <- left_join(info_mun, reg)
prov_master <- left_join(info_prov, code[rccp==rccm] %>% select(-rcc), by=c("rcc"="rccp")) %>%
  left_join(reg)

setDT(brgy_master)[,`:=`(cs = NULL, tcs = NULL)]
setDT(mun_master)[,`:=`(cs = NULL, tcs = NULL)]
setDT(prov_master)[,`:=`(cs = NULL, tcs = NULL)]

info <- rbindlist(list(brgy_master, mun_master, prov_master), fill = TRUE)
fwrite(info, "./data/processed/info_final.csv")

fwrite(brgy_master, "./data/processed/brgy_info.csv")
fwrite(mun_master, "./data/processed/mun_info.csv")
fwrite(prov_master, "./data/processed/prov_info.csv")
