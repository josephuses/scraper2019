# Make a function to process each file
library(jsonlite)
processsrs <- function(f){
  df <- fromJSON(f, flatten = TRUE)
  rs <- df$rs
  vbc <- df$vbc
  rs$vbc <- vbc
  rs
}

processcos <- function(f){
  df <- fromJSON(f, flatten = TRUE)
  cos <- df$cos
  vbc <- df$vbc
  cos$vbc <- vbc
  cos
}

processsts <- function(f){
  df <- fromJSON(f, flatten = TRUE)
  sts <- df$sts
  vbc <- df$vbc
  sts$vbc <- vbc
  sts
}

processobs <- function(f){
  df <- fromJSON(f, flatten = TRUE)
  obs <- df$obs
  vbc <- df$vbc
  obs$vbc <- vbc
  obs
}

# Find all .json files

coc_files <- dir("./scraper2019/data/results/", recursive = TRUE, full.names = TRUE, pattern = "\\coc.json$")

rs <- lapply(coc_files, processsrs)
coc <- lapply(coc_files, processcos)
sts <- lapply(coc_files, processsts)
obs <- lapply(coc_files, processobs)

library(data.table)

coc <- rbindlist(coc)
rs <- rbindlist(rs)

fwrite(coc, "./scraper2019/data/processed/coc.csv")
fwrite(rs, "./scraper2019/data/processed/rs.csv")
