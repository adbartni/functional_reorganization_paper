library(shiny)
library(shinythemes)
library(ggplot2)

source('scripts/getData.R')
source('scripts/preprocessing.R')
source('scripts/getRegionConnections.R')
source('scripts/getSelectedPair.R')

## Define UI for application
ui <- fluidPage(
		theme = shinytheme("flatly"),
   
   ## Application title
   titlePanel("Testing"),
     
     ## Show scatter plot
     mainPanel(
       
       ## Lists to select regions to pair up
       selectInput(inputId = "region1",
                   label = strong("Region 1"),
                   choices = regions),
       
       plotOutput("distPlot")
     )
)

## Define server logic required to draw a scatterplot
server <- function(input, output) {
  
   output$distPlot <- renderPlot({
     
     region <- input$region1

     plotRegionConnections(region)

   },
   height = 720, 
   width = 1300)
}

## Run the application 
shinyApp(ui = ui, server = server)
