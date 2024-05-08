-- Looking at Total Population vs Vaccinations

SELECT
	dea.continent, dea.location, dea.date, dea.population,
	vacc.new_vaccinations
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Looking at Total Population vs Vaccinations

SELECT
	dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
	SUM(vacc.new_vaccinations)
	OVER (PARTITION BY dea.location
		  ORDER BY dea.location, dea.date)
		  AS rolling_people_vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH pop_vs_vacc (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT
	dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
	SUM(vacc.new_vaccinations)
	OVER (PARTITION BY dea.location
		  ORDER BY dea.location, dea.date)
		  AS rolling_people_vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM pop_vs_vacc


-- TEMP TABLE

CREATE TABLE percent_population_vaccinated
(
continent VARCHAR(255),
location VARCHAR(255),
date DATE,
population NUMERIC,
new_vaccinations NUMERIC,
rolling_people_vaccinated NUMERIC
);

INSERT INTO percent_population_vaccinated
SELECT
	dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
	SUM(vacc.new_vaccinations)
	OVER (PARTITION BY dea.location
		  ORDER BY dea.location, dea.date)
		  AS rolling_people_vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date;
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (rolling_people_vaccinated/population)*100
FROM percent_population_vaccinated;

-- Creating View to store data for later visualizations

CREATE OR REPLACE VIEW perc_pop_vacc AS
SELECT
	dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
	SUM(vacc.new_vaccinations)
	OVER (PARTITION BY dea.location
		  ORDER BY dea.location, dea.date)
		  AS rolling_people_vaccinated
FROM
	covid_deaths AS dea
JOIN
	covid_vaccinations AS vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

