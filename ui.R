# ui.R
library(shiny)
library(shinyjs)

shinyUI(fluidPage(
  useShinyjs(),
  
  titlePanel("Shiny App with Shared Data"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("name", "Enter your name:"),
      numericInput("number", "Enter a number (0-100):", 50, min = 0, max = 100, step = 1),
      actionButton("submit", "Submit"),
      actionButton("reset", "Start Over"),
      
      # Admin controls (rendered only for admins)
      uiOutput("admin_controls")
    ),
    
    mainPanel(
      tableOutput("data_table"),
      textOutput("user_info"),
      textOutput("closest_user")
    )
  )
))
