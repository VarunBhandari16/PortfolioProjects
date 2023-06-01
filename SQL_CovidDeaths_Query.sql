/*
Covid 19 Data Exploration (Part 1)

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
from PortProject..CovidDeaths
where continent is not null

--Select *
--from PortProject..CovidVacinations

-- Select Data we are going to be use
select Location, date, total_cases, new_cases, total_deaths, population
from PortProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases Vs Total Deaths
-- show likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortProject..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2


--Looking at Total Cases Vs Total Deaths
--shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected	  
from PortProject..CovidDeaths
where location like '%states%'

--Looking at countries with Highest Infection Rate compared to Population
Select location, population,  MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
PercentPopulationInfected 
from PortProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
select Location, MAX(cast(total_deaths as int))  as TotalDeathCount
from PortProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- Let's Break Down With Continent

-- Showing the continents with the highest death count per population.

select location, MAX(cast(total_deaths as int))  as TotalDeathCount
from PortProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS 
-- It shows new_cases, new_deaths per day and death_percentage as well.
select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from PortProject..CovidDeaths
where continent is not null
group by date
order by date

