/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject1..CovidDeaths$
WHERE continent is not NULL 
order by 3,4


-- Select Data that will be used 
-- Allows us to explore the data we'd like from a huge dataset 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Displays likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM PortfolioProject1..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases Vs Population
-- Displays what percentage of the population has contracted Covid. 
SELECT Location, date, total_cases, Population, (total_cases/population)*100 as CovidPopPercentage 
FROM PortfolioProject1..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Countries with highest Infection Rate compared to Population 

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM PortfolioProject1..CovidDeaths$
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-- Countries with the Highest Death Count per Population 
-- Note: total deaths must be casted as an integer 
-- Note: Locations like South America and Africa should not be displayed 

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
WHERE continent is not NULL 
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Continents with the Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
WHERE continent is NULL 
GROUP BY location
ORDER BY TotalDeathCount desc


-- Showing continents with the highest death count per population 

 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
WHERE continent is NULL 
GROUP BY location
ORDER BY TotalDeathCount desc


-- Global Numbers 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage 
FROM PortfolioProject1..CovidDeaths$
WHERE continent is not NULL 
ORDER BY 1,2



-- Viewing Total Population vs Vaccinations
-- Displays Percentage of Population that has received at least one Covid Vaccine 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
	AS RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths$ dea
LEFT Join PortfolioProject1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE to perform calculation on Partition By in previous entry 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 AS PercentagePopulationVaccinated
From PopvsVac


-- TEMP TABLE 

DROP TABLE if exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)   



INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentagePopulationVaccinated
From #PercentPopulationVaccinated



-- Creating View to store date for later visualizations 

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL 

SELECT *
FROM PercentPopulationVaccinated