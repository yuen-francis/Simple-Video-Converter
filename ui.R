library(shiny)

ui <- fluidPage(
  
  h2("Video Converter"),
  
  actionButton(
    "browse",
    "Browse"
  ),
  
  br(),
  br(),
  
  textOutput("folder_path"),
  
  br(),
  
  h4("Videos found:"),
  
  textOutput("video_count"),
  
  verbatimTextOutput("video_list"),
  
  br(),
  
  h4("Conversion options:"),
  
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
  
  h4("FFmpeg commands:"),
  
  verbatimTextOutput("ffmpeg_commands"),
  
  br(),
  
  actionButton(
    "convert",
    "Convert Videos"
  )
)