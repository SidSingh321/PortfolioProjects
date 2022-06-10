/*
COVID DATA EXPLORATION

SKILLS APPLIED:  Window Function, Aggregate Functions,Joins, CTE's, Temp Tables, Creating Views, Checking available views, Dropping Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

--Starting Query with required columns

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contact covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageofDeath
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Show what percentage of population got covid
SELECT location, date, population, total_cases,  (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionRate,  Max((total_cases/population))*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location,population
order by InfectedPercentage desc

--Showing countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location
order by TotalDeathCount desc

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
Group by location
order by TotalDeathCount desc

--Showing continent with Highest Death Count per Population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
--Showing the data for the whole world grouped by date.

SELECT date, SUM(new_cases) as Total_newcases, SUM(cast(new_deaths as int)) as Total_newdeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by date
order by 1,2

--Showing the no. of totaldeaths and Death Percentage due to covid in entire world.

SELECT SUM(new_cases) as Total_newcases, SUM(cast(new_deaths as int)) as Total_newdeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

--Lookin at Total Population vs Vaccinations(Using Join)
--How may people out of whole population in the world are vaccinated

SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..CovidVaccinations as Vac
ON Dea.location = Vac.location
and Dea.date = Vac.date
WHERE Dea.continent is not null
order by 2,3

--Rolling count
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as bigint)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingCountVaccination
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..CovidVaccinations as Vac
ON Dea.location = Vac.location
and Dea.date = Vac.date
WHERE Dea.continent is not null
order by 2,3

--Using CTE (because we can't use RollingCountVaccination/population * 100 directly)

With PopvsVac (continent,location,date,population,new_vaccinations,RollingCountVaccination)
as
(
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as bigint)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingCountVaccination
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..CovidVaccinations as Vac
ON Dea.location = Vac.location
and Dea.date = Vac.date
WHERE Dea.continent is not null
)
SELECT *, (RollingCountVaccination/population)*100 as RollingVaccinationPercentage
FROM PopvsVac

--Using Temp Table (because we can't use RollingPeopleVAccinated/population * 100 directly)
DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingCountVaccination numeric
)
Insert Into PercentPopulationVaccinated
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as bigint)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingCountVaccination
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..CovidVaccinations as Vac
ON Dea.location = Vac.location
and Dea.date = Vac.date
WHERE Dea.continent is not null
and Dea.location = 'Albania'

SELECT *, (RollingCountVaccination/population)*100 as RollingVaccinationPercentage
FROM PercentPopulationVaccinated

--creating views to store data for later Visualization
Go
create view View_1 as
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as bigint)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..CovidVaccinations as Vac
ON Dea.location = Vac.location
and Dea.date = Vac.date
WHERE Dea.continent is not null

SELECT *
FROM View_1

--Checking the available view.
SELECT 
OBJECT_SCHEMA_NAME(o.object_id) schema_name,o.name
FROM
sys.objects as o
WHERE
o.type = 'V';

--Dropping all the available view
DROP VIEW IF EXISTS dbo.PercentPopulationVaccinated;
DROP VIEW IF EXISTS dbo.PopulationVaccinatedPercent;







