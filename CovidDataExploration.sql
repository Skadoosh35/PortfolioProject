/*

Covid 19 Data Exploration as of Jan 31, 2023.

Skills used: Joins, CTE's, Temp Tables, Windows Function, Aggregate Functions, Creating Views, Converting Data Types
 

*/

SELECT * 
FROM PortfolioProject..CovidDeath
WHERE continent is not null
ORDER BY location, date 



SELECT * 
FROM PortfolioProject..CovidVaccination 
WHERE continent is not null
ORDER BY location, date

-- Select Data that will be used to start with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeath 
ORDER BY location, date

-- A country like Afghanistan had deaths almost a month after the first case.
-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contracted covid in your country

SELECT location, date, total_cases, total_deaths, (100*total_deaths/total_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeath 
WHERE continent is not null
ORDER BY location, date

-- Looking into specific Country's Death Percentage
SELECT location, date, total_cases, total_deaths, (100*total_deaths/total_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeath 
WHERE location = 'Philippines'
ORDER BY location, date

-- Looking at Total Cases vs Population
-- Shows what percentage of the population got covid

SELECT location, date, Population, total_cases, (100*total_cases/population) AS InfectionRate
FROM PortfolioProject..CovidDeath 
WHERE location = 'Philippines'
ORDER BY location, date

-- Looking at Countries with greatest infection rates


SELECT location, Population, total_cases, (100*total_cases/population) AS PopulationInfected
FROM PortfolioProject..CovidDeath 
ORDER BY InfectionRate DESC

--Showing Countries with Highest Death Count per Population

SELECT location, Population, total_deaths, (100*total_deaths/population) AS MortalityRate
FROM PortfolioProject..CovidDeath 
ORDER BY MortalityRate DESC


-- In order for countries to not repeat themselves, lets change the query

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX(100*total_cases/population) as PopulationInfected
FROM PortfolioProject..CovidDeath 
GROUP BY location, Population
ORDER BY PopulationInfected DESC


--Showing Countries with Highest Death Count per Population

SELECT location, Population, total_deaths, (100*total_deaths/population) AS MortalityRate
FROM PortfolioProject..CovidDeath 
ORDER BY MortalityRate DESC

--Showing Countries with Highest Death Count Percentage per Population

SELECT location, MAX(population) as new_population, MAX(cast(total_deaths as int)) as TotalDeaths, MAX(100*total_deaths/population) as PercentDeath
FROM PortfolioProject..CovidDeath 
WHERE continent is not NULL 
GROUP BY location
ORDER BY PercentDeath DESC


-- Breaking down deaths per continent

SELECT location, population, MAX(cast(total_deaths as int)) AS TotalDeaths, 100 * (MAX(cast(total_deaths as int))/population) AS PercentDeathContinent
FROM PortfolioProject..CovidDeath 
WHERE continent is NULL AND location = 'Europe' OR location = 'North America' OR location = 'South America' OR location = 'Oceania' OR location = 'Africa' OR location = 'Asia'  
GROUP BY location, population
ORDER BY TotalDeaths DESC

--Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) AS total_deaths, 100 * SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE continent is not null AND total_cases is not null 
GROUP BY date
ORDER BY total_cases, total_deaths

-- Total Population vs Vaccination
-- Shows Percentage of Population that has received at least one Covid Vaccine

SELECT c2.continent, c2.location, c2.date, c2.population, c1.new_vaccinations, 
SUM(CONVERT(bigint, c1.new_vaccinations)) OVER (PARTITION BY c2.location ORDER BY c2.date) AS RollingVaccination --, RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidVaccination c1
JOIN PortfolioProject..CovidDeath c2
	ON c1.location = c2.location
	AND c1.date = c2.date
WHERE c2.continent is not null --AND new_vaccinations is not null
ORDER BY continent, location, date


--Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccination) 
AS
(
SELECT c2.continent, c2.location, c2.date, c2.population, c1.new_vaccinations, 
SUM(CONVERT(bigint, c1.new_vaccinations)) OVER (PARTITION BY c2.location ORDER BY c2.date) AS RollingVaccination --(RollingVaccination/population)*100 
FROM PortfolioProject..CovidVaccination c1
JOIN PortfolioProject..CovidDeath c2
ON c1.location = c2.location
AND c1.date = c2.date
WHERE c2.continent is not null
--ORDER BY continent, location, date
)

SELECT *,  100 * (RollingVaccination/population) AS VaccinationRate
FROM PopvsVac
ORDER BY VaccinationRate

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingVaccination numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT c2.continent, c2.location, c2.date, c2.population, c1.new_vaccinations, SUM(CONVERT(bigint, c1.new_vaccinations)) OVER (PARTITION BY c2.location ORDER BY c2.date) AS RollingVaccination
FROM PortfolioProject..CovidVaccination c1
JOIN PortfolioProject..CovidDeath c2
ON c1.location = c2.location
AND c1.date = c2.date

SELECT *, (RollingVaccination/Population)*100 AS VaccinationRate
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT c2.continent, c2.location, c2.date, c2.population, c1.new_vaccinations, SUM(CONVERT(bigint, c1.new_vaccinations)) OVER (PARTITION BY c2.location ORDER BY c2.date) AS RollingVaccination
FROM PortfolioProject..CovidVaccination c1
JOIN PortfolioProject..CovidDeath c2
ON c1.location = c2.location
AND c1.date = c2.date
WHERE c2.continent is not null

SELECT *
FROM PercentPopulationVaccinated