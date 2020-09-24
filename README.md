# INFO 498 D Final Project, Spring 2018

Contributors: Alex Huang, Kevin Lim, Mason Shigenaka, Ryan Hanchett

Our resource can be found [here](https://shigenaka.shinyapps.io/INFO-498-Final-Project/).

## Project Description

What is the purpose of your research project?
* Our research is an exploratory data analysis looking at the trends of alcohol abuse over time, how it impacts different demographic groups, and its relationship to the abuse of other substances, regulation, and tax rates.

What other research has been done in this area? Make sure to include 3+ links to related works.
* Tax rate vs alcohol consumption: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3735171/
* The Potential Benefits of Alcohol Excise Tax Increases in Maryland: https://www.jhsph.edu/research/centers-and-institutes/center-for-adolescent-health/_includes/_pre-redesign/Abell%20tax%20report%2011%2023%2009%20FINALB.pdf
* Successful Pain Management for the Recovering Addicted Patient: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC315480/
* https://www.newyorkfed.org/medialibrary/media/research/current_issues/ci7-11.pdf
  * Article from the Federal Reserve Bank of New York that examines when taxation policy impacts consumer purchasing behavior, their findings state that consumer purchasing behavior only changes when the taxation policy impacts the take home wage

What is the dataset you'll be working with?  Please include background on who collected the data, where you accessed it, and any additional information we should know about how this data came to be.
* https://datafiles.samhsa.gov/study-dataset/national-survey-drug-use-and-health-2015-nsduh-2015-ds0001-nid16894
  * Substance Abuse & Mental Health Data Archive is an agency under the U.S. Department of Health and Human Services serving to improve the behavioral health of the U.S. by reducing the impacts of mental illness and substance abuse. SAMHSA conducted the National Survey on Drug Use and Health in 2015, which includes statistics on the effects of illicit drug use, alcohol, and tobacco on mental health issues for U.S. civilians ages 12 and older. The study also analyzes mental and substance abuse disorders and their treatments. 
* https://www.taxpolicycenter.org/statistics/alcohol-rates-2000-2010-2013-2017
  * The Tax Policy Center provides statistics and analyses on tax policies for the public and the policymakers. The alcohol rates dataset contains taxation data for each state from multiple years (2013-2017, 2010, 2006-2008, 2003-2004, and 2000). The format is that of an excel file and in a table with horizontal breaks for each type of alcohol. A challenge will be wrangling the data into a cleaner format for our models and visualizations.
* http://ghdx.healthdata.org/gbd-2016/data-input-sources?locations=102&components=6&risks=101
  * The Global Health Data Exchange (GHDx) is a data catalogue created by the Institute for Health Metrics and Evaluation with a mission to improve the health of human populations around the world by providing datasets on population health. This data source was introduced to us through this class, which contains data that is easily obtainable in a format that is very simple to clean and manipulate. The Global Burden of Disease Study 2016 dataset will act as a great dataset to examine the outcomes of alcohol abuse by demographic features like age and gender.

Who is your target audience?  Depending on the domain of your data, there may be a variety of audiences interested in using the dataset. You should hone in on one of these audiences.
* The main audience of our project will be policymakers who are looking to combat alcohol abuse, as well as abuse of other substances. The intent of this project is to shine a light on these relationships, which will hopefully lead to smarter policies targeting the issues as a whole rather than labeling the individual as the problem who has isolated, self-inflicted issues.

What should your audience learn from your resource? Please list out at least 3 specific questions that your project will answer for your audience.
1. Is there a correlation between alcohol tax rates and alcohol consumption?
  * Is there a correlation between alcohol taxation policy and other substance abuse rates (taking into account the legal status of said substances as well)?
2. Is there a relationship between alcohol abuse and other substance abuse prevalences?
3. How has the privatization in Washington state impacted alcohol abuse prevalence?
 

## Technical Description
What will be the format of your final product (Shiny app, HTML page or slideshow compiled with KnitR, etc.)?
* Our final product will be a Shiny app.

Do you anticipate any specific data collection / data management challenges?
* Since we are using multiple data sources to make comparisons, we will need to clean and modify the data sets so that we can join the datasets easily.
* Based on our initial data collection, we have found a few surveys. To use them will require us to study the codebooks and understand the questions asked, and how we must code them to explore our domain and attempt to answer our questions

What new technical skills will need to learn in order to complete your project?
* Some of us have never built a Shiny app, and others did so in INFO 201 awhile back. We will need to learn or re-learn the syntax of Shiny, which will be an interesting challenge for this project.
* We hope to use a few regression and statistical techniques to examine significance and relationships. Some of us have experience using these tools while others do not, so it will be a great opportunity for those unfamiliar to learn how R can be used for data modeling and relationship analysis.

What major challenges do you anticipate?
* A concern for any research project is the data. Getting our datasets into a clean, readable format will be difficult, but data cleaning and manipulation is a significant part of data analysis, so it will require a lot of work to get the data into a format we can use for statistical analysis and visualization. In addition, some questions may require information from multiple datasets in order to formulate an answer. This poses a challenge to identify and use the right data and combining it with that of other datasets to display an intriguing visualization.
* Another challenge is being able to create our Shiny application. Learning a new language is common in Informatics classes, but it is something that we must anticipate and prepare for. We will need to review Shiny on our own and learn fast, as we only have around three to four weeks to complete this project. Adding interactivity to data visualizations is a difficult process as well, so we must be willing to invest the time to learn how to create them in Shiny, and debug problems that we inevitably run into.
* It is important to ensure that our research is original. If there has already been extensive research into answering a certain question, we must figure out what new analysis we can bring to the table or how can we either confirm or provide an alternative explanation for any trends found.

