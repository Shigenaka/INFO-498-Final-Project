

library(shiny)
library(plotly)
library(DT)

state_alc_taxrate <-
  read.csv("data/prepped/alcohol_and_tax_rate_state_data.csv")
tax_data <- read.csv("data/prepped/prepped-tax-data.csv") %>%
  mutate(state = as.character(state)) %>%
  filter(state != "U.S. Median")

ui <- shinyUI(fluidPage(
  tags$style(
    type = "text/css",
    ".shiny-output-error { visibility: hidden; }",
    ".shiny-output-error:before { visibility: hidden; }"
  ),
  
  # Application title
  titlePanel(
    "The Relationship Between Alcohol, Tax Rates, and other Substances"
  ),
  
  navbarPage(
    "",
    
    tabPanel("Kevin",
      sidebarLayout(
               sidebarPanel(
                 selectInput("Question", "Question",
                             choices = unique(state_alc_taxrate$Question)),
                 
                 sliderInput(
                   "year",
                   label = h3("year"),
                   min = NA,
                   max = NA,
                   value = c(NA, NA)
                 ),
                 
                 selectInput("strata", "strata", choices = "",
                             selected = ""),
                 
                 selectInput("by", "by", choices = "", selected = ""),
                 
                 selectInput("type", "type", choices = "", selected = "")
               ),
               
               # Show a plot of the generated distribution
               mainPanel(plotlyOutput('state_alc_taxrate_plot', height = "900px"))
             )),
      tabPanel("Alex: Alcohol Use Disorder in the United States 2015-2016",
                sidebarLayout(
                        
                        sidebarPanel(
                          
                          selectInput("alcoholUseDisorderAgeFilter", label = "Choose the Age Range",
                                      choices = c("12 and Older", "18 and Older", "26 and Older"),
                                      selected = "12 and Older"),
                          
                          radioButtons("alcoholUseDisorderTypeFilter", "Count or Proportion",
                                       c("Count", "Proportion"),
                                       selected = "Count")
                          
                        ),
                        
                        
                        mainPanel(
                          
                          plotlyOutput("alcoholUseDisorderPlot")
                        )
                      )    
              ),
    tabPanel(
      "The Relationship Between Drug and Alcohol Abuse in the USA",
      sidebarLayout(
        sidebarPanel(
          selectInput(
            "causeOpioidFilter",
            h2("Type of Substance"),
            choices = c("Opioid", 'Amphetamine', "Alcohol"),
            selected = "Opioid"
          )
        ),
        mainPanel(
          plotlyOutput("drugPlot"),
          tags$br(),
          tags$h2("Relationships Between Substances"),
          tags$br(),
          plotlyOutput("amphetamine_alc"),
          tags$br(),
          plotlyOutput("opioid_alc"),
          tags$br(),
          plotlyOutput("opioid_amphetamine"),
          tags$br(),
          tags$h3("Analysis"),
          tags$p(
            "Looking at the data above we can see that there is little to no correlation between the different substance use disorders. Additionally, we originally used a year range as a control for the substance use disorder by state, however, the change in prevalence year-over-year was extremely small for most states, with some states like Alabama only seeing a 6% decrease over 16 years. Therefore, we determined to aggregate the data to show the average prevalence over the entire period for each state."
          ),
          tags$br(),
          tags$p(
            "These findings go against our initial hypotheses, with the thinking that the different substances would have a strong relationship, as people who have use disorders for one may be more susceptible to use disorders for the others.  "
          )
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
                tags$br(),
                tags$div(class = "alchText",
                          tags$p("This plot displays the alcohol taxation in the US by state, year, and by
                                  three types: liquor, wine, and beer. The states without a tax associated
                                  with the selected alcohol type will be displayed in the sidebar table."),
                          tags$p("An issue with the tax data is that the taxes are applied in gallons of
                                  alcohol. To put that in perspective, a fifth of Smirnoff contains 59.2
                                  fluid ounces of liquid, which converts roughly to 0.46 gallons, so the
                                  consumer impact in this context may appear to be very little."),
                          tags$p("Throughout the last four years, not much has changed. Besides a few changes
                                  in Washington, Rhode Island, and Tennessee, taxation has stayed stagnant.
                                  Another interesting note is that Beer is taxed in every state but the 
                                  same cannot be said for wine and liquor.")
                        )
                )
              )
    ),
    tabPanel("Regression Analysis",
             sidebarLayout(
               sidebarPanel(
                 selectInput("regType",
                             h3("Regression Type"), 
                             choices = c("Difference", "Single Year"), 
                             selected = "Difference")
                 ),
               mainPanel(
                 plotlyOutput("regressionScatter"),
                 tags$br(),
                 verbatimTextOutput(outputId = "alchTaxRegOutput"),
                 tags$br(),
                 tags$div(class = "regResultsText",
                          tags$h3("Results"),
                          tags$p("To analyze the relationship between we performed simple linear regressions.
                                  We performed two regressions, one analyzing the impact a change in taxation
                                  has on the prevalence of alcohol abuse and the other an analysis of tax rates
                                  and their impact on alcohol abuse prevalence. We planned to first do a naive
                                  regression analysis, looking at the relationship between tax rates and 
                                  alcohol abuse prevalence, and then include other features to add noise and
                                  see if the relationship holds."),
                          tags$p("As seen above, both naive regressions displayed that there is no statistically
                                          significant relationship between the two. Both models had negative adjusted
                                          r-squared, meaning that the models explained very little variability. The p-values
                                          for the tax variable in both models are also above the threshold (0.05) for statistical
                                          significance, meaning that we cannot reject the null hypothesis that there is no difference.")
                          ),
                          tags$div(class="regConclusionText",
                                   tags$h3("Conclusion"),
                                   tags$p("In conclusion, if states are looking to combat alcohol abuse prevalence, attempts through taxation
                                          policy is not recommended. One of the main issues is that the data we obtained from government websites 
                                          taxation is on gallons of alcohol, which is an odd unit for taxation. This means that when broken down 
                                          to an individual drink, the additional money needed is somewhat unnoticeable, and that the price is still 
                                          elastic for people suffering from addiction. Instead, reports state that public education, social
                                          marketing, media advocacy, and media literacy are strategies to address the health issue and that community
                                          policing and incentives is a great way to enforce these strategies."),
                                   tags$p("The Seattle sugary beverage tax is a great example of taxation policies attempting to address public health.
                                          Due to the fact it is very new, there are no results on its effectiveness, but the city has reported that it
                                          already has brought in $4 million in tax revenue from it in the first quarter of 2018 alone (Seattle Times).
                                          The article also mentions the negative implications the taxation could have on certain marginalized populations,
                                          which would be another issue for an alcohol taxation policy (you are taking it out on already existing addicts).
                                          Overall, after conducting research on existing information and our data sources, we believe that taxation policies
                                          aimed to reduce alcohol abuse will not be effective."))
                  )
                      )
             )
    )
  )
)

shinyUI(ui)