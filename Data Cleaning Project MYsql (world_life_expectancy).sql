# Step 1: Standardize column names
ALTER TABLE world_life_expectancy
RENAME COLUMN Lifeexpectancy TO Life_expectancy,
RENAME COLUMN AdultMortality TO Adult_Mortality,
RENAME COLUMN infantdeaths TO infant_deaths,
RENAME COLUMN percentageexpenditure TO percent_age_expenditure
;

# Step 2: Removing duplicates
SELECT *
FROM world_life_expectancy
;

# Count of (country,year) appearing as a pair
SELECT country, year, 
       CONCAT(Country,year) AS country_year , 
       COUNT(CONCAT(Country,year)) AS Count_country_year
FROM world_life_expectancy
GROUP BY country, year, CONCAT(country,year) 
HAVING COUNT(CONCAT(Country,year)) > 1
;

#identifying duplicate rows
SELECT *
FROM (
	SELECT Row_id,
	CONCAT(country,year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(country,year) ORDER BY CONCAT(country,year)) as Row_num
	FROM project.world_life_expectancy
    ) AS Row_table
WHERE Row_num > 1
;

# Removing duplicate rows
DELETE FROM project.world_life_expectancy
WHERE 
	Row_id IN (
    SELECT Row_id
FROM (
	SELECT Row_id,
	CONCAT(country,year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(country,year) ORDER BY CONCAT(country,year)) as Row_num
	FROM project.world_life_expectancy
    ) AS Row_table
WHERE Row_num > 1
)
;

# Step 3: Filling blanks in categorical column (Status)
SELECT *
FROM world_life_expectancy
WHERE Status = ''
;

#identifying what status available
SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE status <> ''
;

# Showing developed countrys
SELECT DISTINCT(country)
FROM world_life_expectancy
WHERE status = 'developing'
;

# Fill in status = developing
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.status = 'developing'
    WHERE t1.status = ''
    AND t2.status <> ''
    AND t2.status = 'Developing'
    ;
    
# Fill in status = developed
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.status = 'Developed'
    WHERE t1.status = ''
    AND t2.status <> ''
    AND t2.status = 'Developed'
    ;

# Step 4: Filling blanks in numerical column (Life Expectancy)
SELECT *
FROM world_life_expectancy
WHERE lifeexpectancy = ''
;

# Filling life expectancy blank with an average
SELECT t1.country, t1.year, t1.lifeexpectancy,
	   t2.country, t2.year, t2.lifeexpectancy,
       t3.country, t3.year, t3.lifeexpectancy,
	ROUND((t2.lifeexpectancy + t3.Lifeexpectancy) /2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year + 1
WHERE t1.Lifeexpectancy = ''
;

#Updating table data
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year + 1
SET t1.lifeexpectancy = ROUND((t2.lifeexpectancy + t3.Lifeexpectancy) /2,1)
WHERE t1.lifeexpectancy = ''
;
