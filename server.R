# server.R
library(shiny)
library(shinyjs)  # For client-side interactivity
library(data.table)  # For handling data.table

# Global shared data stored in a reactiveValues object
shared_data <- reactiveValues(data = data.table(Name = character(0), Number = numeric(0)))

shinyServer(function(input, output, session) {
  
  # Admin control: reactive values for visibility of table and closest user text
  table_visibility <- reactiveVal(FALSE)  # Start with the table hidden
  closest_user_visibility <- reactiveVal(FALSE)  # Start with the closest user text hidden
  reset_visibility <- reactiveVal(FALSE)  # Start with the reset button hidden
  
  # Reactive value to check if the user is an admin
  is_admin <- reactive({
    query <- parseQueryString(session$clientData$url_search)
    !is.null(query$u) && query$u == "samuela"
  })
  
  # Initialize shinyjs
  useShinyjs()
  
  # Observe the submit button
  observeEvent(input$submit, {
    # Validate input
    req(input$name)
    req(input$number)
    
    # Append new data to the shared reactiveValues object (global data)
    isolate({
      new_entry <- data.table(
        Name = input$name,
        Number = as.integer(input$number)
      )
      
      # Append the new entry to shared data
      shared_data$data <- rbind(shared_data$data, new_entry)
    })
    
    # Disable the submit button using shinyjs
    shinyjs::disable("submit")  # Disable the submit button after submission
    
    # Display user info
    output$user_info <- renderText({
      paste0("Thank you, ", input$name, "! You entered: ", input$number)
    })
  })
  
  # Calculate 2/3 of the average and find the closest user
  closest_user <- reactive({
    data <- shared_data$data
    if (nrow(data) > 0) {
      # Calculate the 2/3 average
      average <- mean(data$Number)
      target_value <- (2 / 3) * average
      
      # Find the closest number to the target value
      data[which.min(abs(data$Number - target_value))]
    } else {
      data.table(Name = "N/A", Number = NA)
    }
  })
  
  # Calculate average of all inputs
  average_input <- reactive({
    data <- shared_data$data
    if (nrow(data) > 0) {
      mean(data$Number)
    } else {
      0  # Default value if no data
    }
  })
  
  # Conditionally display the results table
  output$data_table <- renderTable({
    if (table_visibility()) {
      shared_data$data
    } else {
      NULL
    }
  })
  
  # Conditionally display the closest user's information
  output$closest_user <- renderText({
    if (closest_user_visibility()) {
      user <- closest_user()
      avg <- average_input()
      paste0(
        "Closest to 2/3 of the average: Name = ", user$Name, 
        ", Number = ", user$Number, "\n",
        "Average of inputs: ", round(avg  * 2 / 3, 2)
      )
    } else {
      NULL
    }
  })
  
  # Conditionally render the admin button
  output$admin_controls <- renderUI({
    if (is_admin()) {
      actionButton("toggle_table", "Hide/Show Results Table")
    }
  })
  
  # Observe the "Start Over" button (reset the data)
  observeEvent(input$reset, {
    # Only allow reset if the user is an admin
    if (is_admin()) {
      # Reset the data to empty data.table
      shared_data$data <- data.table(Name = character(0), Number = numeric(0))
      
      # Optionally re-enable the submit button if needed
      shinyjs::enable("submit")
      
      # Reset the visibility states as well if desired
      table_visibility(FALSE)
      closest_user_visibility(FALSE)
    }
  })
  
  # Disable the "Start Over" button if the user is not an admin
  observe({
    if (!is_admin()) {
      shinyjs::disable("reset")  # Disable button for non-admins
    }
  })
  
  # Observe the toggle_table button to show/hide the results table
  observeEvent(input$toggle_table, {
    # Toggle visibility of the table and the closest user text
    table_visibility(!table_visibility())
    closest_user_visibility(!closest_user_visibility())
  })
  
})
