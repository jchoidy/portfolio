# Global Covid Deaths EDA + Dashboard

![Covid Deaths and Infection Rate](/assets/covid_dashboard.png)

This project was born out of my curiosity to assess Covid restriction efficacy since 2020 around the globe, particularly by tracking infection rate trends over time in highly populated nations. 

## Process

After downloading the dataset from [Our World in Data](https://ourworldindata.org/covid-deaths), I transformed the table in **Excel**, utilized **SQL** (PostgreSQL) to perform exploratory data analysis, and then extracted my key findings to visualize in **Tableau**.


## Dataset Summary

Global deaths, infections, and vaccine data from [Our World in Data: Coronavirus (COVID-19) Deaths](https://ourworldindata.org/covid-deaths), (January 10, 2020 - February 28, 2024)


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
