select * 
from portfolioProject. .CovidDeaths 
order by 3,4

--select * 
--from portfolioProject. .CovidVaccinations 

select Location, date, total_cases, new_cases, total_deaths, population
from portfolioProject. .CovidDeaths
ORDER BY 1,2



-- Total cases vs Total Deaths
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from portfolioProject. .CovidDeaths
where location like '%states%'
order by 1,2



---- Total case vs Population 
select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from portfolioProject. .CovidDeaths
ORDER BY 1,2

-- countries with highest infection rates compared to population
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
from portfolioProject. .CovidDeaths
Group by location, population
ORDER BY PercentagePopulationInfected desc



-- Countries with highest death counts per population 

select location, max(CAST(Total_deaths AS INT)) as TotalDeathCount
from portfolioProject. .CovidDeaths 
where continent is not null
group by location, population
ORDER BY TotalDeathCount desc

select continent, max(cast(Total_deaths AS INT)) AS TotalDeathCount
from portfolioProject. .CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--- GLOBAL NUMBERS --

select sum(new_cases) as totalCases,  sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolioProject. .CovidDeaths 
where continent is not null
--group by date 
order by 1,2 


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from portfolioProject. .CovidDeaths dea
join  portfolioProject. .CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
order by 2,3
 
  

  create table #PercentagePopulationVaccinated
  (
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioProject. .CovidDeaths dea join portfolioProject. .CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 as '%Vaccinated'
from #PercentagePopulationVaccinated


create view PercenPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from portfolioProject. .CovidDeaths dea
join  portfolioProject. .CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
 