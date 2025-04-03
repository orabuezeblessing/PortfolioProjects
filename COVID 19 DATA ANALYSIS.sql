Select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3, 4

--Select *
--from PortfolioProject..CovidVaccination$
--order by 3, 4
--Select data that we are going to be using


Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_cases/NULLIF(total_deaths, 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total Cases vs population
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
order by 1,2

--Looking at countries with Highest Infection Rate Compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by population, location
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing Continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/(SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
order by 1,2


--Looking at total population vs vaccination
with PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea 
join PortfolioProject..CovidVaccination$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea 
join PortfolioProject..CovidVaccination$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea 
join PortfolioProject..CovidVaccination$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated