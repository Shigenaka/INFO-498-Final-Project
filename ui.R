
library(shiny)
library(plotly)
library(DT)

state_alc_taxrate <- read.csv("data/prepped/alcohol_and_tax_rate_state_data.csv")
tax_data <- read.csv("data/prepped/prepped-tax-data.csv") %>%
  mutate(state = as.character(state)) %>%
  filter(state != "U.S. Median")

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
                      
                      
                      
                      
                      
                      
                      
              ),
             tabPanel("Alcohol Taxation in the US",
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("alchType", 
                                      h3("Alcohol Type"), 
                                      choices = unique(tax_data$type), 
                                      selected = unique(tax_data$type)[[1]]),
                          sliderInput("yearAlch", h3("Year"),
                                      min = min(tax_data$year), max = max(tax_data$year),
                                      value = min(tax_data$year), step = 1,
                                      sep="", ticks = F),
                          h3("States with No Tax"),
                          DT::dataTableOutput("statesNoTax")
                        ),
                        
                        # Show a plot of the generated distribution
                        mainPanel(
                          plotlyOutput("alchPlot"),
                          tags$div(class = "alchText",
                                   tags$p("This plot displays the alcohol taxation in the US by state, year, and by
                                          three types: liquor, wine, and beer. The states without a tax associated
                                          with the selected alcohol type will be displayed in the sidebar table."),
                                   tags$p("Throughout the last four years, not much has changed. Besides a few changes
                                          in Washington, Rhode Island, and Tennessee, taxation has stayed stagnant.
                                          Another interesting note is that Beer is taxed in every state but the 
                                          same cannot be said for wine and liquor.")
                          )
                        )
                      )
             )
            )
  )
)

shinyUI(ui)