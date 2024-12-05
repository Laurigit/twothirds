# server.R
library(shiny)

shinyServer(function(input, output, session) {
  
  # Admin control: reactive values for visibility of table and closest user text
  table_visibility <- reactiveVal(FALSE)  # Start with the table hidden
  closest_user_visibility <- reactiveVal(FALSE)  # Start with the closest user text hidden
  
  # Reactive value to check if the user is an admin
  is_admin <- reactive({
    query <- parseQueryString(session$clientData$url_search)
    !is.null(query$u) && query$u == "samuela"
  })
  
  # Observe the toggle table button (only available for admin)
  observeEvent(input$toggle_table, {
    if (is_admin()) {
      table_visibility(!table_visibility())
      closest_user_visibility(!closest_user_visibility())
    }
  })
  
  # Observe the submit button
  observeEvent(input$submit, {
    # Validate input
    req(input$name)
    req(input$number)
    
    # Append new data to the shared reactiveValues object
    isolate({
      new_entry <- data.table(
        Name = input$name,
        Number = as.integer(input$number)
      )
      shared_data$data <- rbind(shared_data$data, new_entry)
    })
    
    # Disable the submit button and display user info
    updateActionButton(session, "submit", label = "Submitted", disabled = TRUE)
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
      paste0(
        "Closest to 2/3 of the average: Name = ", user$Name, 
        ", Number = ", user$Number
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
})
