library(dplyr)
library(ggplot2)
library(plotly)

us_alcohol_prev <- read.csv("data/raw/US_Alcohol_Prevalence.csv")
wa_alcohol_dependence_prev <- read.csv("data/raw/WA_Alcohol_Dependence_Prevalence.csv")
wa_alcohol_dependence_abuse_prev <- read.csv("data/raw/WA_Alcohol_Dependence_Abuse_Prevalence.csv")
wa_alcohol_use_prevalence_prev <- read.csv("data/raw/WA_Alcohol_Use_Prevalence.csv")

colnames(wa_alcohol_dependence_abuse_prev)[1] <- "outcome"
colnames(wa_alcohol_dependence_prev)[1] <- "outcome"
colnames(wa_alcohol_use_prevalence_prev)[1] <- "outcome"

joined_data <- rbind(us_alcohol_prev, wa_alcohol_dependence_abuse_prev,
                     wa_alcohol_dependence_prev, wa_alcohol_use_prevalence_prev) %>%
  filter(year_pair == "2010-11" | year_pair == "2011-12" | year_pair == "2012-13" |
           year_pair == "2013-14" | year_pair == "2014-15")
joined_data$year_pair <- as.character(joined_data$year_pair)
joined_data$year_pair[joined_data$year_pair == "2010-11"] <- "2010"
joined_data$year_pair[joined_data$year_pair == "2011-12"] <- "2011"
joined_data$year_pair[joined_data$year_pair == "2012-13"] <- "2012"
joined_data$year_pair[joined_data$year_pair == "2013-14"] <- "2013"
joined_data$year_pair[joined_data$year_pair == "2014-15"] <- "2014"
colnames(joined_data)[3] <- "Year"
colnames(joined_data)[5] <- "Prevalence"

write.csv(joined_data, "data/prepped/prepped-us-wa-alcohol-prevalence.csv",
          row.names = FALSE)

