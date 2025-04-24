#!/bin/bash

# Detect OS and install Node.js if not available
if ! command -v node &> /dev/null; then
  echo "📦 Node.js not found. Installing..."

  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if ! command -v brew &> /dev/null; then
      echo "❌ Homebrew not found. Please install Homebrew first: https://brew.sh"
      exit 1
    fi
    brew install node
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    sudo apt update
    sudo apt install -y nodejs npm
  else
    echo "❌ Unsupported OS. Please install Node.js manually."
    exit 1
  fi
else
  echo "✅ Node.js already installed."
fi

# Initialize Node project if package.json not found
if [ ! -f "package.json" ]; then
  echo "📦 Initializing Node.js project..."
  npm init -y
fi


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
