library(shiny)
library(shinythemes)
library(shinydashboard)
library(ggplot2)

source('scripts/getData.R')
source('scripts/preprocessing.R')
source('scripts/getRegionConnections.R')
source('scripts/getSelectedPair.R')

sidebar <- dashboardSidebar(
  
  sidebarMenu(
    menuItem("Absolute Lesional Discon",
             tabName = "discon"),
    menuItem("DTI",
             tabName = "dti")
  )
)


ui <- dashboardPage(
  skin = "black",
  
  dashboardHeader(title = 
                    "Scatters"),
  sidebar = sidebar,
  
  dashboardBody(
    
    tabItems(
      tabItem(tabName = "discon",
              fluidPage(
                
                box(
                  title = "Select which region you would like to examine",
                  selectInput(inputId = "region.discon",
                              label = strong("Region"),
                              choices = regions)
                ),
                
                plotOutput("disconPlot")
              )
        ),
      
      tabItem(tabName = "dti",
              fluidPage(
                
                box(
                  title = "Select which region you would like to examine",
                  selectInput(inputId = "region.dti",
                              label = strong("Region"),
                              choices = regions)
                ),
                
                plotOutput("dtiPlot")
              )
      )
    )
  )
  
)

## Define server logic required to draw a scatterplot
server <- function(input, output) {
  
   output$disconPlot <- renderPlot({
     
     region.discon <- input$region.discon
     plotRegionConnections(region.discon, discon)

   },
   height = 720, 
   width = 1300)
   
   output$dtiPlot <- renderPlot({
     
     region.dti <- input$region.dti
     plotRegionConnections(region.dti, dti)
     
   },
   height = 720, 
   width = 1300)
}

## Run the application 
shinyApp(ui = ui, server = server)
