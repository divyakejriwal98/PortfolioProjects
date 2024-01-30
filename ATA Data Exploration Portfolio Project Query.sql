--Select *
--From [ATA Data Exploration Portfolio Project]..['CovidVaccinations Dataset$']
--order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
From [ATA Data Exploration Portfolio Project]..['CovidDeaths Dataset$']
order by 1, 2

--Looking at Total Cases vs Total Deaths
-- Shows the likelihood of Death if you Contract COVID in your country
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From [ATA Data Exploration Portfolio Project]..['CovidDeaths Dataset$']
where location like '%india%'
order by 1, 2


--Looking at Total Cases vs Population
--Shows the proportion of population contracting COVID
Select location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as CasePercentage
From [ATA Data Exploration Portfolio Project]..['CovidDeaths Dataset$']
where location like '%india%'
order by 1, 2


--Looking at Countries with Highest Infection Rate
Select location, MAX(total_cases) as HighestInfectionCount, population, Max((cast(total_cases as float)/cast(population as float))*100) as MaxCasePercentage
From [ATA Data Exploration Portfolio Project]..['CovidDeaths Dataset$']
Group by Location, Population
order by 4 desc


--Showing countries with Highest Death Count per Population
Select location, max(cast (total_deaths as int)) as TotalDeathCount
From [ATA Data Exploration Portfolio Project]..['CovidDeaths Dataset$']
where continent is not null
Group by location
order by TotalDeathCount desc

--BY CONTINENT

Select continent, max(cast (total_deaths as int)) as TotalDeathCount
From [ATA Data Exploration Portfolio Project]..['CovidDeaths Dataset$']
where continent is not null
Group by continent
order by TotalDeathCount desc

Select location, max(cast (total_deaths as int)) as TotalDeathCount
From [ATA Data Exploration Portfolio Project]..['CovidDeaths Dataset$']
where continent is null
Group by location
order by TotalDeathCount desc

--Global Numbers
Select date, sum(cast(new_cases as float)), sum(cast(new_deaths as float)), sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as  DeathPercentage
From [ATA Data Exploration Portfolio Project]..['CovidDeaths Dataset$']
where continent is not null
Group by date
order by 1,2


--Looking at the Total Population vs Vaccinations
Select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
From [ATA Data Exploration Portfolio Project]..['CovidDeaths Dataset$'] dea
Join [ATA Data Exploration Portfolio Project]..['CovidVaccinations Dataset$'] vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--Looking at the cumulative count of vaccinations by day
Select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVac
From [ATA Data Exploration Portfolio Project]..['CovidDeaths Dataset$'] dea
Join [ATA Data Exploration Portfolio Project]..['CovidVaccinations Dataset$'] vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--USE CTE to find other calculations
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVac)
as
(
Select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVac
From [ATA Data Exploration Portfolio Project]..['CovidDeaths Dataset$'] dea
Join [ATA Data Exploration Portfolio Project]..['CovidVaccinations Dataset$'] vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select *, (CumulativeVac/Population) * 100 as PercentageVaccinations
from PopvsVac

--Using Temp Tables for the same
Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumulativeVac numeric,
)

Insert into #PercentagePopulationVaccinated
Select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVac
From [ATA Data Exploration Portfolio Project]..['CovidDeaths Dataset$'] dea
Join [ATA Data Exploration Portfolio Project]..['CovidVaccinations Dataset$'] vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

Select *, (CumulativeVac/Population) * 100 as PercentageVaccinations
from #PercentagePopulationVaccinated


--Creating View to stroe data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVac
From [ATA Data Exploration Portfolio Project]..['CovidDeaths Dataset$'] dea
Join [ATA Data Exploration Portfolio Project]..['CovidVaccinations Dataset$'] vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null