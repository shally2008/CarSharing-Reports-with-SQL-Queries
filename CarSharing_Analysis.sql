-- creates carsharing_df table
CREATE TABLE Carsharing_df(
    ID INT,
    Holiday VARCHAR(10),
    Workingday VARCHAR(10),
    Humidity DECIMAL(10,2),
    Windspeed DECIMAL(10,2),
    Demand DECIMAL(15,9),
    TempCode VARCHAR(100),
    WeatherCode INT
);

-- create weather TABLE
CREATE TABLE Weather(
    Weather VARCHAR(100),
    WeatherCode INT
);
-- Create temperature TABLE
CREATE TABLE Temperature(
    Temp DECIMAL(10,2), 
    TempFeel DECIMAL(10,2),	
    TempCategory VARCHAR(20),	
    TempCode VARCHAR(50)
);
-- Create time TABLE
CREATE TABLE Time(
    ID	INT,
    DateTime TIMESTAMP,	
    Season	VARCHAR(50),
    Hour	INT,
    WeekdayName	VARCHAR(50),
    MonthName VARCHAR(50)
);
--confirm carsharing_df table was created successfully
SELECT *
FROM carsharing_df;


-- PRIMARY KEYS
-- ALTER TABLE means we want to make a change to a table
-- that has already been created.
-- We use it because our tables already exist.

-- ADD CONSTRAINT means we are adding a rule to the table.
-- The rule will be given a name so we can identify it later.

-- Create a primary key for the Temperature table.
-- TempCode is used because it identifies each temperature category.
-- PRIMARY KEY ensures that every TempCode is unique
-- and cannot be empty (NULL).
ALTER TABLE Temperature
ADD CONSTRAINT pk_temperature
PRIMARY KEY (TempCode);

-- Create a primary key for the Weather table.
-- WeatherCode identifies each weather condition.
-- The primary key prevents two records from having
-- the same WeatherCode.
ALTER TABLE Weather
ADD CONSTRAINT pk_weather
PRIMARY KEY (WeatherCode);

-- Create a primary key for the Time table.
-- ID is used to uniquely identify each time record.
-- The primary key ensures that each ID belongs to
-- only one record in this table.
ALTER TABLE Time
ADD CONSTRAINT pk_time
PRIMARY KEY (ID);


-- FOREIGN KEYS
-- Connect the Carsharing_df table to the Temperature table.

-- ALTER TABLE means we are modifying the existing Carsharing_df table.
-- ADD CONSTRAINT means we are adding a new relationship rule.
-- fk_carsharing_temperature is the name of this rule.
-- FOREIGN KEY (TempCode) identifies the column in Carsharing_df
-- that we want to use for the connection.
-- REFERENCES Temperature(TempCode) tells PostgreSQL that
-- this column must refer to an existing TempCode in Temperature.
ALTER TABLE Carsharing_df
ADD CONSTRAINT fk_carsharing_temperature
FOREIGN KEY (TempCode)
REFERENCES Temperature(TempCode);


-- Connect the Carsharing_df table to the Weather table.
-- WeatherCode is the column used to identify the matching
-- weather condition in the Weather table.
-- REFERENCES points to the primary key in the Weather table.
ALTER TABLE Carsharing_df
ADD CONSTRAINT fk_carsharing_weather
FOREIGN KEY (WeatherCode)
REFERENCES Weather(WeatherCode);

-- Connect the Carsharing_df table to the Time table.
-- ID is the column being used to connect the two tables.
-- REFERENCES tells PostgreSQL to find the matching ID
-- in the Time table.
-- This assumes both ID columns contain corresponding identifiers.
ALTER TABLE Carsharing_df
ADD CONSTRAINT fk_carsharing_time
FOREIGN KEY (ID)
REFERENCES Time(ID);


--DATA ANALYSIS

-- QUESTION (a): FIND THE DATE AND TIME WITH THE HIGHEST DEMAND IN 2017
SELECT
    t.datetime AS demand_date_time, -- Displays the date and time
    c.demand AS highest_demand      -- Displays the demand value
FROM carsharing_df AS c

-- Connect the main dataset to the time table
INNER JOIN time AS t
    ON c.id = t.id
-- Restrict the analysis to records from 2017
WHERE EXTRACT(YEAR FROM t.datetime) = 2017
-- Arrange demand from highest to lowest
ORDER BY c.demand DESC
-- Return the record with the highest demand
LIMIT 1;


-- QUESTION (b): HIGHEST AND LOWEST AVERAGE DEMAND
-- FOR WEEKDAYS, MONTHS AND SEASONS IN 2017

-- STEP 1: Join the main table with the Time table
-- and keep only records from 2017.

WITH yearly_data AS (
    SELECT
        c.demand,
        t.weekdayname,
        t.monthname,
        t.season
    FROM carsharing_df AS c
    INNER JOIN time AS t
        ON c.id = t.id
    WHERE EXTRACT(YEAR FROM t.datetime) = 2017
),

-- STEP 2: Calculate average demand for each weekday.
weekday_average AS (
    SELECT
        'Weekday' AS category,
        weekdayname AS period,
        AVG(demand) AS average_demand
    FROM yearly_data
    GROUP BY weekdayname
),

-- STEP 3: Calculate average demand for each month.
month_average AS (
    SELECT
        'Month' AS category,
        monthname AS period,
        AVG(demand) AS average_demand
    FROM yearly_data
    GROUP BY monthname
),

-- STEP 4: Calculate average demand for each season.
season_average AS (
    SELECT
        'Season' AS category,
        season AS period,
        AVG(demand) AS average_demand
    FROM yearly_data
    GROUP BY season
),

-- STEP 5: Combine the three average-demand results.
all_averages AS (
    SELECT * FROM weekday_average
    UNION ALL
    SELECT * FROM month_average
    UNION ALL
    SELECT * FROM season_average
),

-- STEP 6: Rank the average demand within each category.
ranked_results AS (
    SELECT
        category,
        period,
        average_demand,

        -- Highest average demand receives rank 1.
        RANK() OVER (
            PARTITION BY category
            ORDER BY average_demand DESC
        ) AS highest_rank,

        -- Lowest average demand receives rank 1.
        RANK() OVER (
            PARTITION BY category
            ORDER BY average_demand ASC
        ) AS lowest_rank

    FROM all_averages
)

-- QUESTION (b)
-- Display the highest and lowest averages.
-- Find the weekdays, months and seasons with the
-- highest and lowest average demand throughout 2017.

-- STEP 1: Prepare the 2017 data.
WITH yearly_data AS (
   SELECT
        c.demand,       -- Retrieves the demand values from Carsharing_df.
        t.weekdayname,  -- Retrieves the weekday names from the Time table.
        t.monthname,    -- Retrieves the month names from the Time table.
        t.season        -- Retrieves the seasons from the Time table.
    FROM carsharing_df AS c
    -- FROM specifies the main table we want to retrieve data from.
    -- AS c gives Carsharing_df a shorter name: c.

    INNER JOIN time AS t
    -- INNER JOIN combines records from both tables where their IDs match.
    -- AS t gives the Time table a shorter name: t.

        ON c.id = t.id
        -- ON specifies the condition used to match records.
        -- Here, the ID in both tables must be equal.

    WHERE EXTRACT(YEAR FROM t.datetime) = 2017
    -- WHERE filters the records based on a condition.
    -- EXTRACT(YEAR FROM t.datetime) retrieves the year from each date.
    -- = 2017 keeps only records from the year 2017.

),

-- STEP 2: Calculate the average demand for each weekday.
weekday_average AS (
    SELECT
        'Weekday' AS category,
        -- Creates a column called category.
        -- Every row from this query will be labelled Weekday.

        weekdayname AS period,
        -- Retrieves each weekday name and labels the column period.

        AVG(demand) AS average_demand
        -- AVG() calculates the arithmetic mean of the demand values.
        -- AS average_demand gives the calculated result a column name.

    FROM yearly_data
    -- Retrieves the filtered 2017 records prepared in STEP 1.

    GROUP BY weekdayname
    -- GROUP BY puts records with the same weekday together.
    -- AVG() then calculates the average demand for each weekday.

),

-- STEP 3: Calculate the average demand for each month.
month_average AS (
    SELECT
        'Month' AS category,
        -- Labels all results from this query as Month.

        monthname AS period,
        -- Retrieves the month names and labels the column period.

        AVG(demand) AS average_demand
        -- Calculates the average demand for each month.

    FROM yearly_data
    -- Uses the filtered 2017 records from STEP 1.

    GROUP BY monthname
    -- Groups records belonging to the same month.
    -- Calculates one average demand value for each month.

),

-- STEP 4: Calculate the average demand for each season.
season_average AS (
    SELECT
        'Season' AS category,
        -- Labels all results from this query as Season.

        season AS period,
        -- Retrieves the season names and labels the column period.

        AVG(demand) AS average_demand
        -- Calculates the average demand for each season.

    FROM yearly_data
    -- Uses the filtered 2017 records from STEP 1.

    GROUP BY season
    -- Groups records belonging to the same season.
    -- Calculates the average demand for each season.

),

-- STEP 5: Combine the three sets of average-demand results.
all_averages AS (
    SELECT * FROM weekday_average
    -- SELECT * retrieves all columns from weekday_average.

    UNION ALL
    -- UNION ALL combines the results of multiple SELECT statements.
    -- ALL keeps every row, including duplicates if any exist.

    SELECT * FROM month_average
    UNION ALL
    SELECT * FROM season_average

),

-- STEP 6: Rank the average demand within each category.
ranked_results AS (
    SELECT
        category,       -- Identifies whether the result is a weekday, month or season.
        period,          -- Displays the weekday, month or season name.
        average_demand,  -- Displays the calculated average demand.

        RANK() OVER (
            PARTITION BY category
            ORDER BY average_demand DESC
        ) AS highest_rank,
        -- RANK() assigns a position to each average demand.
        -- OVER() specifies how the ranking should be calculated.
        -- PARTITION BY category separates the rankings into three groups:
        -- Weekday, Month and Season.
        -- ORDER BY average_demand DESC ranks the highest average first.
        -- AS highest_rank names the resulting ranking column.

        RANK() OVER (
            PARTITION BY category
            ORDER BY average_demand ASC
        ) AS lowest_rank
        -- RANK() creates another ranking for the lowest average.
        -- PARTITION BY category keeps each category separate.
        -- ORDER BY average_demand ASC ranks the lowest average first.
        -- ASC means ascending order (smallest to largest).
        -- AS lowest_rank names the resulting ranking column.

    FROM all_averages
    -- Retrieves the combined weekday, month and season averages.

)

-- STEP 7: Display only the highest and lowest average demand.
SELECT
    category,  -- Shows whether the result is a weekday, month or season.

    period,    -- Shows the actual weekday, month or season name.

    CASE
        -- CASE checks conditions and returns a value based on the condition.

        WHEN highest_rank = 1 THEN 'Highest'
        -- WHEN checks whether the highest ranking is 1.
        -- THEN returns the word Highest if the condition is true.

        WHEN lowest_rank = 1 THEN 'Lowest'
        -- Checks whether the lowest ranking is 1.
        -- Returns Lowest if the condition is true.

    END AS demand_position,
    -- END closes the CASE statement.
    -- AS demand_position gives the resulting column its name.

    ROUND(average_demand::numeric, 4) AS average_demand
    -- ::numeric converts the average demand to a numeric data type.
    -- ROUND() rounds the number to 4 decimal places.
    -- AS average_demand names the displayed result.

FROM ranked_results
-- Retrieves the results prepared and ranked in STEP 6.

WHERE highest_rank = 1 OR lowest_rank = 1
-- WHERE filters the results.
-- highest_rank = 1 selects the highest average.
-- OR means either condition can be true.
-- lowest_rank = 1 selects the lowest average.
-- Therefore, we keep only the highest and lowest for each category.

ORDER BY category, demand_position;
-- ORDER BY sorts the final results.
-- First, it sorts by category.
-- Then, it sorts by demand_position within each category.


-- QUESTION (c): HOURLY AVERAGE DEMAND FOR SATURDAY AND THURSDAY
SELECT
    t.weekdayname,                 -- Displays the weekday name.
    t.hour,                         -- Displays the hour of the day.
    AVG(c.demand) AS average_demand -- Calculates average demand for that hour.
FROM carsharing_df AS c

-- Connect the main table to the Time table.
INNER JOIN time AS t
    ON c.id = t.id

-- Keep only records from 2017.
WHERE EXTRACT(YEAR FROM t.datetime) = 2017

-- Keep only Saturday and Thursday records.
AND t.weekdayname IN ('Saturday', 'Thursday')

-- Group records by weekday and hour.
GROUP BY
    t.weekdayname,
    t.hour

-- Arrange the highest hourly average demand first.
ORDER BY
    average_demand DESC;


-- QUESTION (D): WEATHER ANALYSIS FOR 2017
-- STEP 1: Combine the four tables and filter
-- the records to include only the year 2017.
-- We save the combined result as a temporary view
-- so we can reuse it in the analysis.
CREATE OR REPLACE VIEW carsharing_2017_analysis AS
SELECT
    c.id,
    t.datetime,
    t.monthname,
    c.humidity,
    c.windspeed,
    c.demand,
    temp.tempcategory,
    w.weather
FROM carsharing_df c
JOIN "time" t
    ON c.id = t.id
JOIN temperature temp
    ON c.tempcode = temp.tempcode
JOIN weather w
    ON c.weathercode = w.weathercode
WHERE EXTRACT(YEAR FROM t.datetime) = 2017;

-- STEP 2: Find the most prevalent temperature
-- category (Cold, Mild or Hot) in 2017.
-- COUNT calculates the number of records in each category.
-- ORDER BY sorts the categories from highest to lowest.
SELECT
    tempcategory,
    COUNT(*) AS frequency,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM carsharing_2017_analysis
GROUP BY tempcategory
ORDER BY frequency DESC;

-- STEP 3: Find the most prevalent weather condition
-- in 2017, such as Mist or Clear or partly cloudy.
SELECT
    weather,
    COUNT(*) AS frequency,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM carsharing_2017_analysis
GROUP BY weather
ORDER BY frequency DESC;

-- STEP 4: Calculate the monthly average, highest
-- and lowest wind speed for each month in 2017.
-- AVG calculates the average, MAX the highest
-- and MIN the lowest wind speed.
SELECT
    monthname,
    ROUND(AVG(windspeed)::numeric, 2) AS average_windspeed,
    MAX(windspeed) AS highest_windspeed,
    MIN(windspeed) AS lowest_windspeed
FROM carsharing_2017_analysis
GROUP BY monthname
ORDER BY MIN(datetime);

-- STEP 5: Calculate the monthly average, highest
-- and lowest humidity for each month in 2017.
SELECT
    monthname,
    ROUND(AVG(humidity)::numeric, 2) AS average_humidity,
    MAX(humidity) AS highest_humidity,
    MIN(humidity) AS lowest_humidity
FROM carsharing_2017_analysis
GROUP BY monthname
ORDER BY MIN(datetime);

-- STEP 6: Calculate the average demand for Cold,
-- Mild and Hot weather conditions.
-- Results are sorted in descending order
-- to identify the category with the highest demand.
SELECT
    tempcategory,
    ROUND(AVG(demand)::numeric, 4) AS average_demand
FROM carsharing_2017_analysis
GROUP BY tempcategory
ORDER BY average_demand DESC;


-- QUESTION (E): HIGHEST-DEMAND MONTH ANALYSIS
-- STEP 1: Identify the month with the highest
-- average demand in 2017.
-- The result is stored in a CTE (Common Table Expression)
-- for use in the following queries.
WITH monthly_demand AS (
    SELECT
        monthname,
        AVG(demand) AS average_demand
    FROM carsharing_2017_analysis
    GROUP BY monthname
)
SELECT
    monthname,
    ROUND(average_demand::numeric, 4) AS average_demand
FROM monthly_demand
ORDER BY average_demand DESC
LIMIT 1;

-- STEP 2: Calculate the average, highest and lowest
-- wind speed for the month with the highest average demand.
WITH highest_month AS (
    SELECT monthname
    FROM carsharing_2017_analysis
    GROUP BY monthname
    ORDER BY AVG(demand) DESC
    LIMIT 1
)
SELECT
    a.monthname,
    ROUND(AVG(a.windspeed)::numeric, 2) AS average_windspeed,
    MAX(a.windspeed) AS highest_windspeed,
    MIN(a.windspeed) AS lowest_windspeed
FROM carsharing_2017_analysis a
JOIN highest_month h
    ON a.monthname = h.monthname
GROUP BY a.monthname;

-- STEP 3: Calculate the average, highest and lowest
-- humidity for the month with the highest average demand.
WITH highest_month AS (
    SELECT monthname
    FROM carsharing_2017_analysis
    GROUP BY monthname
    ORDER BY AVG(demand) DESC
    LIMIT 1
)
SELECT
    a.monthname,
    ROUND(AVG(a.humidity)::numeric, 2) AS average_humidity,
    MAX(a.humidity) AS highest_humidity,
    MIN(a.humidity) AS lowest_humidity
FROM carsharing_2017_analysis a
JOIN highest_month h
    ON a.monthname = h.monthname
GROUP BY a.monthname;

-- STEP 4: Identify the most prevalent weather conditions
-- during the month with the highest average demand.
WITH highest_month AS (
    SELECT monthname
    FROM carsharing_2017_analysis
    GROUP BY monthname
    ORDER BY AVG(demand) DESC
    LIMIT 1
)
SELECT
    a.weather,
    COUNT(*) AS frequency
FROM carsharing_2017_analysis a
JOIN highest_month h
    ON a.monthname = h.monthname
GROUP BY a.weather
ORDER BY frequency DESC;

-- STEP 5: Calculate average demand for each temperature
-- category during the highest-demand month.
-- This allows us to compare demand during Cold, Mild
-- and Hot conditions within that particular month.
WITH highest_month AS (
    SELECT monthname
    FROM carsharing_2017_analysis
    GROUP BY monthname
    ORDER BY AVG(demand) DESC
    LIMIT 1
)
SELECT
    a.tempcategory,
    ROUND(AVG(a.demand)::numeric, 4) AS average_demand
FROM carsharing_2017_analysis a
JOIN highest_month h
    ON a.monthname = h.monthname
GROUP BY a.tempcategory
ORDER BY average_demand DESC;

