select * 
from [Portfolio-Project]..Covid_Deaths$ 
where continent is not null
order by 3,4

--select * 
--from [Portfolio-Project]..Covid_Vaccinations$
--order by 3,4

select location , date , total_cases , new_cases , total_deaths , population
from [Portfolio-Project]..Covid_Deaths$
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths

select location , date , total_cases ,  total_deaths , round((total_deaths / total_cases) * 100 , 2) as DeathPercentage
from [Portfolio-Project]..Covid_Deaths$
--where location like '%India%'
where continent is not null
order by 1,2

-- As of yesterday , out of 2.7 crore cases and over 3 lakh deathes with a death percentage of 1.17%


-- Looking at total cases vs population
select location , date , total_cases ,  population , round((total_cases / population) * 100 , 2) as CasesVsPopulation
from [Portfolio-Project]..Covid_Deaths$
--where location like '%India%'
where continent is not null
order by 1,2

-- Therefore 2% of India's population has been contacted with the virus as of 29th May 2021

-- Looking at Countries with highest infection rate comapred to population
select location ,  max(total_cases) as HighestInfectionCount ,  population , round((max(total_cases) / population) * 100 , 2) as MaxCasesVsPopulation
from [Portfolio-Project]..Covid_Deaths$
where continent is not null
group by population,location
order by MaxCasesVsPopulation desc

-- Showing Countries with highest Death Count per Population
select location ,  max(cast(total_deaths as int)) as TotalDeathCount 
from [Portfolio-Project]..Covid_Deaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- Highest Death count By Continent
select continent ,  max(cast(total_deaths as int)) as TotalDeathCountContinent 
from [Portfolio-Project]..Covid_Deaths$
where continent is not null
group by continent
order by TotalDeathCountContinent desc

-- Global Numbers
select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths ,  round((sum(cast(new_deaths as int)) / sum(new_cases)) * 100 , 2) as DeathPercentageGlobal
from [Portfolio-Project]..Covid_Deaths$
--where location like '%India%'
where continent is not null
--group by date
order by 1,2

-- Total Pop vs Vaccinations
--USING CTE
with PopVsVacc(Continent , Location , Date , Population , New_Vaccinations ,  RollingSumVacc)
as
(
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as RollingSumVacc
from [Portfolio-Project]..Covid_Deaths$ dea
Join [Portfolio-Project]..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and --dea.location like '%India%'
--order by 2,3
)
select * , round((RollingSumVacc / Population)*100 , 2) as PercentVaccinated
from PopVsVacc

-- Using Temp Table
drop table if exists #PercentVaccinated
Create Table #PercentVaccinated
(
Continent nvarchar(255) , 
Location nvarchar(255) , 
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentVaccinated
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as RollingSumVacc
from [Portfolio-Project]..Covid_Deaths$ dea
Join [Portfolio-Project]..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location like '%India%'
--order by 2,3

select * , round((RollingPeopleVaccinated / Population)*100 , 2) as PercentVaccinated
from #PercentVaccinated

-- Creating Views to store data for later viz
Create View PercentVaccinated as 
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as RollingSumVacc
from [Portfolio-Project]..Covid_Deaths$ dea
Join [Portfolio-Project]..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location like '%India%'
--order by 2,3

select * 
from PercentVaccinated

Create View GlobalNumbers as
select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths ,  round((sum(cast(new_deaths as int)) / sum(new_cases)) * 100 , 2) as DeathPercentageGlobal
from [Portfolio-Project]..Covid_Deaths$
where continent is not null
--group by date
--order by 1,2

create View TotalDeathCountContinent as
select continent ,  max(cast(total_deaths as int)) as TotalDeathCountContinent 
from [Portfolio-Project]..Covid_Deaths$
where continent is not null
group by continent
--order by TotalDeathCountContinent desc

create View TotalDeathCount as 
select location ,  max(cast(total_deaths as int)) as TotalDeathCount 
from [Portfolio-Project]..Covid_Deaths$
where continent is not null
group by location
--order by TotalDeathCount desc

create View MaxCasesVsPopulation as
select location ,  max(total_cases) as HighestInfectionCount ,  population , round((max(total_cases) / population) * 100 , 2) as MaxCasesVsPopulation
from [Portfolio-Project]..Covid_Deaths$
where continent is not null
group by population,location
--order by MaxCasesVsPopulation desc

create View CasesVsPopulation as 
select location , date , total_cases ,  population , round((total_cases / population) * 100 , 2) as CasesVsPopulation
from [Portfolio-Project]..Covid_Deaths$
--where location like '%India%'
where continent is not null
--order by 1,2

create View DeathPercentage as
select location , date , total_cases ,  total_deaths , round((total_deaths / total_cases) * 100 , 2) as DeathPercentage
from [Portfolio-Project]..Covid_Deaths$
--where location like '%India%'
where continent is not null
--order by 1,2