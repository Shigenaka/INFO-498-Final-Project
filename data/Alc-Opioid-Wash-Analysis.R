library(dplyr)

alc_data <- read.csv("data/raw/alch-prev-wa.csv")
drug_data <- read.csv("data/prepped/state_drug_use_data.csv")

clean_drug <- drug_data %>%
  select(location, cause, year, val, code) %>%
  filter(year >= 2010,
         year <= 2015,
         cause == 'Opioid use disorders',
         code == 'WA')


clean_alc <- alc_data %>%
  select(location, year, alc_prev = val) %>%
  filter(year >= 2010, year <= 2015, location == 'Washington')


clean_alc_drug <-
  left_join(clean_drug, clean_alc, by = 'year' ) %>%
  select(year, val, alc_prev) %>%
  mutate(diff_opioid = val - lag(val), diff_alc = alc_prev - lag(alc_prev))


library(ggplot2)

ggplot(clean_alc_drug, aes(val, alc_prev)) + geom_point()
ggplot(clean_alc_drug, aes(year, diff_alc)) + geom_line() + geom_line(aes(year, diff_opioid))


write.csv(
  clean_alc_drug,
  "C:/Users/Ryan/Documents/UW 2017-2018/Spring/Info498/INFO-498-Final-Project/data/prepped/washington_opioid_alc_analysis.csv"
)
