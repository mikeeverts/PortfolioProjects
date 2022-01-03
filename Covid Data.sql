---- Show data from both tables

SELECT * FROM CovidProject..covid_deaths  ORDER BY location, date
--SELECT * FROM CovidProject..covid_vaccinations ORDER BY location, date


---- Data will be used in visualization
---- Total Deaths with Population

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..covid_deaths
WHERE continent is not null
order by 1,2

---- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100  AS 'death_percentage'
FROM CovidProject..covid_deaths
WHERE location like '%states%' AND  continent is not null
order by 1,2

-- Look at Total Cases vs Population 
-- Shows Percentage of Population got Covid
SELECT location, date, population, total_cases,  (total_cases/population) * 100 AS 'population_contracted'
FROM CovidProject..covid_deaths
--WHERE location like '%states%'
WHERE continent is not null
order by 1,2


-- Country with Highest Infection Rates Compared to Populations 

SELECT location, population, MAX(total_cases) AS 'highest_infection_count',  (MAX(total_cases)/population) * 100 AS 'population_contracted'
FROM CovidProject..covid_deaths
WHERE continent is not null
GROUP BY location, population
order by 4 DESC

-- Country with the Highest Death Rates 
SELECT location, MAX(CAST(total_deaths as int)) AS 'total_death_count'
FROM CovidProject..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 desc




---- Continent with the highest date rates
SELECT location, MAX(CAST(total_deaths as int)) AS 'total_death_count'
FROM CovidProject..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 desc

---- BREAK THINGS DOWN BY CONTINENT

--SELECT continent, MAX(CAST(total_deaths as int)) AS 'total_death_count'
--FROM CovidProject..covid_deaths
--WHERE continent is not null
--GROUP BY continent
--ORDER BY 2 desc

SELECT location, MAX(CAST(total_deaths as int)) AS 'total_death_count'
FROM CovidProject..covid_deaths
WHERE continent is null
GROUP BY location
ORDER BY 2 desc

---- SHOW CONTINENT WITH HIGHEST DEATH COUNTS

SELECT location, MAX(CAST(total_deaths as int)) AS 'total_death_count'
FROM CovidProject..covid_deaths
WHERE continent is   null
GROUP BY location
ORDER BY 2 desc

---- GLOBAL NUMBERS

SELECT  date, SUM(new_cases) AS 'total_cases', SUM(CAST(new_deaths AS int)) as 'total_deaths', SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS 'death_percentage'
FROM CovidProject..covid_deaths
WHERE continent is not null
GROUP BY date
order by 1,2


-- TOTAL POPULATION VS VACCINATIONS
SELECT 
dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations,0)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS 'rolling_total_vaccinations'
FROM CovidProject..covid_deaths dea
JOIN CovidProject..covid_vaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE vac.continent is not null
ORDER BY 2,3

---- USE CTE

WITH PopsVsVac  (continent, location, date, population,new_vaccinations, rolling_total_vaccinations)
AS 
(
SELECT 
dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations,0)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS 'rolling_total_vaccinations'
FROM CovidProject..covid_deaths dea
JOIN CovidProject..covid_vaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE vac.continent is not null)
SELECT *, (rolling_total_vaccinations/population) * 100 AS 'percent_population_vaccinated' FROM PopsVsVac Order By 2,3


---- CREATE VIEW FOR FUTURE VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations,0)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS 'rolling_total_vaccinations'
FROM CovidProject..covid_deaths dea
JOIN CovidProject..covid_vaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE vac.continent is not null
