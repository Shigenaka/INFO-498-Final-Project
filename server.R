library(shiny)
library(plotly)
library(rsconnect)

# Read in GBD data
gbd_data <- read.csv("data/raw/GBD.csv")

#load alc vs taxrate data
state_alc_taxrate <- read.csv("data/prepped/alcohol_and_tax_rate_state_data.csv")
colnames(state_alc_taxrate)[9:10] <- c("strata", "by")
state_alc_taxrate <- na.omit(state_alc_taxrate)
state_alc_taxrate <- filter(state_alc_taxrate, DataValueType != "Age-adjusted Prevalence", 
                            DataValueType != "Age-adjusted Mean", 
                            DataValueType != "Age-adjusted Rate")

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

# Define server logic required to draw a histogram
server <- shinyServer(function(input, output, session) {

    observeEvent(
      input$Question,
      updateSliderInput(session, "year", "year",
                        min = min(state_alc_taxrate$year[state_alc_taxrate$Question==input$Question]),
                        max = max(state_alc_taxrate$year[state_alc_taxrate$Question==input$Question]),
                        value = c(min(state_alc_taxrate$year[state_alc_taxrate$Question==input$Question]),
                                  max(state_alc_taxrate$year[state_alc_taxrate$Question==input$Question]))
      )
    )
    
    observeEvent(
      input$year,
      updateSelectInput(session, "strata", "strata",
                        choices = state_alc_taxrate$strata[#state_alc_taxrate$year%in%input$year &
                          state_alc_taxrate$Question==input$Question])
    )
    
    observeEvent(
      input$strata,
      updateSelectInput(session, "by", "by",
                        choices = state_alc_taxrate$by[state_alc_taxrate$strata==input$strata &
                                                         state_alc_taxrate$year%in%input$year &
                                                         state_alc_taxrate$Question==input$Question])
    )
    
    observeEvent(
      input$by,
      updateSelectInput(session, "type", "type",
                        choices = state_alc_taxrate$type[state_alc_taxrate$by==input$by &
                                                           state_alc_taxrate$strata==input$strata &
                                                           state_alc_taxrate$year%in%input$year &
                                                           state_alc_taxrate$Question==input$Question])
    )
    
    output$state_alc_taxrate_plot <- renderPlotly({
      filtered_state_alc_taxrate <- filter(state_alc_taxrate, 
                                           Question == input$Question,
                                           year %in% input$year,
                                           type == input$type,
                                           strata == input$strata,
                                           by == input$by)
      
      graph <- plot_ly(
        data = filtered_state_alc_taxrate, x = ~DataValueAlt, y = ~tax_rate, type = "scatter", color = ~year,
        mode='markers',
        hoverinfo = 'text',
        text = ~paste('State: ', state,
                      '</br> Year: ', year,
                      '</br> ID: ', by,
                      '</br> Tax Rate', tax_rate,
                      '</br> X value', DataValueAlt
        )
      )%>%
        layout(
          title = "Alcohol vs Tax Rates",
          xaxis = list (title = input$Question),
          yaxis = list(
            title = "Tax Rate"
          ) 
        )
      graph <- add_trace(graph,
                         x = ~DataValueAlt,
                         y = fitted(lm(tax_rate ~ DataValueAlt, filtered_state_alc_taxrate)),
                         mode = "lines"
      )
    })
    
    output$plot <- renderPlotly({
      
      # target_data <- over_11_count
      
      if(input$ageFilter == "12 and Older" & input$typeFilter == "Count") {
        target_data <- over_11_count
        title.label <- "Number of Individuals Age 12 and Older with Alcohol Use Disorder"
        y.label <- "Number of Individuals"
      } else if (input$ageFilter == "12 and Older" & input$typeFilter == "Proportion") {
        target_data <- over_11_prop
        title.label <- "Proportion of Individuals Age 12 and Older with Alcohol Use Disorder"
        y.label <- "Proportion of Individuals"
      } else if (input$ageFilter == "18 and Older" & input$typeFilter == "Count") {
        target_data <- over_17_count
        title.label <- "Number of Individuals Age 18 and Older with Alcohol Use Disorder"
        y.label <- "Number of Individuals"
      } else if (input$ageFilter == "18 and Older" & input$typeFilter == "Proportion") {
        target_data <- over_17_prop
        title.label <- "Proportion of Individuals Age 18 and Older with Alcohol Use Disorder"
        y.label <- "Proportion of Individuals"
      } else if (input$ageFilter == "26 and Older" & input$typeFilter == "Count") {
        target_data <- over_25_count
        title.label <- "Number of Individuals Age 26 and Older with Alcohol Use Disorder"
        y.label <- "Number of Individuals"
      } else if (input$ageFilter == "26 and Older" & input$typeFilter == "Proportion") {
        target_data <- over_25_prop
        title.label <- "Proportion of Individuals Age 26 and Older with Alcohol Use Disorder"
        y.label <- "Proportion of Individuals"
      }
      
      graph <- plot_ly(data = target_data, x = ~State, y = ~Number, type = "bar") %>%
        layout(
          title = title.label,
          yaxis = list(title = y.label)
        )
      
    })
    
})

shinyServer(server)

