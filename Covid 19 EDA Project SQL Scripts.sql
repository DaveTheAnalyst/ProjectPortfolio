--COVID DEATHS INFO TABLE
SELECT* 
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4


--COVID VACCINATION INFO TABLE
Select *
From PortfolioProject..CovidVaccinations
order by 3,4


--SELECTING COLUMNS FOR EDA
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where location is not null
order by 1,2


--TOTAL CASES VS DEATHS AND DEATH% ON CONTRACTING COVID
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
where location is not null
order by 1,2


--ANALYZING DAILY NEW COVID CASES AND % OF DEATH IF COVID IS CONTRACTED IN NIGERIA
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%nigeria%'
and continent is not null
order by 1,2


--ANALYZING % OF COUNTRY POPULATION THATS HAS CONTRACTED COVID
Select location, date, population, total_cases, (total_cases/population) * 100 PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
order by 1,2


--ANALYZING COUNTRIES WITH INFECTION COUNT AND % OF POPULATION INFECTED
Select location, population, max(total_cases) as HighestInfectionCount,  max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc


--ANALYZING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
Select location,  max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by location
order by TotalDeathCount desc



Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
where continent is null
group by location
order by TotalDeathCount desc 


--ANALYZING COUNTINENTS WITH HIGHEST DEATH COUNT PER POPULATION 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc


--ANALYZING TOTAL OF NEW CASES WORLDWIDE PER DAY AND DEATH PERCENTAGE
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_death, sum(convert(bigint, new_deaths))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
group by date
order by 1,2

--ANALYZING TOTAL CASES VS TOTAL DEATH & PERCENTAGE OF WORLD POPULATION THAT DIED
Select sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_death, sum(convert(bigint, new_deaths))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
--group by date
order by 1,2


--JOINING COVID DEATHS AND VACCINATION INFO TABLES
Select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


--ANALYZING POPULATION VS VACCINATION COUNT
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations--, (vac.people_vaccinated/dea.population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--ANALYZING ROLLING COUNT OF DAILY VACCINES ADMINISTERED
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE RollingPeopleVaccinated COLUMN
with PopvsVac (continent, location, date, population,  new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE
Create Table #PercPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vacinations numeric,
rollingpeoplevaccinated numeric
)
Insert into #PercPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
from #PercPopulationVaccinated



DROP Table if exists #PercPopulationVaccinated
Create Table #PercPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vacinations numeric,
rollingpeoplevaccinated numeric
)
Insert into #PercPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100 --RollingPeopleVaccinated shows an error cos we can't use a column that you just created to use in the next. we will create a CTE or TEMP TABLE
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
from #PercPopulationVaccinated



--CREATING VIEWS FOR VISUALS
Create View PercPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create View TotalDeathCountPerContinent as 
Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
where continent is not null
group by continent
--order by TotalDeathCount desc


Select *
from PercPopulationVaccinated

Select *
from TotalDeathCountPerContinent