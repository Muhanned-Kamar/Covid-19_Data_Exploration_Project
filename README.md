# Covid-19 Data Exploration Project

## Introduction

In this project I will be exploring the Covid-19 Data from [link](https://ourworldindata.org/covid-deaths), trying to get somewhat an understanding of the impact of the virus to each continent and country from deaths, new cases and vaccination.

## Covid-19 Death Data Exploration

### Selecting data that we are going to be using

    USE CovidProject

### View data

    SELECT *

    FROM CovidDeaths
    WHERE continent is null
    order by 3,4

### Select statment for exploring the data we want to get an idea of 

    SELECT location, date, total_cases, new_cases, total_deaths, population

    FROM CovidDeaths
    ORDER BY location,date

### Looking at Total Cases vs Total Deaths Percentage

### Shows likelihood of dying if you have covid in your country

    SELECT location, date, total_cases, total_deaths,
    (total_deaths/total_cases)*100 AS DeathPercentage

    FROM CovidDeaths
    WHERE continent is not null --AND location = 'Algeria' -- Here you can choose your country and see the results
    ORDER BY location,date

### Looking at the Total Cases vs Population

### Shows what percentage of population got Covid

    SELECT location, date, population, total_cases,
    (total_cases/population)*100 AS Infected_Percentage
    
    FROM CovidDeaths
    ORDER BY location,date

### Looking at Countries with highest infection rate compared to population

    SELECT location, population,
    MAX(total_cases) AS Highest_Infection_Count,
    MAX((total_cases/population))*100 AS Infected_Percentage

    FROM CovidDeaths
    --WHERE location = 'Africa' -- Here you can choose your country and see the results
    GROUP BY location,population
    ORDER BY Infected_Percentage DESC

### Showing the Countries with the Hightest Death Count per Population

    SELECT location,
    MAX(cast(total_deaths as INT)) AS Highest_Death_Counts

    FROM CovidDeaths
    WHERE continent is not null --AND location = 'Egypt'  -- Here you can choose your country and see the results
    GROUP BY location
    ORDER BY Highest_Death_Counts DESC

### Total Death , Cases and percentage of Death

    SELECT SUM(new_cases) AS 'Total Cases',
    SUM(CAST(new_deaths AS INT))  AS 'Total Deaths',
    (SUM(CAST(new_deaths AS INT))/ SUM(new_cases) )*100 AS 'Death Percentage'

    FROM CovidDeaths
    WHERE continent is not null

### Continent

### Highest death ranked by the Continents

    SELECT location AS 'Continent',
    MAX(cast(total_deaths as INT)) AS Highest_Death_Counts

    FROM CovidDeaths
    WHERE continent is null AND location NOT IN ('International','European Union','World','Low income','Lower middle income','High income','Upper middle income' )
    GROUP BY location
    ORDER BY Highest_Death_Counts DESC

### Veiwing the total deaths vs the income 

    SELECT location AS 'Continent',date, total_deaths,
    SUM(CONVERT(BIGINT, total_deaths )) OVER (PARTITION BY location ORDER BY location, date) AS total_add_up_deaths

    FROM CovidDeaths
    WHERE continent is null AND location NOT IN ('International','European Union','World','Europe','North America','Asia','South America', 'Africa', 'Oceania')
    ORDER BY location ,total_add_up_deaths , date DESC

### Global Numbers

### Day by day death and New cases + Percentage

    WITH CumTO (date, Death_per_day, Cumulative_Total_Death, New_Cases_per_day, Cumulative_Total_Cases)
    AS (
    SELECT date,
    SUM(CAST(new_deaths AS INT)) AS Death_per_day  ,
    SUM(SUM(CAST(new_deaths AS INT)))OVER (ORDER BY date ) AS Cumulative_Total_Death,
    SUM(CAST(new_cases AS INT)) AS New_Cases_per_day  ,
    SUM(SUM(CAST(new_cases AS INT)))OVER (ORDER BY date ) AS Cumulative_Total_Cases

    FROM CovidDeaths
    WHERE continent is not null
    GROUP BY date 
    )

    SELECT *,(CAST(Cumulative_Total_Death AS FLOAT) /Cumulative_Total_Cases) * 100 AS DeathPerCases,
    (CAST(Death_per_day AS FLOAT )/New_Cases_per_day) *100 AS DayPercentage

    FROM CumTO

## Covid-19 Vaccination Data Exploration

### Selecting data that we are going to be using

    USE CovidProject

### View data

    SELECT *

    FROM CovidDeaths AS CD
    JOIN CovidVaccinations AS CV
         ON CD.location = CV.location 
	     AND CD.date = CV.date

### Looking at Total Population vs Total Vaccination

#### Comment that the ' OVER (PARTITION BY)' part means that it adds up the values of each location to show the total at the end of each population

    SELECT 
    CD.continent , CD.location , CD.date, CD.population, CV.new_vaccinations,
    SUM (CONVERT(BIGINT, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS 'Total Amout of Vaccination Per Location'

    FROM CovidDeaths AS CD
    JOIN CovidVaccinations AS CV
         ON CD.location = CV.location 
	     AND CD.date = CV.date
	     WHERE CD.continent is not null

    ORDER BY CD.continent , CD.location 

### Percentage of vaccinated of the population with the total amout of vaccination for each location

#### Using a CTE

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

### Total perecatage of the vaccineated populaction per location

#### Using TEMP TABLE

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

### Creating a view to store data for later Vizualtization

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

### The total vaccinations and total population with the percentage of vaccinated 

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

### Total vaccination By location and continent

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





