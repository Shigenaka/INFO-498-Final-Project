library(dplyr)

alc_data <- read.csv("data/raw/alch-prev-wa.csv")
drug_data <- read.csv("data/prepped/state_drug_use_data.csv")

clean_drug <- drug_data %>%
  select(location, cause, year, val, code) %>%
  filter(year >= 2010, year <= 2015, cause == 'Opioid use disorders', code=='WA')

  
clean_alc <- alc_data %>%
  select(location, year, alc_prev = val) %>%
  filter(year >= 2010, year <= 2015, location=='Washington')


clean_alc_drug <- left_join(clean_drug, clean_alc, by = 'location')
