#Setup
#setwd("/Users/Klimb/Documents/INFO498/INFO-498-Final-Project")
library(dplyr)
library(readxl)

#Load in data and fiter by relevent alcohol data
disease_data <- read.csv("data/raw/U.S._Chronic_Disease_Indicators__CDI_.csv", stringsAsFactors = FALSE)
tax_data <- read.csv("data/prepped/prepped-tax-data.csv", stringsAsFactors = FALSE)
 

alcohol_data <- filter(disease_data, disease_data$Topic == "Alcohol")
alcohol_data <- select(alcohol_data, YearEnd, LocationDesc, Question,
                       DataValueUnit, DataValueType, DataValueAlt,
                       StratificationCategory1, Stratification1)
names(alcohol_data)[1] <- "year"
names(alcohol_data)[2] <- "state"

#unique(alcohol_data$Question)
#Filter by heavy drinking among 18+ year olds
#binge_alc_data <- filter(alcohol_data, Question == "Heavy drinking among adults aged >= 18 years",
#                         StratificationCategory1 == "Overall")

tax_average_data <- group_by(tax_data, state, year) %>% summarise(
                            type = "Overall Mean",
                            tax_rate = sum(tax_rate)
                            )
tempdf <- bind_rows(tax_average_data, tax_data)
alcohol_data <- left_join(tempdf, alcohol_data)

binge_youth_data <- read_excel("data/raw/Binge alcohol drinking among youths by age group.xlsx")
binge_youth_data <- filter(binge_youth_data, DataFormat == "Percent")
binge_youth_data$Data <- as.numeric(binge_youth_data$Data)
binge_youth_data$TimeFrame <- substring(binge_youth_data$TimeFrame, 6)
names(binge_youth_data)[3] <- "year"
binge_youth_data$year <- as.numeric(binge_youth_data$year)
names(binge_youth_data)[1] <- "state"
youth_binge_and_tax_data <- left_join(tax_average_data, binge_youth_data, by = c("state","year"))

write.csv(youth_binge_and_tax_data, "./data/prepped/youth_binge_and_tax_data.csv", row.names = F)
write.csv(alcohol_data, "./data/prepped/alcohol_and_tax_rate_state_data.csv", row.names = F)


