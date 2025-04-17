library(shiny)
library(readr)
library(readxl)
library(gtsummary)
library(DT)
library(ggplot2)
library(dplyr)
library(tools)
library(bslib)
library(shinyWidgets)
library(gt)
library(shinyBS)

# Define the UI
ui <- fluidPage(
  theme = bs_theme(version = 5, bootswatch = "minty"),
  
  # Center the title using a CSS class
  tags$head(
    tags$style(HTML("
      .centered-title {
        text-align: center;
        font-size: 24px;
        margin-bottom: 20px;
      }
    "))
  ),
  
  tags$div(class = "centered-title", 
           titlePanel("\U0001F4C8 Interactive Descriptive Statistics")),
  
  tags$div(style = "text-align: center; font-size: 20px; font-style: italic;",
           "Author: Sajan Raju"),
  
  br(),
  
  sidebarLayout(
    sidebarPanel(
      br(),
      fileInput("file", "\U1F4C1 Upload your file", 
                accept = c(".csv", ".xlsx", ".xls", ".txt")),
      helpText("Supported formats: CSV, Excel (.xls/.xlsx), or TXT (tab-delimited)."),
      br(),
      uiOutput("var_select"),
      helpText("Choose the outcome variable to group the summary and plot results."),
      br(),
      uiOutput("var_deselect"),
      helpText("Uncheck any variables you want to exclude from the summary."),
      
      tags$hr(),
      p("Download options"),
      downloadBttn("download_summary", 
                   "Download Summary (CSV)", 
                   style = "material-flat", color = "primary"),
      br(),
      helpText("Exports summary statistics (mean, median, SD, etc.) as a CSV file."),
      br(),
      br(),
      downloadBttn("download_grouped", 
                   "Download Summary Table (HTML)", 
                   style = "material-flat", color = "success"),
      br(),
      helpText("Downloads the formatted summary table with p-values as an HTML file."),
      
      tags$hr(),
      tags$h5("\U0001F64B How to Use"),
      tags$ol(
        tags$li("Upload your data file (CSV, Excel, or TXT)."),
        tags$li("Select the outcome variable to group the data."),
        tags$li("Choose variables to include or exclude."),
        tags$li("Explore:",
                tags$ul(
                  tags$li("Summary statistics"),
                  tags$li("Violin plots or bar charts"),
                  tags$li("Statistical test p-values")
                )),
        tags$li("Download the summary or table outputs as needed.")
      )
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("\U1F4CA Summary",
                 br(),
                 p("Explore summary statistics and violin plots for selected variables."),
                 uiOutput("single_var_ui"),
                 plotOutput("summary_plot", height = "350px"),
                 verbatimTextOutput("summary_stats")
        ),
        
        tabPanel("\U1F4CB Summary with p-values",
                 br(),
                 p("Table includes grouped descriptive statistics and statistical test p-values. Loading...please wait"),
                 gt_output("summary_table_with_pvals")
        ),
        
        tabPanel("\U0001F4CB About", 
                 fluidRow(
                   column(12, br(),
                          h5("Author & Declaration"),
                          HTML("
      <h6>\U0001F4CB Author Information</h6>
      <ul>
        <li><strong>Name:</strong> Sajan Raju</li>
        <li><strong>Affiliation:</strong> University of Oslo / Oslo University Hospital</li>
        <li><strong>Email:</strong> sajanr@uio.no</li>
        <li><strong>GitHub/Website:</strong> <a href='https://github.com/sajanraju' target='_blank'>Link</a></li>
      </ul>

      <h6>\U0001F4DC Declaration</h6>
      <ul>
        <li>This application was developed for research educational purpose.</li>
        <li>This application provides an initial overview of your dataset through descriptive statistics and visualizations, helping you better understand your data before deeper analysis.</li>
        <li>The app performs descriptive statistics and visualizations from uploaded tabular data.</li>
        <li>It does <strong>not</strong> store or transmit any uploaded data.</li>
        <li>Users are responsible for ensuring data privacy and regulatory compliance.</li>
      </ul>

      <h6>\U0001F4E6 License</h6>
      <p><a href='https://opensource.org/licenses/MIT' target='_blank'>MIT License</a><br>
      You may use, modify, and distribute this app under the terms of the license.</p>

      <h6>\U0001F4DA References</h6>
      <ul>
        <li><a href='https://www.danieldsjoberg.com/gtsummary/' target='_blank'>gtsummary</a></li>
        <li><a href='https://shiny.posit.co' target='_blank'>Shiny</a></li>
      </ul>
      ")
                   )
                 )
        )
        
      )
    )
  )
)


server <- function(input, output, session) {
  
  ##### Load & clean data ----
  data <- reactive({
    req(input$file)
    ext <- file_ext(input$file$name)
    switch(ext,
           csv = read_csv(input$file$datapath),
           xlsx = read_excel(input$file$datapath),
           xls = read_excel(input$file$datapath),
           txt = read_delim(input$file$datapath, delim = "\t"),
           validate("Invalid file; Please upload a .csv, .xlsx, .xls or .txt file"))
  })
  
  cleaned_data <- reactive({
    df <- data()
    df <- df %>% select(where(~!all(is.na(.))))
    df
  })
  
  ##### UI Inputs ----
  output$var_select <- renderUI({
    req(cleaned_data())
    selectInput("outcome_var", "Select Outcome Variable", choices = names(cleaned_data()))
  })
  
  output$var_deselect <- renderUI({
    req(cleaned_data())
    checkboxGroupInput("exclude_vars", "Deselect Variables to Exclude from Summary:", 
                       choices = setdiff(names(cleaned_data()), input$outcome_var),
                       selected = setdiff(names(cleaned_data()), input$outcome_var))
  })
  
  output$single_var_ui <- renderUI({
    req(cleaned_data())
    selectInput("single_var", "Select Variable for Summary", choices = names(cleaned_data()))
  })
  
  ##### Summary Table ----
  summary_tbl <- reactive({
    req(input$outcome_var, input$exclude_vars)
    df <- cleaned_data()
    df %>%
      select(all_of(c(input$outcome_var, input$exclude_vars))) %>%
      tbl_summary(by = !!sym(input$outcome_var), missing = "no") %>%
      add_p()
  })
  
  output$summary_table_with_pvals <- gt::render_gt({
    req(summary_tbl())
    gtsummary::as_gt(summary_tbl())
  })
  
  ##### Summary Stats ----
  output$summary_stats <- renderPrint({
    req(input$single_var)
    df <- cleaned_data()
    var <- input$single_var
    if (is.numeric(df[[var]])) {
      stats <- df[[var]]
      list(
        Mean = mean(stats, na.rm = TRUE),
        Median = median(stats, na.rm = TRUE),
        SD = sd(stats, na.rm = TRUE),
        IQR = IQR(stats, na.rm = TRUE),
        Min = min(stats, na.rm = TRUE),
        Max = max(stats, na.rm = TRUE)
      )
    } else {
      table(df[[var]]) %>% prop.table()
    }
  })
  
  ##### Violin Plot 
  output$summary_plot <- renderPlot({
    req(input$single_var, input$outcome_var)
    df <- cleaned_data()
    var <- input$single_var
    outcome <- input$outcome_var
    
    if (is.numeric(df[[var]])) {
      ggplot(df, aes_string(x = outcome, y = var)) +
        geom_violin(fill = "#7ec8e3", color = "gray30", trim = FALSE) +
        geom_jitter(width = 0.1, alpha = 0.3, size = 1) +
        theme_minimal() +
        labs(title = paste("Violin plot of", var, "by", outcome),
             x = outcome, y = var)
    } else {
      ggplot(df, aes_string(x = var, fill = outcome)) +
        geom_bar(position = "dodge") +
        theme_minimal() +
        labs(title = paste("Bar plot of", var, "by", outcome))
    }
  })
  
  ###### Downloads 
  output$download_summary <- downloadHandler(
    filename = function() { "summary_stats.csv" },
    content = function(file) {
      req(summary_tbl())
      write.csv(as_tibble(summary_tbl()$table_body), file, row.names = FALSE)
    }
  )
  
  output$download_grouped <- downloadHandler(
    filename = function() { "summary_table.html" },
    content = function(file) {
      req(summary_tbl())
      gtsummary::as_gt(summary_tbl()) %>% gt::gtsave(file)
    }
  )
}


#shinyApp(ui, server)
#shinyApp(ui, server, options = list(launch.browser = TRUE))
shinyApp(ui, server, options = list(launch.browser = TRUE, port = 8080)) 

