#setwd("/Users/MasonShigenaka/Desktop/INFO 498 D/INFO-498-Final-Project")

library(readxl)
library(dplyr)
library(tidyr)

rawdata <- read_excel("./data/raw/population-by-state.xlsx")
colnames(rawdata)[1] <- "state"
middledata <- rawdata[4:61,] %>%
  filter(!is.na(state)) %>%
  select(-X__1, -X__2) %>%
  mutate(state = ifelse(startsWith(state, "."), substring(state,2), state))
colnames(middledata) <- c("state", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017")

middledata <- middledata %>%
  gather(key = year, value = population, c("2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017")) %>%
  mutate(year = as.integer(year))

write.csv(middledata, "./data/prepped/state-population-data.csv", row.names = F)
