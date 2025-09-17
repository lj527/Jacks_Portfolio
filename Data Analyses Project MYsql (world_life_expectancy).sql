# Step 1: Preview dataset

SELECT *
FROM world_life_expectancy
;

# Step 2: Calculate life expectancy increase over 15 years (2007–2022)

SELECT country,
	   MIN(Life_expectancy) AS 2007_Life_expectancy,
	   MAX(Life_expectancy) AS 2022_Life_expectancy,
       ROUND(MAX(Life_expectancy) - MIN(Life_expectancy),1) AS Life_increase_15_years
FROM world_life_expectancy
	GROUP BY country
	HAVING MIN(Life_expectancy) <> 0
	AND	   MAX(Life_expectancy) <> 0
ORDER BY Life_increase_15_years ASC
;

# Step 3: Average life expectancy per year

SELECT year,
	   ROUND(AVG(life_expectancy),2)
FROM world_life_expectancy
WHERE Life_expectancy <> 0
	AND Life_expectancy <> 0
GROUP BY year
ORDER BY year
;

# Step 4: Average life expectancy and GDP per country

SELECT country, 
       ROUND(AVG(life_expectancy),1) AS Life_Exp,
       ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY country
HAVING Life_Exp > 0
		AND GDP > 0
ORDER BY GDP ASC
;

# Step 5: Relationship between GDP and life expectancy

SELECT
	SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
	ROUND(AVG(CASE WHEN GDP >= 1500 THEN Life_expectancy ELSE NULL END),0) High_GDP_Count_Life_expectancy,
	SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
	ROUND(AVG(CASE WHEN GDP <= 1500 THEN Life_expectancy ELSE NULL END),0) Low_GDP_Count_Life_expectancy
FROM world_life_expectancy
;

# Step 6: Compare average life expectancy by development status

SELECT status,
	ROUND(AVG(Life_expectancy),1)
FROM world_life_expectancy
GROUP BY status
;

# Step 7: Impact of Developed vs Developing country counts on life expectancy

SELECT status,
       COUNT(DISTINCT Country),
       ROUND(AVG(Life_expectancy),1)
FROM world_life_expectancy
GROUP BY status
;

# Step 8: Relationship between BMI and life expectancy by country

SELECT country, 
       ROUND(AVG(life_expectancy),1) AS Life_Exp,
       ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY country
HAVING Life_Exp > 0
		AND BMI > 0
ORDER BY BMI ASC
;

# Step 9: Preview dataset again

SELECT * 
FROM world_life_expectancy
;

# Step 10: Life expectancy vs Adult mortality (with rolling total)

SELECT country,
	year,
	life_expectancy,
    Adult_mortality,
    SUM(Adult_mortality) OVER(PARTITION BY country ORDER BY year) AS Rolling_total
FROM world_life_expectancy
;
