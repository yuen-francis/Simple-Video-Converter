library(shiny)

source("common.R")

server <- function(input, output, session) {
  
  folder <- reactiveVal(NULL)
  
  # Browse for folder
  observeEvent(input$browse, {
    
    selected_folder <- choose_video_folder()
    
    if (!is.null(selected_folder)) {
      folder(selected_folder)
    }
  })
  
  # Display selected folder
  output$folder_path <- renderText({
    
    req(folder())
    
    paste("Selected folder:", folder())
  })
  
  # Find video files
  videos <- reactive({
    
    req(folder())
    
    list.files(
      path = folder(),
      pattern = "\\.(avi|mp4|mov|mkv|wmv|flv|webm|m4v|mpeg|mpg|3gp)$",
      ignore.case = TRUE,
      full.names = TRUE
    )
  })
  
  # Display number of videos
  output$video_count <- renderText({
    
    req(folder())
    
    video_files <- videos()
    
    paste(
      "Number of videos:",
      length(video_files)
    )
  })
  
  # Display video list
  output$video_list <- renderText({
    
    req(folder())
    
    video_files <- videos()
    
    if (length(video_files) == 0) {
      return("No video files found.")
    }
    
    paste(
      basename(video_files),
      collapse = "\n"
    )
  })
  
  # Generate FFmpeg commands
  ffmpeg_commands <- reactive({
    
    req(folder())
    
    video_files <- videos()
    
    if (length(video_files) == 0) {
      return(character(0))
    }
    
    output_format <- input$output_format
    quality <- input$quality
    
    converted_folder <- file.path(
      folder(),
      "converted_videos"
    )
    
    crf <- switch(
      quality,
      high = 18,
      medium = 23,
      small = 28
    )
    
    commands <- character(length(video_files))
    
    for (i in seq_along(video_files)) {
      
      input_file <- video_files[i]
      
      output_name <- paste0(
        tools::file_path_sans_ext(
          basename(input_file)
        ),
        ".",
        output_format
      )
      
      output_file <- file.path(
        converted_folder,
        output_name
      )
      
      commands[i] <- paste(
        "-i",
        shQuote(input_file),
        "-crf",
        crf,
        shQuote(output_file)
      )
    }
    
    commands
  })
  
  # Display FFmpeg commands
  output$ffmpeg_commands <- renderText({
    
    commands <- ffmpeg_commands()
    
    if (length(commands) == 0) {
      return("No videos to convert.")
    }
    
    paste(
      paste("ffmpeg", commands),
      collapse = "\n\n"
    )
  })
  
  # Convert videos
  observeEvent(input$convert, {
    
    req(folder())
    
    video_files <- videos()
    
    if (length(video_files) == 0) {
      
      showNotification(
        "No video files found.",
        type = "warning"
      )
      
      return()
    }
    
    # Find FFmpeg
    ffmpeg <- find_ffmpeg()
    
    if (is.null(ffmpeg)) {
      
      showNotification(
        "FFmpeg could not be found. Please check your FFmpeg installation.",
        type = "error",
        duration = NULL
      )
      
      return()
    }
    
    # Create output folder
    converted_folder <- file.path(
      folder(),
      "converted_videos"
    )
    
    if (!dir.exists(converted_folder)) {
      dir.create(converted_folder)
    }
    
    commands <- ffmpeg_commands()
    
    # Show conversion notification
    showNotification(
      paste(
        "Converting",
        length(video_files),
        "video(s)..."
      ),
      type = "message",
      duration = NULL,
      id = "conversion_progress"
    )
    
    # Track successful and failed conversions
    successful <- 0
    failed <- 0
    
    # Run each FFmpeg command
    for (command in commands) {
      
      result <- system2(
        ffmpeg,
        args = sub("^ffmpeg ", "", command),
        stdout = TRUE,
        stderr = TRUE
      )
      
      status <- attr(
        result,
        "status",
        exact = TRUE
      )
      
      if (is.null(status) || status == 0) {
        successful <- successful + 1
      } else {
        failed <- failed + 1
      }
    }
    
    # Remove conversion notification
    removeNotification(
      id = "conversion_progress"
    )
    
    # Display final result
    if (failed == 0) {
      
      showNotification(
        paste(
          "Success!",
          successful,
          "video(s) converted successfully.",
          "Files saved to the converted_videos folder."
        ),
        type = "message",
        duration = 10
      )
      
    } else if (successful > 0) {
      
      showNotification(
        paste(
          "Conversion finished with warnings.",
          successful,
          "video(s) converted successfully and",
          failed,
          "video(s) failed."
        ),
        type = "warning",
        duration = NULL
      )
      
    } else {
      
      showNotification(
        paste(
          "Conversion failed.",
          "None of the",
          length(video_files),
          "video(s) could be converted."
        ),
        type = "error",
        duration = NULL
      )
    }
  })
}