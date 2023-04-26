Select *
From PortfolioProject..CovidDeath
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases,new_cases,total_deaths, population
From PortfolioProject..CovidDeath
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Convert total cases and total deaths into FLOAT
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (CAST (total_deaths AS int)/CAST(total_cases AS int))*100 AS DeathPercentage
From PortfolioProject..CovidDeath
Where location like '%states%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got covid

Select Location, date, population,total_cases, (CAST (total_cases AS int)/population)*100 AS CasePercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
order by 1,2

-- Looking at Countries with highest infection Rate compared to Population

Select Location,population,MAX(total_cases) AS HighestInfectionCount, MAX((CAST (total_cases AS int)/population))*100 AS PercentagePopulationInfected
From PortfolioProject..CovidDeath
--Where location like '%states%'
Group by Location,population
order by PercentagePopulationInfected desc

-- Showing Countries with Highest Death Count per Population

--LET'S BREAK THINGS BY CONTINENT



Select continent,MAX(CAST(total_deaths as int)) AS ToalDeathCount
From PortfolioProject..CovidDeath
--Where location like '%states%'
where continent is not null
Group by continent
order by ToalDeathCount desc

 -- Showing continents with highest death count per population

 Select continent,location,population,MAX(total_deaths) AS TotalDeathCount, MAX((CAST (total_deaths AS int)/population))*100 AS PercentageTotalDeathCount
From PortfolioProject..CovidDeath
--Where location like '%states%'
where continent is not null
Group by continent,location,population
order by PercentageTotalDeathCount desc


--GLOBAL NUMBERS

Select  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
WHERE continent is not null
--group by date
order by 2,3


-- Looking at total population vs vaccinations

select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS float)) over(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
	--where dea.continent is not null
	order by 2,3


	-- Use CTE


	with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
	as
(
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS float)) over(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
	where dea.continent is not null
	--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
from PopvsVac



--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated

Create Table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
	
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS float)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
--where dea.continent is not null
--	order by 2,3



--Creating View to Store data for Later Visualization

CREATE View PercentVaccinated  AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS float)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
From PercentVaccinated ;

