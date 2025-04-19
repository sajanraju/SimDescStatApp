

create_standalone_shiny_app <- function(app_source_path = "app") {
  dir_name <- "simdesc_app"
  dir.create(dir_name, showWarnings = FALSE)
  
  # Paths
  electron_dir <- file.path(dir_name, "electron")
  app_dir <- file.path(dir_name, "app")
  r_portable_dir <- file.path(dir_name, "R-Portable")
  dir.create(electron_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(app_dir, showWarnings = FALSE)
  dir.create(r_portable_dir, showWarnings = FALSE)
  file.rename("app.R", paste0(app_dir, "/app.R"))
  
  
  # Move or copy your app
  file.copy(list.files(app_source_path, full.names = TRUE), app_dir, overwrite = TRUE)
  
  # Write files
  writeLines(
    'const { app, BrowserWindow } = require("electron");
function createWindow () {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: true
    }
  });
  win.loadURL("http://127.0.0.1:8080");
}
app.whenReady().then(createWindow);',
file.path(dir_name, "main.js")
  )
  
  writeLines(
    '<!DOCTYPE html>
<html>
  <head><title>My Shiny App</title></head>
  <body><h1>Loading Shiny App...</h1></body>
</html>',
    file.path(dir_name, "index.html")
  )
  
  writeLines(
    '{
  "name": "shiny-electron-app",
  "version": "1.0.0",
  "main": "main.js",
  "scripts": {
    "start": "electron ."
  },
  "devDependencies": {
    "electron": "^28.0.0"
  }
}',
    file.path(dir_name, "package.json")
  )
  
  writeLines(
    '@echo off
start R-Portable\\bin\\Rscript.exe -e "shiny::runApp(\'app\', port=8080, launch.browser=FALSE)"
timeout /t 3
start electron\\node_modules\\.bin\\electron .',
    file.path(dir_name, "launch.bat")
  )
  Sys.chmod(file.path(dir_name, "launch.bat"), mode = "0755")  
  
  writeLines(
    '#!/bin/bash
kill -9 $(lsof -t -i:8080)
Rscript -e "shiny::runApp(\'app/app.R\', port=8080, launch.browser=FALSE)" &
sleep 3
npx electron main.js',
    file.path(dir_name, "launch.sh")
  )
  Sys.chmod(file.path(dir_name, "launch.sh"), mode = "0755")  
  message("✅ Standalone Shiny app scaffold created in: ", normalizePath(dir_name))
}


# Run the function to generate
create_standalone_shiny_app("app")
