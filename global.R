# global.R
library(shiny)
library(data.table)
library(shinyjs)

# Shared reactiveValues object for data across sessions
shared_data <- reactiveValues(data = data.table(
  Name = character(),
  Number = integer()
))
