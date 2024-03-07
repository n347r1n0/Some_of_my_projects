select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVac
--order by 3,4

--Select DATA we are going to be using.

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you conttract CoviD in USA

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got CoviD

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HightestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--Showing Countries with the Highest Death Rate

select location,  max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT

select location,  max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

--Showing the continents with the highest death count

select continent,  max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2


--Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVac
--,(RollingPeopleVac/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVac vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVac
--,(RollingPeopleVac/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVac vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVac/population)*100
from PopvsVac

--Temp Table


	Drop table if exists #PercentPopulationVac
	Create Table #PercentPopulationVac
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVac numeric
	)

	insert into #PercentPopulationVac
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVac
	--,(RollingPeopleVac/population)*100
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVac vac
		on dea.location = vac.location
		and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

	select *, (RollingPeopleVac/population)*100
	from #PercentPopulationVac

	--Creating view to store DATA for later visualisation

	Create view PercentPopulationVac as 
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVac
	--,(RollingPeopleVac/population)*100
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVac vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

	Select *
	From PercentPopulationVac