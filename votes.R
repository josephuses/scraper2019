# Make a function to process each file
library(jsonlite)
processrs <- function(f){
  df <- fromJSON(f, flatten = TRUE)
  rs <- df$rs
  vbc <- df$vbc
  df
}

processcos <- function(f){
  df <- fromJSON(f, flatten = TRUE)
  cos <- df$cos
  vbc <- df$vbc
  df
}

processSts <- function(f){
  df <- fromJSON(f, flatten = TRUE)
  sts <- df$sts
  vbc <- df$vbc
  df
}

processobs <- function(f){
  df <- fromJSON(f, flatten = TRUE)
  obs <- df$obs
  vbc <- df$vbc
  df
}

# Find all .json files
## Find all files named "coc.json"
coc_files <- dir("./scraper2019/data/results/", recursive = TRUE, full.names = TRUE, pattern = "\\coc.json$")
## Find all files named "info.json"
info_files <- dir("./scraper2019/data/results/", recursive = TRUE, full.names = TRUE, pattern = "\\info.json$")
## Find all json files
json_files <- dir("./scraper2019/data/results/", recursive = TRUE, full.names = TRUE, pattern = ".json$")
## Remove all files named "coc.json" and "info.json" from json_files
vote_files <- setdiff(setdiff(json_files, coc_files), info_files)


votes <- lapply(vote_files, processrs)
cos_votes <- lapply(vote_files, processcos)
sts_votes <- lapply(vote_files, processSts)
obs_votes <- lapply(vote_files, processobs)
