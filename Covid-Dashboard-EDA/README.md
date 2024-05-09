# Global Covid Deaths EDA + Dashboard

[Tableau Dashboard](https://public.tableau.com/app/profile/jason.choi7047/viz/CovidResearch_17129148303530/Dashboard1)<br/>
![covid_dashboard](https://github.com/jchoidy/portfolio/assets/129639246/6db98167-9c64-4799-8951-87daa25d13fc)

- This project stems from my curiosity about analyzing global COVID-19 death and infection rates, particularly focusing on mortality and infection rates, and assessing the accuracy of reporting across countries worldwide

## Dataset Summary
- Global deaths, infections, and vaccination data from [Our World in Data: Coronavirus (COVID-19) Deaths](https://ourworldindata.org/covid-deaths), (January 10, 2020 - February 28, 2024)

## Tools Used + Process
- **Tools**: Excel, SQL (PostgreSQL, PGAdmin), Tableau
- **Process**: I organized the dataset into two Excel tables (covid_deaths and covid_vaccinations), loaded them into SQL, and extracted query results for visualization in Tableau.

## Exploratory Data Analysis + Takeaways
With the dashboard, we can concentrate on global regions' mortality and infection rates.<br/>
**Population vs. Fatality Ratio**
> - Defined as the **ratio between the global % of population and the global % of fatalities** due to COVID-19
> - Europe, North America, and South America exhibit a consistent ratio between their share of the global population and their % of COVID-19 fataliaties, although there isn't a standardized metric for comparison
> - **Asia and Africa exhibit a disproportionately lower fatality rate relative to their global population**
> - Oceania is closer to 1:1

| Continent     | Global Population | Global Fatality % COVID-19 | Population : Fatality Ratio |
| ------------- | ----------------- | -------------------------- | --------------------------- |
| Europe	| 9.26%             | 29.8%                      | 1 : 3.2                     |
| North America | 7.6%              | 23.5%                      | 1 : 3.1             	       |
| South America | 5.53%             | 19.3%                      | 1 : 3.5                     | 
| **Asia**      | **61.56%**        | **23.2%**                  | **1 : 0.4**                 |
| **Africa**    | **18.68%**        | **3.6%**                   | **1 : 0.2**                 |
| Oceania       | 0.58% 	    | 0.45%                      | 1 : 0.8                     |

**Explanatory Factors for Disparity**
> - Disparities in population-to-fatality ratios between continents raise questions about reporting accuracy, resource availability, and governance structures
> - Potential explanations include flawed reporting systems, resource limitations, and governmental factors -- such as the [influence of authoritarian regimes](https://www.thoughtco.com/communist-countries-overview-1435178) on data transparency or [underdeveloped countries in certain continents](https://www.jagranjosh.com/general-knowledge/third-world-countries-list-1705907395-1)
> - Oceania's balanced ratio may be explain due to ['higher trust' in government and people](https://www.nytimes.com/2022/05/15/world/australia/covid-deaths.html), making its COVID-19 policy efficacy higher

<br/>

Death % by location
```sql
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
ORDER BY 1,2
```

% of population that contracted COVID-19 by location
```sql
SELECT location, date, population, total_cases, (total_cases/population)*100 AS contraction_percentage
FROM covid_deaths
ORDER BY 1,2
```
Looking at countries with **highest infection rate**
```sql
SELECT location, population, MAX(total_cases) as highest_infection_count,
MAX((total_cases/population)*100) AS contraction_percentage
FROM covid_deaths
GROUP BY location, population
ORDER BY contraction_percentage DESC
```
**Highest death count** by location
```sql
SELECT location, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE continent != 'null'
GROUP BY location
ORDER BY total_death_count DESC
```
Infection rate by continent
```sql
SELECT location, MAX(total_cases) AS highest_infection_count,
MAX((total_cases/population)*100) AS contraction_percentage
FROM covid_deaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income',
                    'Lower middle income','Low income')
GROUP BY location, population
ORDER BY contraction_percentage DESC
```

Looking at continents with the **highest death count**
```sql
/* 'location' column includes data that has more accurate continent totals,
so WHERE statement should be 'continent is null'
*/
SELECT location, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE continent IS null
AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income',
                    'Lower middle income','Low income')
GROUP BY location
ORDER BY total_death_count DESC
```

Rolling % of population vaccinated by location and date (using Common Table Expression)
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
SELECT *, (rolling_people_vaccinated/population)*100 AS percent_vaccinated
FROM pop_vs_vacc
```

---

## Queries for Dashboard

Total cases, deaths, and death %
```sql
SELECT SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	(SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2
```

Total deaths by continent
```sql
SELECT location, SUM(new_deaths) AS total_death_count
FROM covid_deaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income',
                    'Lower middle income','Low income')
GROUP BY location
ORDER BY total_death_count DESC
```

Total infection count and infection % by location
```sql
SELECT location, population, MAX(total_cases) AS highest_infection_count,
MAX((total_cases/population))*100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population
ORDER BY percent_population_infected DESC
```

% of population infected by date and location (time-series)
```sql
SELECT location, population, date, MAX(total_cases) AS highest_infection_count,
MAX((total_cases/population))*100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population, date
ORDER BY percent_population_infected DESC
```
