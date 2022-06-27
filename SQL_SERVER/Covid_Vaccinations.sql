-- Selecting data that we are going to be using

USE CovidProject

-- View data

SELECT *
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
     ON CD.location = CV.location 
	 AND CD.date = CV.date

-- Looking at Total Population vs Total Vaccination

-- Comment that the ' OVER (PARTITION BY)' part means that it adds up the values of each location to show the total at the end of each population

SELECT 
CD.continent , CD.location , CD.date, CD.population, CV.new_vaccinations,
SUM (CONVERT(BIGINT, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS 'Total Amout of Vaccination Per Location'

FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
     ON CD.location = CV.location 
	 AND CD.date = CV.date
	 WHERE CD.continent is not null

ORDER BY CD.continent , CD.location 

-- Percentage of vaccinated of the population with the total amout of vaccination for each location

-- Using a CTE

WITH pvv (continent, location, date, population, new_vaccinations , Total_Amout_of_Vaccination_Per_Location)
AS (
SELECT 
CD.continent , CD.location , CD.date, CD.population,
CV.new_vaccinations,
SUM (CONVERT(BIGINT, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Total_Amout_of_Vaccination_Per_Location

FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
     ON CD.location = CV.location 
	 AND CD.date = CV.date
	 WHERE CD.continent is not null
)

SELECT *, (Total_Amout_of_Vaccination_Per_Location/population)*100 AS Percentage_Vaccinated
FROM pvv

-- Totge thte perecatage of the vaccineated populaction per location

-- Using TEMP TABLE

DROP TABLE IF EXISTS percent_population_vaccinated

CREATE TABLE percent_population_vaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR (255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
Total_Amout_of_Vaccination_Per_Location NUMERIC
)

INSERT INTO percent_population_vaccinated

SELECT 
CD.continent , CD.location , CD.date, CD.population, CV.new_vaccinations,
SUM (CONVERT(BIGINT, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Total_Amout_of_Vaccination_Per_Location

FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
     ON CD.location = CV.location 
	 AND CD.date = CV.date
	 WHERE CD.continent is not null

SELECT *, (Total_Amout_of_Vaccination_Per_Location/population)*100 AS percentage_of_population_per_location
FROM percent_population_vaccinated

-- Creating a view to store data for later Vizualtization

CREATE VIEW  percent_population_vaccinated_View AS

SELECT 
CD.continent , CD.location , CD.date, CD.population,
CV.new_vaccinations,
SUM (CONVERT(BIGINT, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Total_Amout_of_Vaccination_Per_Location

FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
     ON CD.location = CV.location 
	 AND CD.date = CV.date
	 WHERE CD.continent is not null

SELECT *

FROM percent_population_vaccinated_View

-- The total vaccinations and total population with the percentage of vaccinated 

SELECT CD.continent , 
SUM(CONVERT(BIGINT,CD.population)) AS Total_Population,
SUM(CONVERT(BIGINT , CV.New_vaccinations)) AS Total_Vaccinations,
SUM((CONVERT(FLOAT, CV.New_vaccinations))/(CONVERT(FlOAT,CD.population))) AS Percentage_Vaccinated

FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
     ON CD.location = CV.location 
	 AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
GROUP BY CD.continent
ORDER BY Total_Vaccinations DESC

-- Total vaccination By location and continent

SELECT Continent,Location ,SUM(Population) AS Population,
SUM(Total_Amout_of_Vaccination_Per_Location) AS Total_Vac,
(SUM(Total_Amout_of_Vaccination_Per_Location)/SUM(population))*100 AS percentage_of_population_per_location
FROM percent_population_vaccinated
GROUP BY Continent , location

SELECT 
Location,
SUM(Population) AS Population,
SUM(Total_Amout_of_Vaccination_Per_Location) AS Total_Vac,
(SUM(Total_Amout_of_Vaccination_Per_Location)/SUM(population))*100 AS percentage_of_population_per_location
FROM percent_population_vaccinated

GROUP BY Location
ORDER BY percentage_of_population_per_location DESC

