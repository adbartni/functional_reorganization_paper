library(shiny)
library(shinythemes)
library(shinydashboard)


source('scripts/getData.R')
source('scripts/preprocessing.R')
source('scripts/getRegionConnections.R')
source('scripts/getSelectedPair.R')
source('scripts/getNetworkConnections.R')


sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Proportional Lesional ChaCo",
             tabName = "discon"),
    menuItem("Diffusion FA",
             tabName = "dti"),
    menuItem("Smith Networks",
             tabName = "nemosmith")
  )
)


ui <- dashboardPage(
  skin = "black",
  
  dashboardHeader(title = 
                    "Scatters"),
  sidebar = sidebar,
  
  dashboardBody(
    
    ## Sidebar
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
      ),
      
      tabItem(tabName = "nemosmith",
              fluidPage(

                box(
                  title = "Select which resting state network you would like to examine",
                  selectInput(inputId = "network",
                              label = strong("Smith Network"),
                              choices = smith.networks),
                  selectInput(inputId = "disconSource",
                              label = strong("Proportional ChaCo or Diffusion FA"),
                              choices = c("ChaCo", "Diffusion"))
                ),

                box(plotOutput("smithPlot")),
                box(plotOutput("intraSmithPlot")),
                box(plotOutput("interSmithPlot"))
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
   })
   
   output$dtiPlot <- renderPlot({
     region.dti <- input$region.dti
     plotRegionConnections(region.dti, dti)
   })
   
   output$intraSmithPlot <- renderPlot({
     network <- input$network
     disconSource <- input$disconSource
     plotIntraNetworkSums(network, disconSource)
   })
   
   output$interSmithPlot <- renderPlot({
     network <- input$network
     disconSource <- input$disconSource
     plotInterNetworkSums(network, disconSource)
   })
   
   output$smithPlot <- renderPlot({
     network <- input$network
     disconSource <- input$disconSource
     plotNetworkSums(network, disconSource)
   })
}

## Run the application 
app <- shinyApp(ui = ui, server = server)
