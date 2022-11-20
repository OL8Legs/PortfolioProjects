--General Queries
Select 
  * 
From 
  PortfolioProject..CovidDeaths 
Where 
  continent is not null 
Order By 
  3, 
  4;

--Select Data that we are going to be using
Select 
  location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population 
From 
  PortfolioProject..CovidDeaths 
Where 
  continent is not null 
Order By 
  1, 
  2;

--Total Cases vs Total Deaths
--Likelihood of death from Covid
Select 
  location, 
  date, 
  total_cases, 
  total_deaths, 
  (total_deaths / total_cases)* 100 As DeathPercentage 
From 
  PortfolioProject..CovidDeaths 
Where 
  location like '%states%' 
  And continent is not null 
Order By 
  1, 
  2;

--Total Cases vs. Population
--Percentage of population that contracted Covid
Select 
  location, 
  date, 
  population, 
  total_cases, 
  (total_cases / population)* 100 As PercentPopulationInfected 
From 
  PortfolioProject..CovidDeaths 
Where 
  continent is not null 
Order By 
  1, 
  2;

--Comparing highest infection rate vs population
Select 
  location, 
  population, 
  MAX(total_cases) as HighestInfectionCount, 
  MAX(
    (total_cases / population)
  )* 100 As PercentPopulationInfected 
From 
  PortfolioProject..CovidDeaths 
Where 
  continent is not null 
Group by 
  Location, 
  Population 
Order By 
  PercentPopulationInfected Desc;

--Countries with highest death count per population
Select 
  location, 
  MAX(
    cast(Total_Deaths as int)
  ) as TotalDeathCount 
From 
  PortfolioProject..CovidDeaths 
Where 
  continent is not null 
Group by 
  Location 
Order By 
  TotalDeathCount Desc;

--Braking it down by continent
Select 
  continent, 
  MAX(
    cast(Total_Deaths as int)
  ) as TotalDeathCount 
From 
  PortfolioProject..CovidDeaths 
Where 
  continent is not null 
Group by 
  continent 
Order By 
  TotalDeathCount Desc;

--Continents with highest death count
Select 
  continent, 
  MAX(
    cast(Total_Deaths as int)
  ) as TotalDeathCount 
From 
  PortfolioProject..CovidDeaths 
Where 
  continent is not null 
Group by 
  continent 
Order By 
  TotalDeathCount Desc;

--Global Numbers
Select 
  date, 
  SUM(new_cases) as total_cases, 
  SUM(
    cast(new_deaths as int)
  ) as total_deaths, 
  SUM(
    cast(new_deaths as int)
  )/ SUM(new_cases)* 100 As DeathPercentage 
From 
  PortfolioProject..CovidDeaths 
Where 
  continent is not null 
Group By 
  date 
Order By 
  1, 
  2;

--Total population vs total vaccinations, using cte
With PopvsVac (
  Continent, Location, Date, Population, 
  New_Vaccinations, RollingVaccinations
) as (
  Select 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(
      Convert(bigint, vac.new_vaccinations)
    ) OVER(
      Partition by dea.location 
      Order By 
        dea.location, 
        dea.date
    ) as RollingVaccinations --, (RollingVaccinations/dea.population)*100
  From 
    PortfolioProject..CovidDeaths dea 
    Join PortfolioProject..CovidVaccinations vac On dea.location = vac.location 
    And dea.date = vac.date 
  Where 
    dea.continent is not null --Order By 2,3
    ) 
Select 
  *, 
  (RollingVaccinations / Population)* 100 
From 
  PopvsVac 

--Temp Table
Drop 
  Table if exists #PercentPopulationVaccinated

  Create Table #PercentPopulationVaccinated
  (
    Continent nvarchar(255), 
    Location nvarchar(255), 
    Date datetime, 
    Population numeric, 
    New_Vaccinations numeric, 
    RollingVaccinations numeric
  ) Insert Into #PercentPopulationVaccinated
Select 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(
    Convert(bigint, vac.new_vaccinations)
  ) OVER(
    Partition by dea.location 
    Order By 
      dea.location, 
      dea.date
  ) as RollingVaccinations 
From 
  PortfolioProject..CovidDeaths dea 
  Join PortfolioProject..CovidVaccinations vac On dea.location = vac.location 
  And dea.date = vac.date 
Where 
  dea.continent is not null 
Select 
  *, 
  (RollingVaccinations / Population)* 100 
From 
  #PercentPopulationVaccinated

--Creating view to store data for visualizations
Drop 
  View if exists PercentPopulationVaccinated Create View PercentPopulationVaccinated as 
Select 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(
    Convert(bigint, vac.new_vaccinations)
  ) OVER(
    Partition by dea.location 
    Order By 
      dea.location, 
      dea.date
  ) as RollingVaccinations 
From 
  PortfolioProject..CovidDeaths dea 
  Join PortfolioProject..CovidVaccinations vac On dea.location = vac.location 
  And dea.date = vac.date 
Where 
  dea.continent is not null --Order By 2,3
Select 
  * 
From 
  PercentPopulationVaccinated
