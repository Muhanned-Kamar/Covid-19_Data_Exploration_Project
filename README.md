# Covid-19 Data Exploration Project

## Introduction

In this project I will be exploring the Covid-19 Data from [link](https://ourworldindata.org/covid-deaths), trying to get somewhat an understanding of the impact of the virus to each continent and country from deaths, new cases and vaccination.

### Selecting data that we are going to be using

    USE CovidProject

-- View data

SELECT *

FROM CovidDeaths
WHERE continent is null
order by 3,4

-- Select statment for exploring the data we want to get an idea of 

SELECT location, date, total_cases, new_cases, total_deaths, population

FROM CovidDeaths
ORDER BY location,date

-- Looking at Total Cases vs Total Deaths Percentage

-- Shows likelihood of dying if you have covid in your country

SELECT location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 AS DeathPercentage

FROM CovidDeaths
WHERE continent is not null --AND location = 'Algeria' -- Here you can choose your country and see the results
ORDER BY location,date

-- Looking at the Total Cases vs Population

-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases,
(total_cases/population)*100 AS Infected_Percentage

FROM CovidDeaths
ORDER BY location,date

-- Looking at Countries with highest infection rate compared to population

SELECT location, population,
MAX(total_cases) AS Highest_Infection_Count,
MAX((total_cases/population))*100 AS Infected_Percentage

FROM CovidDeaths
--WHERE location = 'Africa' -- Here you can choose your country and see the results
GROUP BY location,population
ORDER BY Infected_Percentage DESC

-- Showing the Countries with the Hightest Death Count per Population

SELECT location,
MAX(cast(total_deaths as INT)) AS Highest_Death_Counts

FROM CovidDeaths
WHERE continent is not null --AND location = 'Egypt'  -- Here you can choose your country and see the results
GROUP BY location
ORDER BY Highest_Death_Counts DESC

-- Total Death , Cases and percentage of Death

SELECT  SUM(new_cases) AS 'Total Cases' ,
SUM(CAST(new_deaths AS INT))  AS 'Total Deaths',
(SUM(CAST(new_deaths AS INT))/ SUM(new_cases) )*100 AS 'Death Percentage'

FROM CovidDeaths
WHERE continent is not null

-- Continent

-- Highest death ranked by the Continents

SELECT location AS 'Continent',
MAX(cast(total_deaths as INT)) AS Highest_Death_Counts

FROM CovidDeaths
WHERE continent is null AND location NOT IN ('International','European Union','World','Low income','Lower middle income','High income','Upper middle income' )
GROUP BY location
ORDER BY Highest_Death_Counts DESC

-- Veiwing the total deaths vs the income 

SELECT 
location AS 'Continent',date, total_deaths,
SUM(CONVERT(BIGINT, total_deaths )) OVER (PARTITION BY location ORDER BY location, date) AS total_add_up_deaths

FROM CovidDeaths
WHERE continent is null AND location NOT IN ('International','European Union','World','Europe','North America','Asia','South America', 'Africa', 'Oceania')
ORDER BY location ,total_add_up_deaths , date DESC

-- Global Numbers

-- Day by day death and New cases + Percentage

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
© 2022 GitHub, Inc.
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
