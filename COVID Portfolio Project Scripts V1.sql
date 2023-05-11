SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT null
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country (USA)

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is NOT null
ORDER BY 1,2


--Looking at the Total Cases vs Population 
--Shows what percentage of population got Covid

SELECT Location, date,Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC


--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is NOT null
GROUP BY continent, location
ORDER BY TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT 



--Showing Continents with highest death counts

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount DESC



--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is NOT null
--GROUP BY date
ORDER BY 1,2



--Looking at total Populations vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3



--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location varchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
--WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated