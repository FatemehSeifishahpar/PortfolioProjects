select *
from PortfolioProject..covidDeath
order by 3,4

select *
from PortfolioProject..covidVaccination
order by 3,4

-- Select data that we are going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covidDeath
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covidDeath
where location like '%states%'
order by 1,2

-- looking at total cases vs population
-- what percentage got Covid
select Location, date, total_cases, population, (total_cases/population)*100 as infectPercentage
from PortfolioProject..covidDeath
--where location like '%states%'
order by 1, 2

-- looking at the countries with highest infection rate compared to population
select Location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as percentPopulationInfected
from PortfolioProject..covidDeath
group by location, population
order by percentPopulationInfected desc



select Location, max(cast(total_deaths as int)) as MaxtotalDeathCount
from PortfolioProject..covidDeath
where continent is not null
group by location
order by MaxtotalDeathCount desc


-- BRIVKING DOWN THINGS BY CONTINENT

-- showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as MaxtotalDeathCount
from PortfolioProject..covidDeath
where continent is not null
group by continent
order by MaxtotalDeathCount desc


select location, max(cast(total_deaths as int)) as MaxtotalDeathCount
from PortfolioProject..covidDeath
where continent is null
group by location
order by MaxtotalDeathCount desc


-- Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..covidDeath
-- where location like '%states%'
where continent is not null
group by date
order by 1,2

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as numeric(12, 0))) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..covidDeath dea
join PortfolioProject..covidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as numeric(12, 0))) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..covidDeath dea
join PortfolioProject..covidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as numeric(12, 0))) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..covidDeath dea
join PortfolioProject..covidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for future vidualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as numeric(12, 0))) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..covidDeath dea
join PortfolioProject..covidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *
from PercentPopulationVaccinated

