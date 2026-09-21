library(shiny)

ui <- fluidPage(
  
  h2("Video Converter"),
  
  actionButton(
    "browse",
    "Select Video Folder"
  ),
  
  br(),
  br(),
  
  wellPanel(
    textOutput("folder_path")
  ),
  
  br(),
  
  h4("Videos found:"),
  
  textOutput("video_count"),
  
  verbatimTextOutput("video_list"),
  
  br(),
  
  h4("Conversion options:"),
  
  checkboxGroupInput(
    "input_formats",
    "Convert files of type:",
    choices = NULL
  ),
  
  selectInput(
    "output_format",
    "Output format:",
    choices = c(
      "MP4" = "mp4",
      "MOV" = "mov",
      "MKV" = "mkv"
    ),
    selected = "mp4"
  ),
  
  selectInput(
    "quality",
    "Quality:",
    choices = c(
      "High quality" = "high",
      "Medium quality" = "medium",
      "Smaller file" = "small"
    ),
    selected = "medium"
  ),
  
  br(),
  
  actionButton(
    "convert",
    "Convert Videos"
  )
)