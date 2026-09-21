choose_video_folder <- function() {
  
  command <- paste(
    "powershell.exe",
    "-NoProfile",
    "-Command",
    shQuote(
      "Add-Type -AssemblyName System.Windows.Forms;
       $dialog = New-Object System.Windows.Forms.FolderBrowserDialog;
       $dialog.Description = 'Select your video folder';
       $dialog.ShowNewFolderButton = $false;
       if ($dialog.ShowDialog() -eq 'OK') {
         Write-Output $dialog.SelectedPath
       }"
    )
  )
  
  selected_folder <- system(
    command,
    intern = TRUE
  )
  
  if (length(selected_folder) == 0) {
    return(NULL)
  }
  
  selected_folder
}

# Find FFmpeg ------------------------------------------------------------------

find_ffmpeg <- function() {
  
  # First check whether FFmpeg is already on PATH
  ffmpeg <- Sys.which("ffmpeg")
  
  if (ffmpeg != "") {
    return(ffmpeg)
  }
  
  # Check common local installation location
  common_path <- "C:/ffmpeg/bin/ffmpeg.exe"
  
  if (file.exists(common_path)) {
    return(common_path)
  }
  
  # FFmpeg could not be found
  return(NULL)
}

# Run FFmpeg -------------------------------------------------------------------

run_ffmpeg <- function(args) {
  
  ffmpeg <- find_ffmpeg()
  
  if (is.null(ffmpeg)) {
    stop(
      "FFmpeg could not be found. ",
      "Please install FFmpeg or check the configured path."
    )
  }
  
  system2(
    command = ffmpeg,
    args = args
  )
}