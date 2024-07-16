

SELECT * 
FROM Portfolio_project.dbo.CovidDeaths
WHERE Continent is not null
ORDER BY 3,4



--SELECT * 
--FROM Portfolio_project.dbo.Covidvaccination
--ORDER BY 3,4

--select Data we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_project.dbo.CovidDeaths
WHERE Continent is not null
ORDER BY 1,2


--looking at total cases vs total deaths
--likelyhood of dieing if you contact covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentageofpopulationinffected
FROM Portfolio_project.dbo.CovidDeaths
where location like '%State%'
WHERE Continent is not null
ORDER BY 1,2

--looking at total cases vs population
--show what percentage of population goy covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as percentageofpopulationinffected
FROM Portfolio_project.dbo.CovidDeaths
--where location like '%Nigeria%'
WHERE Continent is not null
ORDER BY 1,2

-- looking at countries with hih=ghest infection rate comparwed to population

SELECT Location, population, MAX(total_cases) as HigheestInfectionCount, MAX((total_cases/population))*100 as 
percentageofpopulationinffected
FROM Portfolio_project.dbo.CovidDeaths
--where location like '%Nigeria%'
Group By Location, population
WHERE Continent is not null
Order By percentageofpopulationinffected desc


--showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_project.dbo.CovidDeaths
--where location like '%Nigeria%'
WHERE Continent is not null
Group By Location
Order By TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_project.dbo.CovidDeaths
--where location like '%Nigeria%'
WHERE Continent is not null
Group By Continent
Order By TotalDeathCount desc



--GLOBAL NUMBERS

SELECT date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 
as deathpercentage
FROM Portfolio_project.dbo.CovidDeaths
--where location like '%State%'
WHERE Continent is not null
Group By date
ORDER BY 1,2



--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinate
--(RollingPeopleVaccinated/population)*100
From Portfolio_project.dbo.CovidDeaths dea
Join  Portfolio_project.dbo.Covidvaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
   WHERE dea.continent is not null
   Order By 2,3
		

		--USE CTE

With PopvsCac (Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Portfolio_project.dbo.CovidDeaths dea
Join  Portfolio_project.dbo.Covidvaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
   WHERE dea.continent is not null
   --Order By 2,3
   )
   select *, (RollingPeopleVaccinated/population)*100
   From PopvsCac


   --TEMP TABLE 

--DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
   select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Portfolio_project.dbo.CovidDeaths dea
Join  Portfolio_project.dbo.Covidvaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
   --WHERE dea.continent is not null
   --Order By 2,3

 select *, (RollingPeopleVaccinated/population)*100
   From #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Portfolio_project.dbo.CovidDeaths dea
Join  Portfolio_project.dbo.Covidvaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
   WHERE dea.continent is not null
   --Order By 2,3


   select *
   From PercentPopulationVaccinated