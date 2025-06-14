# Project1
# Clinical Visit Insights Automation

This project demonstrates a complete automation pipeline for pulling, cleaning, and analyzing clinical visit data stored in a Snowflake data warehouse. It includes JSON parsing, data validation, QA checks, and output generation — all using secure, reproducible R code.

---

## Project Overview

**Goal**: Automatically process patient-level clinical visit data pulled from Snowflake, parse nested JSON vitals, clean and validate it, and generate both QA outputs and department-level summaries.

---

## Folder Structure

```
Project1/
├── scripts/
│   └── automation_pipeline.R
├── output/
│   ├── qa_issues.csv
│   └── department_summary.csv
└── README.md
```

---

## Setup Instructions

### 1. Save your Snowflake credentials using `keyring`

Run this once in R to store your credentials securely:

```r
install.packages("keyring")
library(keyring)
key_set("snowflake", username = "DWANALYTICSPROJECTS")
```

### 2. Install required packages

```r
install.packages(c("DBI", "odbc", "dplyr", "jsonlite", "purrr", "keyring", "rstudioapi"))
```

### 3. Open this project as an RStudio Project

Make sure you’re working inside the GitHub repo folder (e.g., `C:/Users/you/Documents/GitHub/Project1/`) to ensure paths work properly.

### 4. Run the pipeline script

Run `scripts/automation_pipeline.R` from RStudio. It will:
- Pull data from Snowflake (`clinical_visits_2`)
- Clean and parse the `vitals` column (JSON)
- Perform QA checks
- Generate a department-level summary
- Save outputs to `output/`

---

## Example Use Case

Imagine you're working with a healthcare analytics team. You receive patient visit data from an external Snowflake instance. This script allows you to:

- Validate the quality and structure of that data (missing vitals, malformed JSON, abnormal temperatures)
- Rapidly summarize clinical load by department and admission status
- Output clean summaries for use in dashboards, reports, or further modelling

This kind of workflow is essential in environments like NHS reporting, pharmaceutical real-world evidence, or population health analytics.

---

Developed by **David Willsher**.  

