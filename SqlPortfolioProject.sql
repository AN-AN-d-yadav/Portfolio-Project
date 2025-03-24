--select * 
--from [Portfolio Project]..CovidVaccinated$
--order by 3,4

--select * 
--from [SQL TUTORIAL]..CovidDeaths$
--order by 3,4


select location,date, total_cases, new_cases,total_deaths,population
from [SQL TUTORIAL]..CovidDeaths$
order by 1,2

--looking at total cases vs total deaths 

select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as dyingPercentage
from [SQL TUTORIAL]..CovidDeaths$
where loCATION LIKE '%India%'
order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got infected

select location,date,population,total_cases,(total_cases/population)*100 as infectedpercentage
from [SQL TUTORIAL]..CovidDeaths$
where loCATION LIKE '%India%'
order by 1,2

--looking at countries with highest infected perecentage 

select location,population,MAX(total_cases) as HighestInfectedCount,
max((total_cases/population))*100 as infectedpercentage,
max((total_deaths/total_cases))*100 as DeathPercentage
from [SQL TUTORIAL]..CovidDeaths$
--where loCATION LIKE '%states%'
where continent is null 
group by location,population
order by infectedpercentage desc, DeathPercentage desc

-- lets break things down by continent 

select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from [SQL TUTORIAL]..CovidDeaths$
where continent is  null
group by location 
order by TotalDeathCount desc 

-- lets get the global data of death

select 
sum(total_cases) as total_cases ,
sum( cast(total_deaths as int )) as total_deaths,
sum((total_deaths/total_cases)*100) as DeathPercentage
from [SQL TUTORIAL]..CovidDeaths$
--group by date

-- join two tables
-- finding total population vaccinated

--using cte 


with popvsvac( continent,location, date,population, new_vaccinations,RollingPeopleVaccinated) as(

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population) we cant use a newly created column
from [SQL TUTORIAL]..CovidDeaths$ dea 
join [Portfolio Project]..CovidVaccinated$ vac
on dea.location=vac.location and dea.date=vac.date
)

select *, (RollingPeopleVaccinated/population)*100 from popvsvac


--using temp table 
 
 
 drop table if exists #percentpopulationvaccinated
 create table #percentpopulationvaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric ,
 RollingPeopleVaccinated numeric
 )
 insert into #percentpopulationvaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population) 
from [SQL TUTORIAL]..CovidDeaths$ dea 
join [Portfolio Project]..CovidVaccinated$ vac
on dea.location=vac.location and dea.date=vac.date

select *, (RollingPeopleVaccinated/population)*100 from #percentpopulationvaccinated


--> creating a VIEW 

create view PercentPopulationVaccinated as
  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population) 
from [SQL TUTORIAL]..CovidDeaths$ dea 
join [Portfolio Project]..CovidVaccinated$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select *from PercentPopulationVaccinated