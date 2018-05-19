#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/

library(shiny)
library(plotly)

# Define server logic required to draw a histogram
server <- shinyServer(function(input, output, session) {
    # Read in NSDUH data (Must extract NSDUH.tsv)
    nsduh_data <- read.csv("data/raw/NSDUH/NSDUH.tsv", sep = "\t")

    # Read in GBD data
    gbd_data <- read.csv("data/raw/GBD.csv")

    #load alc vs taxrate data
    state_alc_taxrate <- read.csv("~/info498/wb-8-kevinsanglim/data/prepped/alcohol_and_tax_rate_state_data.csv")
    colnames(state_alc_taxrate)[9:10] <- c("strata", "by")
    state_alc_taxrate <- na.omit(state_alc_taxrate)
    state_alc_taxrate <- filter(state_alc_taxrate, DataValueType != "Age-adjusted Prevalence", 
                               DataValueType != "Age-adjusted Mean", 
                               DataValueType != "Age-adjusted Rate")
    
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

  })

})

