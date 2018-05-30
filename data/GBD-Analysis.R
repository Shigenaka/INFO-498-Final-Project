

library(dplyr)


raw_drug_data <- read.csv("raw/IHME-GBD_2016_DATA-4edf4eb1-1.csv")
states <- read.csv('raw/state_table.csv', strip.white = TRUE)
states$value <- as.character((states$value))



clean_drug_data <- raw_drug_data %>%
  select(measure, location, cause, metric, val, year) %>%
  mutate(location = as.character(location)) %>%
  filter(metric == "Percent",
         cause %in% c("Opioid use disorders", "Amphetamine use disorders")) %>%
  group_by(location, cause, year) %>%
  summarise(val = mean(val))

alc_data <-
  read.csv('prepped/prepped-us-alcohol-abuse-17-prop.csv')

clean_drug_data <-
  left_join(clean_drug_data, states, by = c('location' = 'value'))


clean_drug_data <-
  left_join(clean_drug_data,
            alc_data,
            by = c('location' = 'State'),
            as = "alc_prop")


write.csv(
  clean_drug_data,
  "C:/Users/Ryan/Documents/UW 2017-2018/Spring/Info498/INFO-498-Final-Project/data/prepped/state_drug_use_data.csv"
)
