# Make a function to process each file
library(jsonlite)
processFile <- function(f){
  fromJSON(f, flatten = TRUE)
}

# Find all .json files

files <- dir("./scraper2019/data/results/", recursive = TRUE, full.names = TRUE, pattern = "\\.json$")

result <- lapply(files, processFile)
str(result)
