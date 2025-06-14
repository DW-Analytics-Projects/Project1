# Project1  
## Clinical Visit Insights Automation

This project demonstrates a complete automation pipeline for pulling, cleaning, validating, and analyzing clinical visit data from a Snowflake data warehouse. The pipeline includes structured JSON parsing, quality assurance checks, secure credential handling via `keyring`, and polished output reporting using R Markdown.

---

## Project Overview

**Goal**: Automatically process patient-level clinical visit data pulled from Snowflake, parse nested JSON vitals, clean and validate it, and generate both QA outputs and department-level summaries.  
A final HTML report presents the workflow, findings, and visual summaries — styled to match Sorcero’s design.

---

## Folder Structure

```
Project1/
├── scripts/
│   └── automation_pipeline.R
├── output/
│   ├── cleaned_clinical_visits.csv
│   ├── qa_issues.csv
│   └── department_summary.csv
├── Report.Rmd
├── Report.html
├── styles.css
└── README.md
```

---

## Setup Instructions

### 1. Store Snowflake credentials securely

Run this once in R to store your password using your system’s credential vault:

```r
install.packages("keyring")
library(keyring)
key_set("snowflake_pwd")  # Enter the Snowflake password when prompted
```

### 2. Install required packages

```r
install.packages(c(
  "DBI", "odbc", "dplyr", "jsonlite",
  "purrr", "keyring", "readr", "ggplot2", "rmarkdown", "rstudioapi"
))
```

### 3. Open the project in RStudio

Work inside your GitHub folder (e.g., `C:/Users/you/Documents/GitHub/Project1/`) to ensure relative paths resolve correctly.

### 4. Run the pipeline

Run `scripts/automation_pipeline.R` to:

- Connect to Snowflake via ODBC
- Retrieve data from `clinical_visits_2`
- Parse JSON in the `vitals` column
- Clean and validate patient-level records
- Output results to `/output/`

---

## Generate the Report

The R Markdown file (`Report.Rmd`) compiles an HTML report with:

- Executive summary
- Data cleaning and QA logic
- Grouped summaries and charts
- Visual style matching Sorcero branding

To render:

```r
rmarkdown::render("Report.Rmd")
```

Ensure `/output/` contains the expected `.csv` files before rendering.

---

## Example Use Case

Imagine you're working with a clinical insights team receiving daily extracts from a Snowflake instance. This pipeline allows you to:

- Validate and clean embedded JSON vital signs (e.g., blood pressure, temperature)
- Flag missing data and prepare QA reports
- Generate real-time summary tables for dashboards or reports
- Store results and reports in GitHub for reproducibility and version control

---

## Security

This project uses the `keyring` package to securely store Snowflake credentials outside the script, eliminating the need to hardcode sensitive information.

---

Developed by **David Willsher**.
