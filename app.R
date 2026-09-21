library(shiny)

source("ui.R")
source("server.R")
source("common.R")

shinyApp(
  ui = ui,
  server = server
)