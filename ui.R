
library(shiny)
library(plotly)

state_alc_taxrate <- read.csv("data/prepped/alcohol_and_tax_rate_state_data.csv")

ui <- shinyUI(fluidPage(
  
  tags$style(type="text/css",
             ".shiny-output-error { visibility: hidden; }",
             ".shiny-output-error:before { visibility: hidden; }"
  ),
  
  # Application title
  titlePanel("Drinking vs Tax Rates"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("Question", "Question",
                  choices = unique(state_alc_taxrate$Question) 
      ),
      
      sliderInput("year", label = h3("year"), min = NA, 
                  max = NA, value = c(NA,NA)
      ),
      
      selectInput("strata", "strata",
                  choices = "",
                  selected = ""
      ),
      selectInput("by", "by",
                  choices = "",
                  selected = ""
      ),
      
      selectInput("type", "type",
                  choices = "",
                  selected = ""
      )
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotlyOutput('state_alc_taxrate_plot', height = "900px")
    )
  )
))

shinyUI(ui)