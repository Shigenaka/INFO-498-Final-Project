library(shiny)
library(plotly)
library(rsconnect)
library(DT)
library(tidyr)
library(dplyr)

# Read in GBD data
gbd_data <- read.csv("data/raw/GBD.csv")

# Read in drug abuse data
state_drug_use <- read.csv("data/prepped/state_drug_use_data.csv")
washington_alc_opioid <- read.csv("data/prepped/washington_opioid_alc_analysis.csv")

# Read in WA/US alcohol prevalence data
us_wa_alcohol_prevalence_data <- read.csv("data/prepped/prepped-us-wa-alcohol-prevalence.csv")

#load alc vs taxrate data
state_alc_taxrate <-
  read.csv("data/prepped/alcohol_and_tax_rate_state_data.csv")
colnames(state_alc_taxrate)[9:10] <- c("strata", "by")
state_alc_taxrate <- na.omit(state_alc_taxrate)
state_alc_taxrate <-
  filter(
    state_alc_taxrate,
    DataValueType != "Age-adjusted Prevalence",
    DataValueType != "Age-adjusted Mean",
    DataValueType != "Age-adjusted Rate"
  )

tax_data <- read.csv("data/prepped/prepped-tax-data.csv") %>%
  mutate(state = as.character(state)) %>%
  filter(state != "U.S. Median")

diff_tax_alch_data <- read.csv("data/prepped/diff-alch-tax.csv")
reg_single_year_data <- read.csv("data/prepped/15-16-reg-data.csv")

diff.fit <- lm(change_alch ~ change_tax, data = diff_tax_alch_data)
singleYear.fit <- lm(Number ~ total_tax, data = reg_single_year_data)
#load

# Read in US alcohol abuse counts and proportions

over_11_count <-
  read.csv("data/prepped/prepped-us-alcohol-abuse-11-count.csv")
over_11_prop <-
  read.csv("data/prepped/prepped-us-alcohol-abuse-11-prop.csv")
over_17_count <-
  read.csv("data/prepped/prepped-us-alcohol-abuse-17-count.csv")
over_17_prop <-
  read.csv("data/prepped/prepped-us-alcohol-abuse-17-prop.csv")
over_25_count <-
  read.csv("data/prepped/prepped-us-alcohol-abuse-25-count.csv")
over_25_prop <-
  read.csv("data/prepped/prepped-us-alcohol-abuse-25-prop.csv")


# Define server logic required to draw a histogram
server <- shinyServer(function(input, output, session) {
  observeEvent(
    input$Question,
    updateSliderInput(
      session,
      "year",
      "year",
      min = min(state_alc_taxrate$year[state_alc_taxrate$Question ==
                                         input$Question]),
      max = max(state_alc_taxrate$year[state_alc_taxrate$Question ==
                                         input$Question]),
      value = c(
        min(state_alc_taxrate$year[state_alc_taxrate$Question == input$Question]),
        max(state_alc_taxrate$year[state_alc_taxrate$Question ==
                                     input$Question])
      )
    )
  )
  
  observeEvent(
    input$year,
    updateSelectInput(session, "strata", "strata",
                      choices = state_alc_taxrate$strata[#state_alc_taxrate$year%in%input$year &
                        state_alc_taxrate$Question == input$Question])
  )
  
  observeEvent(
    input$strata,
    updateSelectInput(session, "by", "by",
                      choices = state_alc_taxrate$by[state_alc_taxrate$strata ==
                                                       input$strata &
                                                       state_alc_taxrate$year %in%
                                                       input$year &
                                                       state_alc_taxrate$Question ==
                                                       input$Question])
  )
  
  observeEvent(
    input$by,
    updateSelectInput(session, "type", "type",
                      choices = state_alc_taxrate$type[state_alc_taxrate$by ==
                                                         input$by &
                                                         state_alc_taxrate$strata ==
                                                         input$strata &
                                                         state_alc_taxrate$year %in%
                                                         input$year &
                                                         state_alc_taxrate$Question ==
                                                         input$Question])
  )
  
  output$state_alc_taxrate_plot <- renderPlotly({
    filtered_state_alc_taxrate <- filter(
      state_alc_taxrate,
      Question == input$Question,
      year %in% input$year,
      type == input$type,
      strata == input$strata,
      by == input$by
    )
    
    graph <- plot_ly(
      data = filtered_state_alc_taxrate,
      x = ~ DataValueAlt,
      y = ~ tax_rate,
      type = "scatter",
      color = ~ year,
      mode = 'markers',
      hoverinfo = 'text',
      text = ~ paste(
        'State: ',
        state,
        '</br> Year: ',
        year,
        '</br> ID: ',
        by,
        '</br> Tax Rate',
        tax_rate,
        '</br> X value',
        DataValueAlt
      )
    ) %>%
      layout(
        title = "Alcohol vs Tax Rates",
        xaxis = list (title = input$Question),
        yaxis = list(title = "Tax Rate")
      )
    graph <- add_trace(graph,
                       x = ~ DataValueAlt,
                       y = fitted(lm(
                         tax_rate ~ DataValueAlt, filtered_state_alc_taxrate
                       )),
                       mode = "lines")
  })
  
  output$alcoholUseDisorderPlot <- renderPlotly({
    # target_data <- over_11_count
    
    if (input$alcoholUseDisorderAgeFilter == "12 and Older" &
        input$alcoholUseDisorderTypeFilter == "Count") {
      target_data <- over_11_count
      title.label <-
        "Number of Individuals Age 12 and Older with Alcohol Use Disorder"
      y.label <- "Number of Individuals"
    } else if (input$alcoholUseDisorderAgeFilter == "12 and Older" &
               input$alcoholUseDisorderTypeFilter == "Proportion") {
      target_data <- over_11_prop
      title.label <-
        "Proportion of Individuals Age 12 and Older with Alcohol Use Disorder"
      y.label <- "Proportion of Individuals"
    } else if (input$alcoholUseDisorderAgeFilter == "18 and Older" &
               input$alcoholUseDisorderTypeFilter == "Count") {
      target_data <- over_17_count
      title.label <-
        "Number of Individuals Age 18 and Older with Alcohol Use Disorder"
      y.label <- "Number of Individuals"
    } else if (input$alcoholUseDisorderAgeFilter == "18 and Older" &
               input$alcoholUseDisorderTypeFilter == "Proportion") {
      target_data <- over_17_prop
      title.label <-
        "Proportion of Individuals Age 18 and Older with Alcohol Use Disorder"
      y.label <- "Proportion of Individuals"
    } else if (input$alcoholUseDisorderAgeFilter == "26 and Older" &
               input$alcoholUseDisorderTypeFilter == "Count") {
      target_data <- over_25_count
      title.label <-
        "Number of Individuals Age 26 and Older with Alcohol Use Disorder"
      y.label <- "Number of Individuals"
    } else if (input$alcoholUseDisorderAgeFilter == "26 and Older" &
               input$alcoholUseDisorderTypeFilter == "Proportion") {
      target_data <- over_25_prop
      title.label <-
        "Proportion of Individuals Age 26 and Older with Alcohol Use Disorder"
      y.label <- "Proportion of Individuals"
    }
    
    graph <-
      plot_ly(
        data = target_data,
        x = ~ State,
        y = ~ Number,
        type = "bar"
      ) %>%
      layout(title = title.label,
             yaxis = list(title = y.label))
    
  })
  
  output$alcoholDependenceAbusePlot <- renderPlotly({
    
    if (input$yearFilter == 10) {
      us_wa_alcohol_prevalence_data <- filter(us_wa_alcohol_prevalence_data, Year == "2010")
    } else if (input$yearFilter == 11) {
      us_wa_alcohol_prevalence_data <- filter(us_wa_alcohol_prevalence_data, Year == "2010" | Year == "2011")
    } else if (input$yearFilter == 12) {
      us_wa_alcohol_prevalence_data <- filter(us_wa_alcohol_prevalence_data, Year == "2010" | Year == "2011" |
                                                Year == "2012")
    } else if (input$yearFilter == 13) {
      us_wa_alcohol_prevalence_data <- filter(us_wa_alcohol_prevalence_data, Year == "2010" | Year == "2011" |
                                                Year == "2012" | Year == "2013")
    } else if (input$yearFilter == 14) {
      us_wa_alcohol_prevalence_data <- filter(us_wa_alcohol_prevalence_data, Year == "2010" | Year == "2011" |
                                                Year == "2012" | Year == "2013" | Year == "2014")
    }
    
    if (input$alcoholOutcomeFilter == "Alcohol Dependence in the Past Year") {
      WA_target_data <- filter(us_wa_alcohol_prevalence_data, outcome == "Alcohol Dependence in the Past Year",
                               geography == "Washington")
      US_target_data <- filter(us_wa_alcohol_prevalence_data, outcome == "Alcohol Dependence in the Past Year",
                               geography == "United States")
    } else if (input$alcoholOutcomeFilter == "Alcohol Dependence or Abuse in the Past Year") {
      WA_target_data <- filter(us_wa_alcohol_prevalence_data, outcome == "Alcohol Dependence or Abuse in the Past Year",
                               geography == "Washington")
      US_target_data <- filter(us_wa_alcohol_prevalence_data, outcome == "Alcohol Dependence or Abuse in the Past Year",
                               geography == "United States")
    } else if (input$alcoholOutcomeFilter == "Alcohol Use in the Past Month") {
      WA_target_data <- filter(us_wa_alcohol_prevalence_data, outcome == "Alcohol Use in the Past Month",
                               geography == "Washington")
      US_target_data <- filter(us_wa_alcohol_prevalence_data, outcome == "Alcohol Use in the Past Month",
                               geography == "United States")
    }
    
    graph <- plot_ly(data = WA_target_data, x = ~Year, y = ~Prevalence, 
                     type = "scatter", mode = "lines+markers", name = "Washington") %>%
      add_trace(data = US_target_data, x = ~Year, y = ~Prevalence,
                mode = "lines+markers", name = "United States") %>%
      layout(title = paste0(input$alcoholOutcomeFilter, " in the 2010s")
      )
  })
  
  output$alchPlot <- renderPlotly({
    plot_data <- tax_data %>%
      filter(type == input$alchType &
               year == input$yearAlch & tax_rate > 0)
    
    y <- list(title = "State"
              , tickfont = list(size = 7))
    
    x <- list(title = "Tax Rate ($/Gallon)")
    plot_ly(plot_data,
            x =  ~ tax_rate,
            y =  ~ state,
            type = "bar") %>%
      layout(yaxis = y, xaxis = x)
  })
  
  state_opioid_amphetamine_use <- reactive({
    if (input$causeOpioidFilter == 'Opioid') {
      selectedDrugs <- c("Opioid use disorders")
    } else if (input$causeOpioidFilter == 'Amphetamine') {
      selectedDrugs <- c("Amphetamine use disorders")
    } else {
      opioid <- state_drug_use %>%
        select(location, cause, val = Number, code) %>%
        filter(cause %in% 'Opioid use disorders') %>%
        group_by(code) %>%
        summarise(val = mean(val)) %>%
        mutate(hover = paste(
          code,
          "<br>",
          paste("Percentage of", input$causeOpioidFilter, 'Use', val)
        ))
      return(opioid)
    }
    
    
    
    opioid <- state_drug_use %>%
      select(location, cause, val, code) %>%
      filter(cause %in% selectedDrugs) %>%
      group_by(cause, code) %>%
      summarise(val = mean(val) * 10) %>%
      mutate(hover = paste(
        code,
        "<br>",
        paste("Percentage of", input$causeOpioidFilter, 'Use'),
        val
      ))
    return(opioid)
  })
  
  # give state boundaries a white border
  l <- reactive({
    list(color = toRGB("white"), width = 2)
  })
  
  # specify some map projection/options
  g <- reactive({
    list(
      scope = 'usa',
      projection = list(type = 'albers usa'),
      showlakes = TRUE,
      lakecolor = toRGB('white')
    )
  })
  
  output$amphetamine_alc <- renderPlotly({
    x <- list(title = "Amphetamine Use Disorder Prevalence")
    
    y <- list(title = "Alcohol Use Disorder Prevalence")
    
    
    opioid_alc <- state_drug_use %>%
      select(location, cause, val, code, Number) %>%
      filter(cause == "Amphetamine use disorders") %>%
      group_by(location, cause, code) %>%
      summarise(val = mean(val), Number = mean(Number))
    
    plot_ly(data = opioid_alc,
            x = ~ val,
            y = ~ Number) %>%
      layout(xaxis = x,
             yaxis = y,
             title = 'Amphetamine vs Alcohol Use Disorders in USA by State')
    })
  
  output$opioid_alc <- renderPlotly({
    x <- list(title = "Opioid Use Disorder Prevalence")
    y <- list(title = "Alcohol Use Disorder Prevalence")
    
    
    opioid_alc <- state_drug_use %>%
      select(location, cause, val, code, Number) %>%
      filter(cause == "Opioid use disorders") %>%
      group_by(location, cause, code) %>%
      summarise(val = mean(val), Number = mean(Number))
    
    plot_ly(data = opioid_alc,
            x = ~ val,
            y = ~ Number) %>%
      layout(xaxis = x,
             yaxis = y,
             title = 'Opioid vs Alcohol Use Disorders in USA by State')
  })
  
  output$washington_opioid <- renderPlotly({
    washington_alc_opioid
    
    plot_ly(washington_alc_opioid, x = ~val, y = ~alc_prev, type = 'scatter', mode = 'lines')
    
    
    
  })
  
  output$opioid_amphetamine <- renderPlotly({
    x <- list(title = "Opioid Use Disorder Prevalence")
    y <- list(title = "Amphetamine Use Disorder Prevalence")
    
    
    amp <- state_drug_use %>%
      select(code, cause, val) %>%
      filter(cause == 'Amphetamine use disorders') %>%
      group_by(code, cause) %>%
      summarise(val = mean(val))
    
    amphetamine_opioid <- state_drug_use %>%
      select(code, cause, val) %>%
      filter(cause == 'Opioid use disorders')%>%
      group_by(code, cause) %>%
      summarise(val = mean(val))
    
    amphetamine_opioid <- left_join(amphetamine_opioid, amp, by='code')
    
    ggplot(amphetamine_opioid, aes(x = val.x, y = val.y)) + geom_point() + geom_smooth()
    plot_ly(data = amphetamine_opioid,
            x = ~ val.x,
            y = ~ val.y) %>%
      layout(xaxis = x,
             yaxis = y,
             title = 'Opioid vs Amphetamine Use Disorders in USA by State')
  })
  
  
  
  output$drugPlot <- renderPlotly({
    d <- state_opioid_amphetamine_use()
    plot_geo(data = d, locationmode = 'USA-states') %>%
      add_trace(
        data = d,
        z = ~ val,
        text = ~ hover,
        locations = ~ code,
        color = ~ val,
        colors = 'Purples'
      ) %>%
      colorbar(
        title = "Percentage of Substance Use",
        y = 3,
        ypad = 25,
        x = .90
      ) %>%
      layout(
        title = paste(
          'US Average',
          input$causeOpioidFilter,
          'Use by State and Year'
        ),
        geo = g()
      )
  })
  
  output$statesNoTax <- DT::renderDataTable(DT::datatable(
    tax_data %>%
      filter(type == input$alchType &
               year == input$yearAlch & tax_rate == 0) %>%
      select(state),
    options = list(searching = FALSE, paging = FALSE)
  ))
  
  output$regressionScatter <- renderPlotly({
    if (input$regType == "Difference") {
      x <- list(title = "Change in Tax Rate ($/Gallon)")
      y <- list(title = "Change in Alcohol Abuse Prevalence (%)")
      plot_ly(
        diff_tax_alch_data,
        x =  ~ change_tax,
        y =  ~ (change_alch * 100),
        type = "scatter",
        mode = 'markers',
        hoverinfo = 'text',
        text =  ~ paste(
          'State: ',
          state,
          '</br>',
          '</br> Year 0: ',
          year0,
          '</br> Year 1: ',
          year1
        )
      ) %>%
        layout(yaxis = y, xaxis = x)
    } else {
      x <- list(title = "Total Tax Rate ($/Gallon)")
      y <- list(title = "Alcohol Abuse Prevalence (%)")
      plot_ly(
        reg_single_year_data,
        x =  ~ total_tax,
        y =  ~ (Number * 100),
        type = "scatter",
        mode = 'markers',
        hoverinfo = 'text',
        text =  ~ paste('State: ', State)
      ) %>%
        layout(yaxis = y, xaxis = x)
    }
  })
  
  output$alchTaxRegOutput <- renderPrint(if (input$regType == "Difference") {
    summary(diff.fit)
  } else {
    summary(singleYear.fit)
  })
  
  
})

shinyServer(server)
