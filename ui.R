
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
  
  navbarPage("",
             
             tabPanel("Kevin",
                
                      sidebarLayout(
                        
                        sidebarPanel(
                          
                          selectInput("Question", "Question",
                                      choices = unique(state_alc_taxrate$Question) 
                                      ),
                          
                          sliderInput("year", label = h3("year"), min = NA,
                                      max = NA, value = c(NA,NA)
                                      ),
                          
                          selectInput("strata", "strata", choices = "", 
                                      selected = ""
                                      ),
                          
                          selectInput("by", "by", choices = "", selected = ""
                                      ),
                          
                          selectInput("type", "type", choices = "", selected = ""
                                      )
                        ),
                        
                        # Show a plot of the generated distribution
                        mainPanel(
                          plotlyOutput('state_alc_taxrate_plot', height = "900px")
                        )
                      )
                    ),
             
             tabPanel("Alex: Alcohol Use Disorder in the United States 2015-2016",
                      sidebarLayout(
                        
                        sidebarPanel(
                          
                          selectInput("ageFilter", label = "Choose the Age Range",
                                      choices = c("12 and Older", "18 and Older", "26 and Older"),
                                      selected = "12 and Older"),
                          
                          radioButtons("typeFilter", "Count or Proportion",
                                       c("Count", "Proportion"),
                                       selected = "Count")
                          
                        ),
                        
                        
                        mainPanel(
                          
                          plotlyOutput("plot")
                        )
                      )
                      
                      
                      
                      
                      
                      
                      
                      )
            )
  )
)

shinyUI(ui)