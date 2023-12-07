--select *
--from portfolio1..CovidVaccination$
--order  by 3,4

select *
from portfolio1..CovidDeaths$
where continent is not null
order  by 3,4

select Location,date,total_cases,new_cases,total_deaths
from portfolio1..CovidDeaths$
where continent is not null
order  by 1,2

--total cases vs total deaths
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from portfolio1..CovidDeaths$
where location like '%states%'
order  by 1,2


--looking at total  cases vs population
select Location,date,population,total_cases,(total_cases/population)*100 as percentpopulationinfected
from portfolio1..CovidDeaths$
where continent is not null
--where location like '%states%'
order  by 1,2

--countries with highest infections
select Location,population,MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as PercentPopulationInfected
from portfolio1..CovidDeaths$
--where location like '%states%
where continent is not null
Group by location,population
order  by PercentPopulationInfected desc

--countries with highestdeathpopulation
select Location,MAX(cast(total_deaths as int)) as totalDeathsCount
from portfolio1..CovidDeaths$
where continent is not null
--where location like '%states%
Group by location
order  by  totalDeathsCount desc


--lets break things up  by continent
--showing continent with highestdeaths

select continent,MAX(cast(total_deaths as int)) as totalDeathsCount
from portfolio1..CovidDeaths$
where continent is not null
--where location like '%states%
Group by continent
order  by  totalDeathsCount desc



--global numbers

select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from portfolio1..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order  by 1,2

--looking at total population vs vaccination
with PopvsVac(continent,loaction,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeoplevaccinated

from portfolio1..CovidDeaths$ dea
join portfolio1..CovidVaccination$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rollingpeoplevaccinated/population)*100
from PopvsVac

--temp table
Drop Table if exists #PerecentpopulationVaccinated1
Create Table #PerecentpopulationVaccinated1
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeoplevaccinated numeric
)
Insert into #PerecentpopulationVaccinated1
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeoplevaccinated

from portfolio1..CovidDeaths$ dea
join portfolio1..CovidVaccination$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(Rollingpeoplevaccinated/population)*100
from #PerecentpopulationVaccinated1



--creating view to store data for later visualization
Create View PerecentpopulationVaccinated1 as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeoplevaccinated

from portfolio1..CovidDeaths$ dea
join portfolio1..CovidVaccination$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

     



