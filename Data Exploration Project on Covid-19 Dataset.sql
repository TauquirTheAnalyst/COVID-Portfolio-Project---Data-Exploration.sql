
select * 
from CovidDeath
where continent is not null 
order by 3, 4

--select  location,sum(new_cases) as Total_cases  , sum(convert(int,new_deaths))
--from   CovidDeath
--where location = 'Saudi Arabia'
--group by location 

select * 
from CovidVaccination
where location = 'India'
order by 3, 4

-- select the data that we are going to be using 

select Location , date , total_cases , new_cases , total_deaths , population 
from CovidDeath
--where location = 'India' 
where continent is not null 
order by 1, 2

-- Looking at Total Cases vs Total Death
-- SHows likelihood of dying if you contract covid in your country 

select Location , date , total_cases , total_deaths ,
                  (total_deaths/total_cases)*100 DeathPercentage 
from CovidDeath
where location Like '%India%' 
and continent is not null 
order by 1, 2

-- Looking at Totalcases vs Population 
-- Show what percentage of population got Covid 

select Location , date , population , total_cases  , 
                  (total_cases/population)*100 PrcentPopulationInfected  
from CovidDeath
--where location Like 'Indi%' 
order by 1, 2

-- Looking at countries with Highest Infection Rate compared to population 

select Location , population , max(total_cases) as HighestInfectionCOunt  , 
                  max((total_cases/population))*100 PrcentPopulationInfected
from CovidDeath
--where location Like 'Indi%'
group by Location , population
order by PrcentPopulationInfected desc

-- Showing Countries With Highest Death Count Per Population 

select Location , max(cast(total_deaths as int)) as HighestDeathCount 
from CovidDeath
--where location Like 'Afg%'
where continent is not null 
group by Location 
order by HighestDeathCount desc 

-- LET's BREAK THINGS DOWN BY CONTINENTS 

select continent , max(cast(total_deaths as int)) as HighestDeathCount 
from CovidDeath
--where location Like 'Afg%'
where continent is not null 
group by continent 
order by HighestDeathCount desc 

-- Showing the continent with the highest death count per poopulation 

select continent , max(cast(total_deaths as int)) as HighestDeathCount 
from CovidDeath
--where location Like 'Afg%'
where continent is not null 
group by continent 
order by HighestDeathCount desc

-- Global Numbers 

select date , sum(new_cases) as Total_Cases , sum(cast(new_deaths as int)) as Total_Death, 
                  (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage 
                  --, total_deaths ,
                  --(total_deaths/total_cases)*100 DeathPercentage , 
from CovidDeath
--where location Like '%states%' 
Where continent is not null 
group by date 
order by 1, 2

------------------------------------------------------------------------------

select  sum(new_cases) as Total_Covid_Cases_Accros_World , sum(cast(new_deaths as int)) as Total_Covid_Death_Accros_world, 
                  (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentageOfCovidAccrosWorld 
                  --, total_deaths ,
                  --(total_deaths/total_cases)*100 DeathPercentage  
from CovidDeath
--where location Like '%states%' 
Where continent is not null  
order by 1, 2



-- Looking at Total Population Vs Vaccination 

select * from CovidVaccination

select  dea.continent , dea.Location ,dea.date, dea.population , vac.new_vaccinations
, sum(convert(bigint , vac.new_vaccinations)) over(order by dea.location,
  dea.date) as RunningPeopleVaccinated 
  
from CovidDeath as dea 
join  CovidVaccination as vac 
     on dea.date = vac.date
	 and dea.location = vac.location
where dea.continent is not null  and dea.Location like 'India'
order by 2,3


--use CTE 

with PopvsVac (continent,Location,date,population,new_vaccinations,RunningPeopleVaccinated)
as
(
select  dea.continent , dea.Location ,dea.date, dea.population , vac.new_vaccinations
, sum(convert(bigint , vac.new_vaccinations)) over(order by dea.location,
  dea.date) as RunningPeopleVaccinated 
  
from CovidDeath as dea 
join  CovidVaccination as vac 
     on dea.date = vac.date
	 and dea.location = vac.location
where dea.continent is not null  --and dea.Location like 'India'
--order by 2,3
)
select * , (RunningPeopleVaccinated/population)*100
from PopvsVac


-- TEMP TABLE 

drop table if exists  #PercentPopulationVaccinated

create table #PercentPopulationVaccinated 
(
Continent nvarchar(255) ,
Location nvarchar(255) , 
date datetime,
population numeric ,
new_vaccinations numeric , 
RunningPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select  dea.continent , dea.Location ,dea.date, dea.population , vac.new_vaccinations
, sum(convert(bigint , vac.new_vaccinations)) over(Partition by dea.location order by dea.location,
  dea.date) as RunningPeopleVaccinated 
  
from CovidDeath as dea 
join  CovidVaccination as vac 
     on dea.date = vac.date
	 and dea.location = vac.location
--where dea.continent is not null  --and dea.Location like 'India'
--order by 2,3

select * , (RunningPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
where Location = 'Kenya'
order by 2,3