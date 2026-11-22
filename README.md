# CarSharing-Reports-with-SQL-Queries
# CarSharing Report with SQL Queries

## 1. Project Overview

This project involves analysing a car-sharing dataset containing hourly customer demand records from January 2017 to August 2018. The dataset includes information about customer demand, time-related features, and weather conditions such as temperature, humidity, and wind speed.

The aim of the project is to manipulate and organise the dataset, create a relational database, and use SQL queries to answer business questions that can help the company's marketing team understand customer demand patterns.

## 2. Tools and Technologies

- **Google Sheets:** Data manipulation, cleaning, categorisation, and preparation.
- **PostgreSQL:** Database creation, table management, and SQL analysis.
- **pgAdmin 4:** Database administration and query execution.
- **GitHub:** Project documentation and code sharing.
- **Google Drive:** Storage and sharing of analysis result tables.

## 3. Part One: Data Manipulation with Google Sheets

The original dataset was opened in Google Sheets and prepared for database management.

The following tasks were completed:

- Filled missing values in the `temp` and `temp_feel` columns using their respective averages, rounded to two decimal places.
- Created a `temp_category` column to classify temperature records into Cold, Mild, and Hot categories.
- Generated unique temperature identifiers in the `temp_code` column by combining temperature, feels-like temperature, and temperature category.
- Identified distinct weather conditions and assigned numerical identifiers using the `weather_code` column.
- Extracted hour, weekday name, and month name from the timestamp column.
- Created separate `weather`, `temperature`, and `time` sheets.
- Removed duplicate records from the weather and temperature sheets.
- Removed unnecessary columns from the main dataset to prepare the four tables for database creation.

## 4. Part Two: Database Management

The prepared datasets were exported as CSV files and imported into a PostgreSQL database named `carsharing`.

Four tables were created:

1. `carsharing_df` – Contains the main car-sharing records, including demand, humidity, wind speed, and foreign keys.
2. `temperature` – Contains temperature, feels-like temperature, temperature category, and temperature code.
3. `weather` – Contains weather conditions and their corresponding weather codes.
4. `time` – Contains date and time information, including season, hour, weekday name, and month name.

Relationships were established between the main `carsharing_df` table and the three supporting tables using their respective identifiers.

## 5. Part Three: SQL Queries and Business Analysis

SQL queries were written and executed to answer the five business questions provided in the project.

### Question A: Highest Demand in 2017

Identified the date and time with the highest recorded customer demand in 2017.

### Question B: Demand Patterns

Determined the weekdays, months, and seasons with the highest and lowest average customer demand throughout 2017, including their calculated average demand values.

### Question C: Hourly Demand Analysis

Examined the average demand across different hours for the weekdays identified in Question B. Results were sorted in descending order based on average demand.

### Question D: Weather Analysis for 2017

Analysed weather conditions throughout 2017 by:

- Determining whether the year was predominantly Cold, Mild, or Hot.
- Identifying the most prevalent weather condition.
- Calculating the average, highest, and lowest wind speed for each month.
- Calculating the average, highest, and lowest humidity for each month.
- Comparing average customer demand across the Cold, Mild, and Hot temperature categories.

### Question E: Analysis of the Highest-Demand Month

Repeated the weather and demand analysis in Question D for the month with the highest average customer demand in 2017 to enable comparison with the overall yearly results.

## 6. Project Files and Results

**SQL Script:** `CarSharing_Analysis.sql`

The SQL script contains the queries used to answer Questions A–E, with comments identifying each question and explaining the purpose of the queries.

**Analysis Results:** [View the result tables on Google Drive](https://drive.google.com/drive/folders/1_MgbwW-XZ_fgOMRZHPlnNEBIf5GvxThd?usp=sharing)

## 7. Conclusion

This project demonstrates the use of spreadsheet functions for data manipulation, relational database management, and SQL querying to investigate customer demand patterns and their relationship with time and weather conditions. The findings provide useful information that can support data-driven marketing and business decisions.
