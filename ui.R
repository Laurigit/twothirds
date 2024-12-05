# ui.R
library(shiny)

shinyUI(fluidPage(
  titlePanel("User Input App"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("name", "Enter your name:", value = ""),
      numericInput(
        "number", 
        "Enter a whole number (0-100):", 
        value = 0, 
        min = 0, 
        max = 100
      ),
      actionButton("submit", "Submit"),
      hr(),
      h4("Admin Controls"),
      uiOutput("admin_controls")  # Placeholder for admin controls
    ),
    
    mainPanel(
      h3("Submitted Data"),
      tableOutput("data_table"),
      h3("Closest User"),
      textOutput("closest_user"),
      hr(),
      h4("Your Input"),
      textOutput("user_info")
    )
  )
))
