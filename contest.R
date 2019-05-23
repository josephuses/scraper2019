# Make a function to process each file
library(jsonlite)
library(tidyverse)
library(data.table)
processnames <- function(f){
  df <- fromJSON(f, flatten = TRUE)
  bos <- df$bos
  type <- df$type
  pre <- df$pre
  ccn <- df$ccn
  ccc <- df$ccc
  cn <- df$cn
  cc <- df$cc
  bos$type <- type
  bos$pre <- pre
  bos$ccn <- ccn
  bos$ccc <- ccc
  bos$cn <- cn
  bos$cc <- cc
  bos
}

# Find all .json files
files <- dir("./scraper2019/data/contests/", recursive = TRUE, full.names = TRUE, pattern = "\\.json$")
names <- lapply(files, processnames)
names_df <- rbindlist(names)
fwrite(names_df, "./scraper2019/data/processed/contest.csv")
