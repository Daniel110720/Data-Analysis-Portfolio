/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
order by 3,4


--select the data we are going to use

select location, date,total_cases, new_cases, total_deaths, population
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
order by 1,2

--looking at the total cases vs total deaths
-- shows the likelihood of dying if you got covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
where continent is not null
AND location like '%states%'
order by 1,2

--looking at the Total Cases vs the Population
-- shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From [Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
From [Portfolio Project].dbo.CovidDeaths
group by location, population
order by PercentagePopulationInfected desc

--showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--lets break things down by continent

select location, max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc 

--global numnbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
--where location like '%states%'
order by 1,2

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

--use cte

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
--Where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int, vac.new_vaccinations)) over(Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated