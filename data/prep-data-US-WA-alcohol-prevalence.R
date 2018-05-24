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
  filter(year_pair == "2012-13" | year_pair == "2013-14" | year_pair == "2014-15")


alcohol_dependence_abuse_data <- joined_data %>%
  filter(outcome == "Alcohol Dependence or Abuse in the Past Year")



ggplot(joined_data, aes(year_pair, estimate, fill = geography)) +
  geom_bar(stat = "identity", position = "dodge", color = "black")

ggplot(joined_data, aes(year_pair, estimate, color = geography)) +
  geom_point()

ggplotly(ggplot(alcohol_dependence_abuse_data,
                aes(year_pair, estimate, color = geography, group = geography)) +
           geom_point() +
           geom_line())


plot_ly(data = alcohol_dependence_abuse_data, x = ~year_pair, y = ~estimate, fill = ~geography, 
        type = "scatter", mode = "lines")

WA_alcohol_dependence_abuse_data <- alcohol_dependence_abuse_data %>%
  filter(geography == "Washington")

US_alcohol_dependence_abuse_data <- alcohol_dependence_abuse_data %>%
  filter(geography == "United States")

data <- data.frame(US_alcohol_dependence_abuse_data, WA_alcohol_dependence_abuse_data)

plot_ly(data = WA_alcohol_dependence_abuse_data, x = ~year_pair, y = ~estimate, 
        type = "scatter", mode = "lines") %>%
  add_trace(data = US_alcohol_dependence_abuse_data, x = ~year_pair, y = ~estimate,
            type = "scatter", mode = "lines")

