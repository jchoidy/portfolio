# Global Covid Deaths EDA + Dashboard

![Covid Deaths and Infection Rate](/assets/covid_dashboard.png)

This project was born out of my curiosity to assess Covid restriction efficacy since 2020 around the globe, particularly by tracking infection rate trends over time in highly populated nations. 

## Dataset Summary

Global deaths, infections, and vaccine data from [Our World in Data: Coronavirus (COVID-19) Deaths](https://ourworldindata.org/covid-deaths), (January 10, 2020 - February 28, 2024)

## Process

After downloading the dataset from [Our World in Data](https://ourworldindata.org/covid-deaths), I transformed the table in **Excel**, utilized **SQL** (PostgreSQL) to perform exploratory data analysis, and then extracted my key findings to visualize in **Tableau**.

## Tools Used
- Transform csv file into two tables in **Excel**
- Load tables using **PostgreSQL** into **PG Admin**
- Extract query results and load data into **Tableau**

## Exploratory Data Analysis
- What are the Total Cases vs Total Deaths?
> Shows % of people who died who had Covid-19; also the general likelihood of dying if you contract Covid-19.
- What are the Total Cases vs Population?
> Shows % of population that contracted Covid-19 in a given country.
- Looking at countries with **highest infection rate**
- Show countries with **highest death count** per population
- Show continents with the **highest death count per population**
- Show total populations vs vaccinations (using Common Table Expression)
```sql
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
```


## Queries for Dashboard

Total cases, deaths, and death percentage

```sql
SELECT SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	(SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2
```

Deaths by continent
```sql
SELECT location, SUM(new_deaths) AS total_death_count
FROM covid_deaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income',
                    'Lower middle income','Low income')
GROUP BY location
ORDER BY total_death_count DESC
```

Total infection count and infection percentage by location
```sql
SELECT location, population, MAX(total_cases) AS highest_infection_count,
MAX((total_cases/population))*100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population
ORDER BY percent_population_infected DESC
```
infection by date (by location)
```sql
SELECT location, population, date, MAX(total_cases) AS highest_infection_count,
MAX((total_cases/population))*100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population, date
ORDER BY percent_population_infected DESC
```
