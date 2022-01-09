SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project.Covid_deaths
ORDER BY 1, 2


-- Total Cases vs Total Deaths --
-- shows likelihood of dying if you contract covid in your country --

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM portfolio_project.Covid_deaths
WHERE location LIKE "%states%" 
	AND continent IS NOT NULL
ORDER BY 1, 2


-- Total Cases vs Population --
-- Shows what percentage of population got Covid --

SELECT Location, date, Population, total_cases, (total_cases / Population) * 100 AS InfectionRate
FROM portfolio_project.Covid_deaths
WHERE location LIKE "%states%"
ORDER BY 1, 2


-- Countries with Highest Infection Rate compared to population --

SELECT Location, Population, Max(total_cases) AS HighestInfectionCount, MAX((total_cases / Population)) * 100 AS InfectionRate
FROM portfolio_project.Covid_deaths
-- WHERE location LIKE "%states%"
GROUP BY Location
ORDER BY InfectionRate DESC


-- Showing Countries with Highest Death Count per population --
-- SIGNED integer 사용할 것 --

SELECT Location, MAX(CAST(Total_deaths AS SIGNED integer)) AS TotalDeathCount
FROM portfolio_project.Covid_deaths
-- WHERE location LIKE "%states%"
WHERE continent IS NOT NULL
	AND iso_code NOT LIKE "OWID%"
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Let's break things down by continents --
-- Showing continents with the highest death count per population --

SELECT continent, MAX(CAST(Total_deaths AS SIGNED integer)) AS TotalDeathCount
FROM portfolio_project.Covid_deaths
-- WHERE location LIKE "%states%"
WHERE continent IS NOT NULL
	AND iso_code NOT LIKE "OWID%"
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers --

SELECT date, SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS SIGNED integer)) AS total_deaths, 
    SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM portfolio_project.Covid_deaths
-- WHERE location LIKE "%states%" 
WHERE continent IS NOT NULL
	AND iso_code NOT LIKE "OWID%"
GROUP BY date
ORDER BY 1, 2

-- Total --

SELECT SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS SIGNED integer)) AS total_deaths, 
    SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM portfolio_project.Covid_deaths
-- WHERE location LIKE "%states%" 
WHERE continent IS NOT NULL
	AND iso_code NOT LIKE "OWID%"
-- GROUP BY date
ORDER BY 1, 2


-- join --

SELECT *
FROM portfolio_project.Covid_deaths AS dea
JOIN portfolio_project.covid_vaccination AS vac
	-- dea.location = vac.location
    ON dea.date = vac.date


-- Looking at Total Population vs Vaccinations --

SELECT dea.continent, DISTINCT(dea.location), dea.date, dea.population, vac.new_vaccinations
FROM portfolio_project.Covid_deaths AS dea
JOIN portfolio_project.covid_vaccination AS vac
    ON dea.date = vac.date
		AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
	AND dea.iso_code NOT LIKE "OWID%"
ORDER BY 2, 3


SELECT dea.continent, dea.location
FROM portfolio_project.Covid_deaths AS dea
JOIN portfolio_project.covid_vaccination AS vac
    ON dea.date = vac.date
		AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
	AND dea.iso_code NOT LIKE "OWID%"
GROUP BY location
ORDER BY 1, 2


SELECT min(dea.date)
FROM portfolio_project.Covid_deaths AS dea
JOIN portfolio_project.covid_vaccination AS vac
    ON dea.date = vac.date
		AND dea.location = vac.location
WHERE vac.new_vaccinations IS NOT NULL
	AND dea.iso_code NOT LIKE "OWID%"
GROUP BY dea.location
ORDER BY 1 ASC


SELECT DISTINCT(dea.location), dea.continent, dea.date, dea.population, vac.new_vaccinations
	-- , SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location)
FROM portfolio_project.Covid_deaths AS dea
JOIN portfolio_project.covid_vaccination AS vac
    ON dea.date = vac.date
		-- AND dea.location = vac.location
-- WHERE dea.location LIKE "%Korea%" 
WHERE dea.continent IS NOT NULL
	AND dea.iso_code NOT LIKE "OWID%"
ORDER BY 1,3


-- Temp Table --
    
DROP TABLE IF EXISTS PercentpopulationVaccinated
CREATE TABLE PercentpopulationVaccinated
    (
    Continent VARCHAR(255)
    Location VARCHAR(255),
    Date datetime,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingpeopleVaccinated NUMERIC
    )
    
INSERT INTO PercentpopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingpeopleVaccinated
FROM portfolio_project.Covid_deaths AS dea
JOIN portfolio_project.covid_vaccination AS vac
    ON dea.date = vac.date
		AND dea.location = vac.location
-- WHERE dea.continent IS NOT NULL AND dea.iso_code NOT LIKE "OWID%"
-- ORDER BY 1,3

SELECT *, (RollingpeopleVaccinated/Population) * 100
From PercentpopulationVaccinated


-- Creating View to store data for later visualizations --

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingpeopleVaccinated
FROM portfolio_project.Covid_deaths AS dea
JOIN portfolio_project.covid_vaccination AS vac
    ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL 
	AND dea.iso_code NOT LIKE "OWID%"
-- ORDER BY 1,3


-- view --

CREATE VIEW PopulationVaccinated AS
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
	-- , SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location)
FROM portfolio_project.Covid_deaths AS dea
JOIN portfolio_project.covid_vaccination AS vac
    ON dea.date = vac.date
		-- AND dea.location = vac.location
-- WHERE dea.location LIKE "%Korea%" 
WHERE dea.continent IS NOT NULL
	AND dea.iso_code NOT LIKE "OWID%"
ORDER BY 1,3
