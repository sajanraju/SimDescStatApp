#!/bin/bash

# Check for required files before initialization
if [ ! -f "main.js" ] && [ ! -d "app" ] ; then
  echo "🔧 Initializing SimDescStatApp ..."
  Rscript create_app.R

  echo "📦 Installing required R packages..."
  Rscript -e 'packages <- c("shinyBS", "gt", "shinyWidgets", "bslib", "dplyr", "ggplot2", "DT", "gtsummary", "readxl", "readr", "shiny"); new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]; if(length(new_packages)) install.packages(new_packages, repos = "https://cloud.r-project.org")'

  echo "✅ SimDescStatApp structure initialized successfully. You can run the launch.sh now"
else
  echo "✅ SimDescStatApp structure already initialized. You can run the launch.sh now"
fi

