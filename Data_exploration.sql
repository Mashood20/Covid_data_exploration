ALTER TABLE PortfolioProject.dbo.Coviddeaths ALTER COLUMN total_deaths FLOAT
ALTER TABLE PortfolioProject.dbo.Coviddeaths ALTER COLUMN total_cases FLOAT

Select *
from PortfolioProject.dbo.Coviddeaths
where continent is not null
order by 3,4

-- total death vs total cases
SELECT location, date, total_deaths, total_cases, total_deaths/total_cases*100 as Deathsratio
from PortfolioProject.dbo.Coviddeaths
where continent is not null

-- total death vs total cases in united states
SELECT location, date, total_deaths, total_cases, total_deaths/total_cases*100 as Deathsratio
from PortfolioProject.dbo.Coviddeaths
WHERE continent is not null
and location like '%states%'
order by 1,2

-- total cases vs population
SELECT location, date, total_cases, population, (total_cases/population)*100 as casesratiopercentage
from PortfolioProject.dbo.Coviddeaths
WHERE continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as casesratiopercentage
from PortfolioProject.dbo.Coviddeaths
WHERE continent is not null
GROUP by location, population
ORDER by casesratiopercentage desc


--looking at countries with highest death rate compared to population
SELECT location, MAX(total_deaths) as highest_death_count
from PortfolioProject.dbo.Coviddeaths
where continent is not Null
GROUP by location
ORDER by highest_death_count desc


--showing continents with highest count per population
SELECT continent, MAX(total_deaths) as highest_death_count
from PortfolioProject.dbo.Coviddeaths
where continent is not Null
GROUP by continent
ORDER by highest_death_count desc

-- calculating percentage of deaths daily
SELECT SUM(new_cases) as new_cases, SUM(new_deaths) as new_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as death_percentage
from PortfolioProject.dbo.Coviddeaths
where continent is not Null
and new_cases != 0
ORDER by 1,2


--looking total population vs vaccinations

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER(Partition by deaths.location order by deaths.location, deaths.date) as sum_of_vaccinated
from PortfolioProject.dbo.Coviddeaths deaths
JOIN PortfolioProject.dbo.Covidvaccinations vac
    on deaths.location = vac.location 
    and deaths.date = vac.date
WHERE deaths.continent is not NULL 
ORDER by 2,3 

--use cte
WITH Popvsvac(continent, location, date, population, new_vaccinations, sum_of_vaccinated)
AS(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER(Partition by deaths.location order by deaths.location, deaths.date) as sum_of_vaccinated
from PortfolioProject.dbo.Coviddeaths deaths
JOIN PortfolioProject.dbo.Covidvaccinations vac
    on deaths.location = vac.location 
    and deaths.date = vac.date
WHERE deaths.continent is not NULL 
-- ORDER by 2,3 
)
SELECT *, (convert(float, sum_of_vaccinated)/ convert(float,population))*100 as Percentage_of_vaccinated
FROM Popvsvac
ORDER by 2,3 

--doing same with temp table
DROP TABLE if EXISTS #Percentageofvaccinated
Create Table #Percentageofvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population NUMERIC,
Sum_of_vaccinated NUMERIC,
Percentage_of_vaccinated NUMERIC
)
Insert into #Percentageofvaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER(Partition by deaths.location order by deaths.location, deaths.date) as sum_of_vaccinated
from PortfolioProject.dbo.Coviddeaths deaths
JOIN PortfolioProject.dbo.Covidvaccinations vac
    on deaths.location = vac.location 
    and deaths.date = vac.date
WHERE deaths.continent is not NULL 
-- ORDER by 2,3 

SELECT *, (convert(float, sum_of_vaccinated)/ convert(float,population))*100 as Percentage_of_vaccinated
FROM #Percentageofvaccinated


--creating view to store data for visualizations
CREATE VIEW Percentageofvaccinated as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER(Partition by deaths.location order by deaths.location, deaths.date) as sum_of_vaccinated
from PortfolioProject.dbo.Coviddeaths deaths
JOIN PortfolioProject.dbo.Covidvaccinations vac
    on deaths.location = vac.location 
    and deaths.date = vac.date
WHERE deaths.continent is not NULL 
-- ORDER by 2,3 
