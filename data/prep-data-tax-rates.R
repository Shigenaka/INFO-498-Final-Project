setwd("/Users/MasonShigenaka/Desktop/INFO 498 D/INFO-498-Final-Project")

library(readxl)
library(dplyr)

read_excel_allsheets <- function(filename, tibble = FALSE) {
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}

allSheets <- read_excel_allsheets("./data/raw/alcohol_rates_3.xls")

for (i in seq(1:length(allSheets))){
  tempname <- ls(allSheets[i])
  tempdf <- allSheets[[i]]
  colnames(tempdf)[1] <- "state"
  if(tempname %in% c("2013", "2014", "2015", "2016", "2017")) {
    tempdf <- tempdf %>%
      select(state, X__1, X__4, X__7) %>%
      filter(!is.na(state))
    tempdf <- tempdf[3:54,]
    colnames(tempdf) <- c("state", "liquor", "wine", "beer")
    tempdf$year <- tempname
    tempdf <- tempdf %>%
      mutate(liquor = ifelse(!is.na(as.numeric(liquor)), as.numeric(liquor), 0),
             wine = ifelse(!is.na(as.numeric(wine)), as.numeric(wine), 0),
             beer = ifelse(!is.na(as.numeric(beer)), as.numeric(beer), 0),
             state = ifelse(startsWith(state, "Washington"), "Washington", state))
    assign(paste0("data", tempname), tempdf)
  }
}

prepped_data <- rbind(data2013, data2014, data2015, data2016, data2017)

write.csv(prepped_data, "./data/prepped/prepped-tax-data.csv")
