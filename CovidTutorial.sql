select * 
From PortfolioProject..['Covid Data$']
where continent is not null
order by 3,4

/*select * 
From PortfolioProject..['Covid Vaccination$']
where continent is not null
order by 3,4*/

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['Covid Data$']
order by 1,2


--Looking total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_Cases)*100 as DeathPercentage
From PortfolioProject..['Covid Data$']
where location like '%India%'
and continent is not null
order by 1,2

--Looking at total case vs population
--shows what percentage of population got covid

select location, date,  population, total_cases, (total_Cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['Covid Data$']
--where location like '%India%'
order by 1,2


--Looking at countries with Highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_Cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['Covid Data$']
--where location like '%India%'
Group by location, population
order by PercentPopulationInfected desc


--Showing Countries with Highest death count per population
select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Data$']
--where location like '%India%'
where continent is not null
Group by location
order by TotalDeathCount desc


--LET's BREAK THINGS DOWN BY CONTINENT
select Continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Data$']
--where location like '%India%'
where continent is null
Group by location
order by TotalDeathCount desc


--Showing continent with highest death count per population
select Continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Data$']
--where location like '%India%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100  as DeathPercentage
From PortfolioProject..['Covid Data$']
--where location like '%India%'
where continent is not null
--group by date
order by 1,2


--Looking at total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Data$'] dea
Join PortfolioProject..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

--USE CTE

With PopVsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Data$'] dea
Join PortfolioProject..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
continent nvarchar(256),
Location nvarchar(256),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rollingpeoplevaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Data$'] dea
Join PortfolioProject..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visulaizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Data$'] dea
Join PortfolioProject..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

select * 
From PercentPopulationVaccinated