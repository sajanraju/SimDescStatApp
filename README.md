#  Simple Interactive Descriptive Statistics App

This is a Shiny web application for performing **descriptive statistics and visualizations** on uploaded datasets. Designed to be **user-friendly and interactive**, the app is especially useful for **clinicians, students, and researchers** working with CSV, Excel, or TXT files.

## Features

- 📂 **Upload** `.csv`, `.xlsx`, `.xls`, or `.txt` files
- 📊 **Summary statistics**:
  - For **numeric** variables: Mean, Median, SD, IQR, Min, Max, Skewness, Kurtosis, etc.
  - For **categorical** variables: Counts and Proportions
- 🧪 **Stratify summaries** by an outcome variable and get **p-values**
- 🎻 **Violin plots** for numeric variables split by outcome variable
- 📥 Download summary stats as **CSV** and formatted tables as **HTML**

## How to use it
1. Create and use the standalone application from the script (required Node.js and NPM installation) OR Download from the google drive.
2. Use the shiny app in R/Rstudio

## 1. How to create the standalone App

 **Run the setup in R or RStudio**  
 - Download the contents of **app** folder
 - set the working dir /path/downloaded/folder/app in R
   
   ```r
   source("create_app.R")
   ```
   - Open terminal and launch the bash script
   <pre> ./launch.sh  </pre>
   
   App will run in the new window or in the browser.


## 2. 📦 Requirements to run in R/Rstudio

This app uses the following R packages:

```r
shiny
readr
readxl
gtsummary
ggplot2
dplyr
DT
tools
gt
moments
```
### Install required packages, if you are planning to use the rshiny code (app.R)
```r
install.packages(c("shiny", "readr", "readxl", "gtsummary", "ggplot2", 
                   "dplyr", "DT", "tools", "gt", "moments"))
```
### How to run this in R/Rstudio

```r
# setwd() to where the app.R saved and run 
shiny::runApp("app.R")

# To open in the browser
shinyApp(ui, server, options = list(launch.browser = TRUE))

```

