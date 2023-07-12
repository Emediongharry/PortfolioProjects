--Select *
--FROM PortfolioProject..CovidDeaths$
--WHERE continent is not NULL
--order by 3,4


--Select *
--FROM PortfolioProject..CovidVaccinations$
--order by 3,4

--Select Data for use

Select Location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

--Total Cases Vs Total Deaths

Select Location, date, CAST(total_cases as int) AS total_cases, CAST(total_deaths AS int) AS total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
WHERE location LIKE '%Afr%'
order by 1,2

--Looking at Total Cases vs Population

Select Location, date, population, CAST(total_cases as int) AS total_cases, (total_cases/population)*100 AS CovidPopPercentage
From PortfolioProject..CovidDeaths$
WHERE location LIKE '%Afr%' AND continent is not NULL
order by 1,2

--Countries with high infection rate compared to population

Select Location, population, MAX(CAST(total_cases as int)) AS HighestTotalCases, MAX((total_cases/population))*100 AS PercentPopInfected
From PortfolioProject..CovidDeaths$
--WHERE location LIKE '%Afr%'
GROUP BY Location, population
order by PercentPopInfected DESC

--Countries with highest death count per population

Select Location, MAX(CAST(total_deaths as int)) AS MaxTotalDeath
From PortfolioProject..CovidDeaths$
--WHERE location LIKE '%Afr%'
WHERE continent is not NULL
GROUP BY Location
order by MaxTotalDeath DESC


--By continent

--Continent with highest death count per populaton

Select continent, MAX(CAST(total_deaths as int)) AS MaxTotalDeath
From PortfolioProject..CovidDeaths$
--WHERE location LIKE '%Afr%'
WHERE continent is not NULL
GROUP BY continent
order by MaxTotalDeath DESC


--GLOBAL NUMBERS

Select 
SUM(CAST(new_cases as int)) AS total_cases, 
SUM(CAST(new_deaths AS int)) AS total_deaths , 
  CASE
    WHEN SUM(CAST(new_cases AS int)) = 0 THEN 0
    ELSE (SUM(CAST(new_deaths AS int)) / NULLIF(SUM(CAST(new_cases AS float)), 0)) * 100 END AS DeathPercentage

From PortfolioProject..CovidDeaths$ 

--WHERE location LIKE '%Afr%'
WHERE continent is not NULL
order by 1,2



--Total population Vs vaccinations

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location,
	dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location=vac.location
	and dea.date = vac.date
	WHERE dea.continent is not NULL
order by 2,3


--USE CTE
With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location,
	dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location=vac.location
	and dea.date = vac.date
	WHERE dea.continent is not NULL
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopVsVac




--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
) 

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location,
	dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location=vac.location
	and dea.date = vac.date
	WHERE dea.continent is not NULL
--order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating view to store data for visualization
USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinated as

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location,
	dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location=vac.location
	and dea.date = vac.date
	WHERE dea.continent is not NULL
--order by 2,3

Select*
FROM PercentPopulationVaccinated