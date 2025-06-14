# ------------------------------------------------------------------------------
# automation_pipeline.R
# Author: David Willsher
# Description: Pulls clinical visit data from Snowflake, parses embedded JSON,
# cleans, checks quality, and generates department-level summaries.
# ------------------------------------------------------------------------------

library(DBI)
library(odbc)
library(dplyr)
library(jsonlite)
library(purrr)
library(keyring)

# ------------------------------------------------------------------------------
# 1. Connect to Snowflake (securely)
# ------------------------------------------------------------------------------

#key_set("snowflake", username = "DWANALYTICSPROJECTS")

con <- dbConnect(odbc(),
                 dsn = "SnowflakeDSN",
                 uid = "DWANALYTICSPROJECTS",
                 pwd = key_get("snowflake", "DWANALYTICSPROJECTS"))

# ------------------------------------------------------------------------------
# 2. Pull raw data from the clinical_visits_2 table
# ------------------------------------------------------------------------------

df <- dbGetQuery(con, "SELECT * FROM clinical_visits_2")

# Convert column names to lowercase for easier handling
df <- df %>% rename_with(tolower)

# ------------------------------------------------------------------------------
# 3. Clean & parse: format gender, remove bad records, parse vitals JSON
# ------------------------------------------------------------------------------

df <- df %>%
  # Remove rows with missing critical fields
  filter(!is.na(vitals), !is.na(age), !is.na(gender)) %>%
  
  # Normalize gender values
  mutate(gender = case_when(
    tolower(gender) %in% c("m", "male") ~ "Male",
    tolower(gender) %in% c("f", "female") ~ "Female",
    TRUE ~ "Other"
  )) %>%
  
  # Safely parse JSON from vitals
  mutate(vitals_parsed = map(vitals, safely(fromJSON))) %>%
  mutate(
    bp = map_chr(vitals_parsed, ~ .x$result$bp %||% NA_character_),
    temp = map_dbl(vitals_parsed, ~ .x$result$temp %||% NA_real_)
  ) %>%
  select(-vitals_parsed) %>%
  
  # Basic sanity checks on vitals and age
  mutate(
    age = ifelse(age < 0 | age > 120, NA, age),
    temp = ifelse(temp < 35 | temp > 42, NA, temp)
  )

# ------------------------------------------------------------------------------
# 4. Quick QA: flag missing or suspicious values
# ------------------------------------------------------------------------------

qa_issues <- df %>%
  filter(is.na(age) | is.na(gender) | is.na(bp) | is.na(temp))

# ------------------------------------------------------------------------------
# 5. Summarise: department-level totals and vitals
# ------------------------------------------------------------------------------

summary_table <- df %>%
  filter(!is.na(age), !is.na(temp)) %>%
  group_by(department, admitted) %>%
  summarise(
    total_patients = n(),
    avg_age = mean(age, na.rm = TRUE),
    avg_temp = mean(temp, na.rm = TRUE),
    .groups = "drop"
  )

# ------------------------------------------------------------------------------
# 6. Export results to output/
# ------------------------------------------------------------------------------

# Dynamically detect path to this script
script_dir <- dirname(rstudioapi::getSourceEditorContext()$path)
output_dir <- file.path(script_dir, "output")

if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)


write.csv(qa_issues, file.path(output_dir, "qa_issues.csv"), row.names = FALSE)
write.csv(summary_table, file.path(output_dir, "department_summary.csv"), row.names = FALSE)

# ------------------------------------------------------------------------------
# 7. Disconnect and finish up
# ------------------------------------------------------------------------------

dbDisconnect(con)
message("Done. Your cleaned summary and QA files are ready in the 'output' folder.")
