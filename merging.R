library(data.table)
library(tidyverse)
brgy_master <- fread("./data/processed/brgy_info.csv")
mun_master <- fread("./data/processed/mun_info.csv")
prov_master <- fread("./data/processed/mun_info.csv")
coc <- fread("./data/processed/coc.csv")
tail(coc)
rs <- fread("./data/processed/rs.csv")
head(rs)
votes <- fread("./data/processed/votes2.csv")
head(votes)
contest <- fread("./data/processed/contest.csv")
#contest %>% arrange(boc)

head(contest)
dim(rs)
dim(votes)
dim(coc)
head(info2)

head(senators)
names(votes)
names(contest)

# say for example you want
senators <- contest[ccn == "SENATOR"]
senators <- senators %>% left_join(votes, by = c("boc"="bo", "cc"))
rm(contest)
rm(votes)


fwrite(senators, "./data/processed/senators_brgy.csv")

names(senators)
