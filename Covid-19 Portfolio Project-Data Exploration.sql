Select * From
PortfolioProject..CovidDeaths
where continent is not null
Order By 3,4

Select * From
PortfolioProject..Vacination
Order By 3,4

--select data that we are going to use 

Select Location, date,  total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Show likelihood of dying if you contract to your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathinPercent
From PortfolioProject..CovidDeaths
--Where Location like ('%Laos%')  
Where continent is not null
Order by 1,2

--Looking at Total Case vs Population
--Show what percent of population got Covid
Select Location, date, Population,total_cases , (total_cases/population)*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Location like ('%Laos%')
Order by 1,2

--Looking at countries with highest infection rate compared to population 
Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like ('%Laos%')
Group by Location, Population
Order by PercentPopulationInfected desc

--Looking at countries with Highest Death Count per Population 
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Let's break things down by continent 

--Showing continents with Highest Deaths Count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Number 
Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by continent
Order by 1,2


--Looking at Total Population Vs Total Vacination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) Over (Partition By dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..Vacination vac
On dea.location = vac.location
And dea.date = vac.date
Where dea.continent is not null 
Order by 2,3

--Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) Over (Partition By dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..Vacination vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null 
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 From PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) Over (Partition By dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..Vacination vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null 
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

CREATE VIEW PercetPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) Over (Partition By dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..Vacination vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null 
--Order by 2,3

Select * 
From PercetPopulationVaccinated
