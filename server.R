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

# Read in US alcohol abuse counts and proportions

over_11_count <- read.csv("data/prepped/prepped-us-alcohol-abuse-11-count.csv")
over_11_prop <- read.csv("data/prepped/prepped-us-alcohol-abuse-11-prop.csv")
over_17_count <- read.csv("data/prepped/prepped-us-alcohol-abuse-17-count.csv")
over_17_prop <- read.csv("data/prepped/prepped-us-alcohol-abuse-17-prop.csv")
over_25_count <- read.csv("data/prepped/prepped-us-alcohol-abuse-25-count.csv")
over_25_prop <- read.csv("data/prepped/prepped-us-alcohol-abuse-25-prop.csv")


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
    
    output$alcoholUseDisorderPlot <- renderPlotly({
      
      # target_data <- over_11_count
      
      if(input$alcoholUseDisorderAgeFilter == "12 and Older" & input$alcoholUseDisorderTypeFilter == "Count") {
        target_data <- over_11_count
        title.label <- "Number of Individuals Age 12 and Older with Alcohol Use Disorder"
        y.label <- "Number of Individuals"
      } else if (input$alcoholUseDisorderAgeFilter == "12 and Older" & input$alcoholUseDisorderTypeFilter == "Proportion") {
        target_data <- over_11_prop
        title.label <- "Proportion of Individuals Age 12 and Older with Alcohol Use Disorder"
        y.label <- "Proportion of Individuals"
      } else if (input$alcoholUseDisorderAgeFilter == "18 and Older" & input$alcoholUseDisorderTypeFilter == "Count") {
        target_data <- over_17_count
        title.label <- "Number of Individuals Age 18 and Older with Alcohol Use Disorder"
        y.label <- "Number of Individuals"
      } else if (input$alcoholUseDisorderAgeFilter == "18 and Older" & input$alcoholUseDisorderTypeFilter == "Proportion") {
        target_data <- over_17_prop
        title.label <- "Proportion of Individuals Age 18 and Older with Alcohol Use Disorder"
        y.label <- "Proportion of Individuals"
      } else if (input$alcoholUseDisorderAgeFilter == "26 and Older" & input$alcoholUseDisorderTypeFilter == "Count") {
        target_data <- over_25_count
        title.label <- "Number of Individuals Age 26 and Older with Alcohol Use Disorder"
        y.label <- "Number of Individuals"
      } else if (input$alcoholUseDisorderAgeFilter == "26 and Older" & input$alcoholUseDisorderTypeFilter == "Proportion") {
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

