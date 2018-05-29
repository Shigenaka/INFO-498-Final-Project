setwd("/Users/MasonShigenaka/Desktop/INFO 498 D/INFO-498-Final-Project")

library(dplyr)
library(tidyr)
library(ggplot2)

over_17_prop <- read.csv("data/prepped/prepped-us-alcohol-abuse-17-prop.csv")
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
  select(-years) %>%
  group_by(state, year0, year1) %>%
  summarise(total_change = sum(change))

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
colnames(all_data)[4] <- "change_tax"
colnames(all_data)[5] <- "change_alch"

##Year Diff analysis

summary(lm(change_alch~change_tax, data=all_data))

plot_data <- all_data %>%
  filter(change_tax >= 0.01)
ggplot(all_data, aes(x=change_tax, y=change_alch)) +
  geom_point()

over_25_prop <- read.csv("data/prepped/prepped-us-alcohol-abuse-25-prop.csv")

write.csv(all_data, "./data/prepped/diff-alch-tax.csv", row.names = F)

tax_2015 <- tax_data %>%
  filter(year == 2015) %>%
  group_by(state) %>%
  summarise(total_tax = sum(tax_rate)) %>%
  mutate(state = ifelse(state == "Dist. of Columbia", "District of Columbia", as.character(state)))


## Single year analysis on risk
single_year_data <- over_25_prop %>%
  left_join(tax_2015, by=c("State" = "state"))
summary(lm(Number~total_tax, data=single_year_data))
ggplot(single_year_data, aes(x=total_tax, y=Number)) +
  geom_point()

write.csv(single_year_data, "./data/prepped/15-16-reg-data.csv")
