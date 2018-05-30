library(ggplot2)
library(dplyr)
library(tidyr)

state_drug_use <- read.csv('data/prepped/state_drug_use_data.csv')
opioid_alc <- state_drug_use %>%
  select(location, cause, val, code, Number) %>%
  filter(cause =="Opioid use disorders") %>%
  group_by(location, cause, code) %>%
  summarise(val = mean(val), Number = mean(Number))

amphetamine_alc <- state_drug_use%>%
  select(location, cause, val, code, Number) %>%
  filter(cause =="Amphetamine use disorders") %>%
  group_by(location, cause, code) %>%
  summarise(val = mean(val), Number = mean(Number))

opioid_amphetamine <- state



ggplot(opioid_alc, aes(x = val, y = Number)) + geom_point() + geom_smooth()
ggplot(amphetamine_alc, aes(x = val, y = Number)) + geom_point() + geom_smooth()

amphetamine_opioid <- state_drug_use %>%
  select(code, cause, val) %>%
  group_by(code, cause) %>%
  summarise(val = mean(val)) %>%
  separate(cause, c("Opioid", 'Amphetamine'), sep='Amphetamine use disorders')
