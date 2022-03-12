-- Below are the queries used to represent data of "WORLD COVID SITUATION AS OF 20th FEBRUARY" in Tableau. 


-- percentage of deaths across world 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from CovidStatusGlobal..CovidDeath
where continent is not null 
order by 1,2



-- death count across all world disctinctly continent wise.

-- Excluding 'World', 'European Union is part of Europe', and 'International'.

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
from CovidStatusGlobal..CovidDeath
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- Country wise polpulation, highest infection count and percentage of population infected. 

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
from CovidStatusGlobal..CovidDeath
Group by Location, Population
order by PercentPopulationInfected desc


-- similar as above. added date as parameter for measurement. 


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
from CovidStatusGlobal..CovidDeath
Group by Location, Population, date
order by PercentPopulationInfected desc



-- Country wise vaccination

Select death.continent, death.location, death.date, death.population, MAX(vac.total_vaccinations) as PeopleVaccinated
From CovidStatusGlobal..CovidDeath death
Join CovidStatusGlobal..CovidVaccination vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
group by death.continent, death.location, death.date, death.population
order by 1,2,3


-- Global Vaccination

select * 
from CovidStatusGlobal..CovidVaccination
order by 3,4



With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as PeopleVaccinated
From CovidStatusGlobal..CovidDeath death
Join CovidStatusGlobal..CovidVaccination vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
)
Select *, (PeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac

