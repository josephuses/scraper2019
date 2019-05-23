# Make a function to process each file
library(jsonlite)
library(tidyverse)
library(data.table)
processsrs <- function(f){
  df <- fromJSON(f, flatten = TRUE)
  info <- as_tibble(t(df))
}


info_files <- dir("./scraper2019/data/results/", recursive = TRUE, full.names = TRUE, pattern = "\\info.json$")

info <- lapply(info_files, processsrs)

info_dat <- rbindlist(info)

info_dat2 <- info_dat %>% unnest(list(pps), .preserve = c(srs, tcs)) 