-- 1.
-- Total cases, total deaths, and death percentage

SELECT SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	(SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- 2.
-- deaths by continent
SELECT location, SUM(new_deaths) AS total_death_count
FROM covid_deaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income',
					'Lower middle income','Low income')
GROUP BY location
ORDER BY total_death_count DESC

-- 3.
-- total infection count and infection percentage by location
SELECT location, population, MAX(total_cases) AS highest_infection_count,
MAX((total_cases/population))*100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population
ORDER BY percent_population_infected DESC

-- 4.
-- infection by date (by location)
SELECT location, population, date, MAX(total_cases) AS highest_infection_count,
MAX((total_cases/population))*100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population, date
ORDER BY percent_population_infected DESC





