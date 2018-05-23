library(dplyr)

# Read in data

# Table 21. Alcohol Use Disorder in the Past Year, by Age Group and State:
# Estimated Numbers (in Thousands), Annual Averages Based on 2015 and 2016 NSDUHs
alcohol_data <- read.csv("data/raw/NSDUHsaeTotals2016-CSVs/alcohol_use_disorder.csv",
                         stringsAsFactors = F)

# Estimated 2016 U.S. state populations by age groups

population_data <- read.csv("data/raw/PEP_2016_PEPAGESEX_with_ann.csv", stringsAsFactors = F)

# Wrangle data

alcohol_data[1, 2] <- "United States"
alcohol_data <- alcohol_data[-1 : -5, ]

alcohol_data$Age_Over_11 <- 
  as.numeric(gsub(",", "", alcohol_data$X12.or.Older.Estimate)) * 1000
alcohol_data$Age_Over_17 <- 
  as.numeric(gsub(",", "", alcohol_data$X18.or.Older.Estimate)) * 1000
alcohol_data$Age_Over_25 <-
  as.numeric(gsub(",", "", alcohol_data$X26.or.Older.Estimate)) * 1000

alcohol_data <- select(alcohol_data, State, Age_Over_11, Age_Over_17, Age_Over_25)

population_data <- select(population_data, GEO.display.label, est72016sex0_age10to14, 
                          est72016sex0_age15to19, est72016sex0_age20to24, est72016sex0_age25to29,
                          est72016sex0_age30to34, est72016sex0_age35to39, est72016sex0_age40to44,
                          est72016sex0_age45to49, est72016sex0_age50to54, est72016sex0_age55to59,
                          est72016sex0_age60to64, est72016sex0_age65to69, est72016sex0_age70to74,
                          est72016sex0_age75to79,est72016sex0_age80to84, est72016sex0_age85plus)

population_data <- population_data[-1, ]

for(i in c(2 : ncol(population_data))) {
  population_data[ , i] <- as.numeric(population_data[ , i])
}

population_data <- mutate(population_data, Total_Age_Over_11 = (est72016sex0_age10to14 / 2) + est72016sex0_age15to19 + 
                            est72016sex0_age20to24 +  est72016sex0_age25to29 + est72016sex0_age30to34 +
                            est72016sex0_age35to39 +  est72016sex0_age40to44 + est72016sex0_age45to49 +
                            est72016sex0_age50to54 +  est72016sex0_age55to59 + est72016sex0_age60to64 +
                            est72016sex0_age65to69 +  est72016sex0_age70to74 + est72016sex0_age75to79 + 
                            est72016sex0_age80to84 +  est72016sex0_age85plus,
                          Total_Age_Over_17 = Total_Age_Over_11 - (est72016sex0_age10to14 / 2) - 
                            (est72016sex0_age15to19 / 2),
                          Total_Age_Over_25 = Total_Age_Over_17 - (est72016sex0_age15to19 / 2) - 
                            est72016sex0_age20to24) %>%
  select(GEO.display.label, Total_Age_Over_11, Total_Age_Over_17, Total_Age_Over_25)

colnames(population_data)[1] <- "State"

joined_data <- left_join(alcohol_data, population_data) %>%
  mutate(Prop_Age_Over_11 = Age_Over_11 / Total_Age_Over_11,
         Prop_Age_Over_17 = Age_Over_17 / Total_Age_Over_17,
         Prop_Age_Over_25 = Age_Over_25 / Total_Age_Over_25)

over_11_count <- select(joined_data, State, Age_Over_11)
colnames(over_11_count)[2] <- "Number"
over_11_prop <- select(joined_data, State, Prop_Age_Over_11)
colnames(over_11_prop)[2] <- "Number"
over_17_count <- select(joined_data, State, Age_Over_17)
colnames(over_17_count)[2] <- "Number"
over_17_prop <- select(joined_data, State, Prop_Age_Over_17)
colnames(over_17_prop)[2] <- "Number"
over_25_count <- select(joined_data, State, Age_Over_25)
colnames(over_25_count)[2] <- "Number"
over_25_prop <- select(joined_data, State, Prop_Age_Over_25)
colnames(over_25_prop)[2] <- "Number"

write.csv(over_11_count, "data/prepped/prepped-us-alcohol-abuse-11-count.csv",
          row.names = FALSE)
write.csv(over_11_prop, "data/prepped/prepped-us-alcohol-abuse-11-prop.csv",
          row.names = FALSE)
write.csv(over_17_count, "data/prepped/prepped-us-alcohol-abuse-17-count.csv",
          row.names = FALSE)
write.csv(over_17_prop, "data/prepped/prepped-us-alcohol-abuse-17-prop.csv",
          row.names = FALSE)
write.csv(over_25_count, "data/prepped/prepped-us-alcohol-abuse-25-count.csv",
          row.names = FALSE)
write.csv(over_25_prop, "data/prepped/prepped-us-alcohol-abuse-25-prop.csv",
          row.names = FALSE)
