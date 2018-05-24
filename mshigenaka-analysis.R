setwd("/Users/MasonShigenaka/Desktop/INFO 498 D/INFO-498-Final-Project")

library(dplyr)
library(tidyr)

tax_data<- read.csv("./data/prepped/prepped-tax-data.csv")
alch_prev <- read.csv("./data/raw/IHME-Alch/IHME-Alch.csv") %>%
  select(location, year, metric,val) %>%
  filter(metric == "Percent") %>%
  select(-metric)

tax_data_diff <- tax_data %>%
  spread(year, tax_rate) %>%
  mutate("2013_2014" = (`2014`- `2013`),
         "2014_2015" = (`2015`- `2014`),
         "2015_2016" = (`2016`- `2015`),
         "2016_2017" = (`2017`- `2016`))
tax_data_diff <- tax_data_diff %>%
  select(-`2013`, -`2014`, -`2015`, -`2016`, -`2017`) %>%
  gather(key=years, value=change, c("2013_2014", "2014_2015","2015_2016", "2016_2017")) %>%
  mutate(year0 = substr(years, 1, 4),
         year1 = substr(years, 6, 9)) %>%
  select(-years)

alch_chage <- alch_prev %>%
  spread(year, val) %>%
  mutate("2013_2014" = (`2014`- `2013`),
         "2014_2015" = (`2015`- `2014`),
         "2015_2016" = (`2016`- `2015`)) %>%
  select(-`2013`, -`2014`, -`2015`, -`2016`) %>%
  gather(key=years, value=change, c("2013_2014", "2014_2015","2015_2016")) %>%
  mutate(year0 = substr(years, 1, 4),
         year1 = substr(years, 6, 9)) %>%
  select(-years)

all_data <- tax_data_diff %>%
  left_join(alch_chage, by = c("state" = "location", "year0", "year1")) %>%
  filter(year1 != 2017)
colnames(all_data)[3] <- "change_tax"
colnames(all_data)[6] <- "change_alch"

liquor_data <- all_data %>%
  filter(type == "liquor")

summary(lm(change_alch~change_tax, data=liquor_data))
