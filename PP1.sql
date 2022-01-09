DROP VIEW IF EXISTS PopulationVaccinated;

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
