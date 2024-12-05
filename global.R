# global.R
library(shiny)
library(data.table)
library(shinyjs)


# Global shared data stored in a reactiveValues object
shared_data <- reactiveValues(data = data.table(Name = character(0), Number = numeric(0)))