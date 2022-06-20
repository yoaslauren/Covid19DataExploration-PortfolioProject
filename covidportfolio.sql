/*
Covid-19 Data Exploration
_________________________

Data source: https://ourworldindata.org/covid-deaths

Skills used: Create Tables, Alter Tables, Joins, Unions, Subqueries, CTE's, Temp Tables, Aggregate Functions, Windows Functions, Converting Data Types, Creating Views, Exporting Data
*/

--I. Create tables
--Create a table of Covid Deaths
CREATE TABLE coviddeaths (
	iso_code varchar(10),
	continent varchar(50),
	location varchar(100),
	date date,
	population bigint,
	total_cases int,
	new_cases int,
	new_cases_smoothed decimal,
	total_deaths int,
	new_deaths int,
	new_deaths_smoothed decimal,
	total_cases_per_million decimal,
	new_cases_per_million decimal,
	new_cases_smoothed_per_million decimal,
	total_deaths_per_million decimal,
	new_deaths_per_million decimal,
	new_deaths_smoothed_per_million decimal,
	reproduction_rate decimal,
	icu_patients int,
	icu_patients_per_million decimal,
	hosp_patients int,
	hosp_patients_per_million decimal,
	weekly_icu_admissions int,
	weekly_icu_admissions_per_million decimal,
	weekly_hosp_admissions int,
	weekly_hosp_admissions_per_million decimal
);

--Create a table of Covid Vaccinations
CREATE TABLE covidvaccinations (
	iso_code varchar(10),
	continent varchar(50),
	location varchar(100),
	date date,
	total_tests int,
	new_tests int,
	total_tests_per_thousand decimal,
	new_tests_per_thousand decimal,
	new_tests_smoothed int,
	new_tests_smoothed_per_thousand decimal,
	positive_rate decimal,
	tests_per_case decimal,
	tests_units text,
	total_vaccinations int,
	people_vaccinated int,
	people_fully_vaccinated int,
	total_boosters int,
	new_vaccinations int,
	new_vaccinations_smoothed int,
	total_vaccinations_per_hundred decimal,
	people_vaccinated_per_hundred decimal,
	people_fully_vaccinated_per_hundred decimal,
	total_boosters_per_hundred decimal,
	new_vaccinations_smoothed_per_million int,
	new_people_vaccinated_smoothed int,
	new_people_vaccinated_smoothed_per_hundred decimal,
	stringency_index decimal,
	population_density decimal,
	median_age decimal,
	aged_65_older decimal,
	aged_70_older decimal,
	gdp_per_capita decimal,
	extreme_poverty decimal,
	cardiovasc_death_rate decimal,
	diabetes_prevalence decimal,
	female_smokers decimal,
	male_smokers decimal,
	handwashing_facilities decimal,
	hospital_beds_per_thousand decimal,
	life_expectancy decimal,
	human_development_index decimal,
	excess_mortality_cumulative_absolute decimal,
	excess_mortality_cumulative decimal,
	excess_mortality decimal,
	excess_mortality_cumulative_per_million decimal
)


--II. Import CSV files from the data source to tables
--Alter tables due to insufficience of particular data type
ALTER TABLE covidvaccinations
ALTER COLUMN total_vaccinations TYPE bigint,
ALTER COLUMN people_vaccinated TYPE bigint,
ALTER COLUMN people_fully_vaccinated TYPE bigint;


--III. Data Exploration

-- Percentage Death per Total Cases for worldwide
-- Shows likelihood of people dying when exposed to covid
SELECT continent, location, date, population, total_cases, total_deaths, ROUND((CAST(total_deaths AS numeric)/total_cases)*100,3) AS PercentDeathperCases
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, date, population, total_cases, total_deaths
ORDER BY location, date;

-- Percentage Death per Total Cases in Indonesia
SELECT location, date, total_cases, total_deaths, ROUND((CAST(total_deaths AS numeric)/total_cases)*100,3) AS PercentDeathperCases
FROM coviddeaths
WHERE continent IS NOT NULL AND location = 'Indonesia'
GROUP BY location, date, total_cases, total_deaths
ORDER BY location, date;

-- Percentage of Population Infected by Covid worldwide
SELECT continent, location, date, population, total_cases, ROUND((CAST(total_cases AS numeric)/population)*100,3) AS PercentPopulationInfected
FROM coviddeaths
WHERE continent IS NOT NULL AND location NOT IN('World', 'European Union', 'International') AND location NOT LIKE '%income%'
GROUP BY continent, location, date, population, total_cases
ORDER BY location, date;

-- Percentage of Population Infected by Covid in Indonesia
SELECT location, date, population, total_cases, ROUND((CAST(total_cases AS numeric)/population)*100,6) AS PercentPopulationInfected
FROM coviddeaths
WHERE continent IS NOT NULL AND location = 'Indonesia'
ORDER BY location, date;

-- Highest Infectious Country
SELECT location, population, MAX(total_cases) AS HighestInfectiousCountry, ROUND((CAST(MAX(total_cases) AS numeric)/population)*100,3) AS PercentPopulationInfected
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC NULLS LAST;

-- Highest Infectious Continent
SELECT continent, SUM(DISTINCT population) AS NumberofPopulation, SUM(total_cases) AS NumberofTotalCases, ROUND((CAST(SUM(total_cases) AS numeric)/SUM(DISTINCT population)),8) AS PercentPopulationInfected
FROM coviddeaths
WHERE continent IS NOT NULL AND location NOT IN('World', 'European Union', 'International') AND location NOT LIKE '%income%'
GROUP BY continent
ORDER BY PercentPopulationInfected DESC;

-- Percentage of Total Deaths by Covid per Population
SELECT location, population, MAX(total_deaths) AS TotalDeathsCount, ROUND((CAST(MAX(total_deaths) AS numeric)/population)*100,3) AS PercentTotalDeaths
FROM coviddeaths
WHERE continent IS NOT NULL AND location NOT IN('World', 'European Union', 'International') AND location NOT LIKE '%income%'
GROUP BY location, population
ORDER BY PercentTotalDeaths DESC NULLS LAST;

-- Percentage of Deaths by Country
SELECT location, population, MAX(total_deaths) AS HighestTotalDeath, ROUND((CAST(MAX(total_deaths) AS numeric)/population)*100,4) AS PercentPopulationDead
FROM coviddeaths
WHERE continent IS NOT NULL AND population IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationDead DESC;

-- Percentage of Deaths by Continent
SELECT continent, SUM(DISTINCT population) AS NumberofPopulation, SUM(TotalDeaths) AS NumberofTotalDeaths, ROUND((CAST(SUM(TotalDeaths) AS numeric)/SUM(DISTINCT population))*100,3) AS PercentPopulationDead
FROM (
	SELECT continent, location, population, MAX(total_deaths) AS TotalDeaths
	FROM coviddeaths
	GROUP BY continent, location, population
	ORDER BY continent
) a
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY PercentPopulationDead DESC;

-- Number of Total Deaths by continent
SELECT continent, SUM(new_deaths) AS NumberofTotalDeaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY NumberofTotalDeaths DESC;

-- Number of Total Deaths per country
SELECT location, SUM(new_deaths) AS NumberofTotalDeaths
FROM coviddeaths
WHERE continent IS NOT NULL AND location NOT IN('World', 'European Union', 'International') AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY NumberofTotalDeaths DESC NULLS LAST


-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, ROUND((CAST(SUM(new_deaths) AS numeric)/SUM(new_cases))*100,2) AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY TotalCases

-- INDONESIA NUMBERS WITH RANKING
-- Using CTE
WITH PercentDeathPerCases (location, TotalCases, TotalDeaths, DeathPercentage)
AS
(
	SELECT location, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, ROUND((CAST(SUM(new_deaths) AS numeric)/SUM(new_cases))*100,2) AS DeathPercentage 
	FROM coviddeaths
	WHERE continent IS NOT NULL AND location NOT IN('World', 'European Union', 'International') AND location NOT LIKE '%income%'
	GROUP BY location
	ORDER BY location, DeathPercentage
)
SELECT *
FROM
(
	SELECT location, TotalCases, TotalDeaths, DeathPercentage, RANK() OVER(ORDER BY DeathPercentage DESC NULLS LAST)
	FROM PercentDeathPerCases
) a
WHERE location = 'Indonesia';


-- Total Population vs Vaccinations
-- Using CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, CumulativePeopleVacinated)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativePeopleVacinated
	FROM coviddeaths dea
	JOIN covidvaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date 
	WHERE dea.continent IS NOT NULL
	ORDER BY location, date
)
SELECT *, ROUND((CAST(CumulativePeopleVacinated AS numeric)/Population)*100,2) AS PercentPopulationVaccinated
FROM PopVsVac


-- Using Temp Table
--DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TEMP TABLE PercentPopulationVaccinated
--(
	--continent nvarchar(50),
	--location nvarchar(100),
	--date date,
	--population numeric,
	--new_vaccination numeric,
	--AccumulationPeopleVacinated numeric
--)
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativePeopleVacinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY location, date;

SELECT *, ROUND((CAST(CumulativePeopleVacinated AS numeric)/Population)*100,2) AS PercentVaccinated
FROM PercentPopulationVaccinated


-- Creating Views to store data for visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativePeopleVacinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY location, date;

SELECT * FROM PercentPopulationVaccinated;

SELECT *, ROUND((CAST(CumulativePeopleVacinated AS numeric)/Population)*100,2) AS PercentVaccinated
FROM PercentPopulationVaccinated;


-- Global Vaccinations Number
SELECT SUM(PeopleFullyVacbyCountry) AS TotalPeopleFullyVac, SUM(population) AS WorldTotalPopulation, ROUND((SUM(PeopleFullyVacbyCountry)/SUM(DISTINCT population))*100,2) AS PercentagePeopleFullyVac
FROM (
	SELECT dea.location, MAX(vac.people_fully_vaccinated) AS PeopleFullyVacbyCountry, dea.population
	FROM coviddeaths dea
	JOIN covidvaccinations vac
	ON dea.location = vac.location
	WHERE dea.continent IS NOT NULL AND dea.location NOT IN('World', 'European Union', 'International') AND dea.location NOT LIKE '%income%'
	GROUP BY dea.location, dea.population
) a


-- Cumulative People Vaccinated at least once
WITH grouped_table AS (
	SELECT date, location, people_vaccinated, COUNT(people_vaccinated) OVER (PARTITION BY location ORDER BY date) AS _group
	FROM covidvaccinations
	ORDER BY location, date
), final_table AS (
	SELECT date, location, people_vaccinated, _group, FIRST_VALUE(people_vaccinated) OVER (PARTITION BY location, _group) AS cumulative_people_vac
	FROM grouped_table
	ORDER BY location, date
)
SELECT date, location, COALESCE(cumulative_people_vac, 0) AS cumulative_people_vaccinated
FROM final_table

-- Percentage of Cumulative people vaccinated at least once per population
WITH grouped_table AS (
	SELECT date, location, people_vaccinated, COUNT(people_vaccinated) OVER (PARTITION BY location ORDER BY date) AS _group
	FROM covidvaccinations
	ORDER BY location, date
), final_table AS (
	SELECT date, location, people_vaccinated, _group, FIRST_VALUE(people_vaccinated) OVER (PARTITION BY location, _group) AS cumulative_people_vac
	FROM grouped_table
	ORDER BY location, date
)
SELECT ppvac.date, ppvac.location, COALESCE(ppvac.cumulative_people_vac, 0) AS cumulative_people_vaccinated, dea.population, ROUND((CAST(COALESCE(ppvac.cumulative_people_vac, 0) AS numeric)/dea.population)*100,2) AS Percentage
FROM final_table ppvac
INNER JOIN coviddeaths dea
ON dea.date = ppvac.date AND dea.location = ppvac.location
WHERE dea.location NOT IN('Oceania', 'Asia', 'North America', 'South America', 'Africa', 'Europe', 'European Union', 'International') AND dea.location NOT LIKE '%income%'


-- Cumulative People Fully Vaccinated
WITH grouped_table AS (
	SELECT date, location, people_fully_vaccinated, COUNT(people_fully_vaccinated) OVER (PARTITION BY location ORDER BY date) AS _group
	FROM covidvaccinations
	ORDER BY location, date
), final_table AS (
	SELECT date, location, people_fully_vaccinated, _group, FIRST_VALUE(people_fully_vaccinated) OVER (PARTITION BY location, _group) AS cumulative_people_fully_vac
	FROM grouped_table
	ORDER BY location, date
)
SELECT date, location, COALESCE(cumulative_people_fully_vac, 0) AS cumulative_people_fully_vaccinated
FROM final_table

-- Percentage of Cumulative people fully vaccinated per population
WITH grouped_table AS (
	SELECT date, location, people_fully_vaccinated, COUNT(people_fully_vaccinated) OVER (PARTITION BY location ORDER BY date) AS _group
	FROM covidvaccinations
	ORDER BY location, date
), final_table AS (
	SELECT date, location, people_fully_vaccinated, _group, FIRST_VALUE(people_fully_vaccinated) OVER (PARTITION BY location, _group) AS cumulative_people_fully_vac
	FROM grouped_table
	ORDER BY location, date
)
SELECT ppvac.date, ppvac.location, COALESCE(ppvac.cumulative_people_fully_vac, 0) AS cumulative_people_fully_vaccinated, dea.population, ROUND((CAST(COALESCE(ppvac.cumulative_people_fully_vac, 0) AS numeric)/dea.population)*100,2) AS Percentage
FROM final_table ppvac
INNER JOIN coviddeaths dea
ON dea.date = ppvac.date AND dea.location = ppvac.location
WHERE dea.location NOT IN('Oceania', 'Asia', 'North America', 'South America', 'Africa', 'Europe', 'European Union', 'International') AND dea.location NOT LIKE '%income%'


-- Cumulative Booster Given
WITH grouped_table AS (
	SELECT date, location, total_boosters, COUNT(total_boosters) OVER (PARTITION BY location ORDER BY date) AS _group
	FROM covidvaccinations
	ORDER BY location, date
), final_table AS (
	SELECT date, location, total_boosters, _group, FIRST_VALUE(total_boosters) OVER (PARTITION BY location, _group) AS cumulative_total_boost
	FROM grouped_table
	ORDER BY location, date
)
SELECT date, location, COALESCE(cumulative_total_boost, 0) AS cumulative_total_boosters
FROM final_table

-- Percentage of Cumulative Booster Given per population
WITH grouped_table AS (
	SELECT date, location, total_boosters, COUNT(total_boosters) OVER (PARTITION BY location ORDER BY date) AS _group
	FROM covidvaccinations
	ORDER BY location, date
), final_table AS (
	SELECT date, location, total_boosters, _group, FIRST_VALUE(total_boosters) OVER (PARTITION BY location, _group) AS cumulative_total_boost
	FROM grouped_table
	ORDER BY location, date
)
SELECT ppvac.date, ppvac.location, COALESCE(ppvac.cumulative_total_boost, 0) AS cumulative_total_boosters, dea.population, ROUND((CAST(COALESCE(ppvac.cumulative_total_boost, 0) AS numeric)/dea.population)*100,2) AS Percentage
FROM final_table ppvac
INNER JOIN coviddeaths dea
ON dea.date = ppvac.date AND dea.location = ppvac.location
WHERE dea.location NOT IN('Oceania', 'Asia', 'North America', 'South America', 'Africa', 'Europe', 'European Union', 'International') AND dea.location NOT LIKE '%income%'


-- Showing the total cases in a continent
WITH SumMaxCases (continent, location, MaxTotalCases)
AS
(
	SELECT continent, location, Max(total_cases) AS MaxTotalCases
	FROM coviddeaths
	WHERE continent = 'Africa'
	GROUP BY continent, location
	ORDER BY location
)
SELECT continent, location, SUM(MaxTotalCases)
FROM SumMaxCases
GROUP BY continent, location
ORDER BY location


--IV. Export data to CSV for visualisation

-- 1. Global Numbers
COPY (
	SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, ROUND((CAST(SUM(new_deaths) AS numeric)/SUM(new_cases))*100,2) AS DeathPercentage
	FROM coviddeaths
	WHERE continent IS NOT NULL
	ORDER BY TotalCases
)
TO 'D:\Portfolio\globalnumbers-may2022.csv' WITH DELIMITER ',' CSV HEADER;


-- 2a. Country Numbers with ranking
COPY (
	WITH PercentDeathPerCases (location, TotalCases, TotalDeaths, DeathPercentage)
	AS
	(
		SELECT location, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, ROUND((CAST(SUM(new_deaths) AS numeric)/SUM(new_cases))*100,2) AS DeathPercentage 
		FROM coviddeaths
		WHERE continent IS NOT NULL AND location NOT IN('World', 'European Union', 'International') AND location NOT LIKE '%income%'
		GROUP BY location
		ORDER BY location, DeathPercentage
	)
	SELECT *
	FROM
	(
		SELECT location, TotalCases, TotalDeaths, DeathPercentage, RANK() OVER(ORDER BY DeathPercentage DESC)
		FROM PercentDeathPerCases
		WHERE deathpercentage < 100 -- exclude North Korea due to data error (death percentage more than 100%)
	) a
)
TO 'D:\Portfolio\countrynumbersandrank-may2022.csv' WITH DELIMITER ',' CSV HEADER;

-- 2b. Indonesia Numbers with ranking
COPY (
	WITH PercentDeathPerCases (location, TotalCases, TotalDeaths, DeathPercentage)
	AS
	(
		SELECT location, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, ROUND((CAST(SUM(new_deaths) AS numeric)/SUM(new_cases))*100,2) AS DeathPercentage 
		FROM coviddeaths
		WHERE continent IS NOT NULL AND location NOT IN('World', 'European Union', 'International') AND location NOT LIKE '%income%'
		GROUP BY location
		ORDER BY location, DeathPercentage
	)
	SELECT *
	FROM
	(
		SELECT location, TotalCases, TotalDeaths, DeathPercentage, RANK() OVER(ORDER BY DeathPercentage DESC NULLS LAST)
		FROM PercentDeathPerCases
	) a
	WHERE location = 'Indonesia'
)
TO 'D:\Portfolio\indonesianumbersandrank-may2022.csv' WITH DELIMITER ',' CSV HEADER;

-- 2c. Indonesia Numbers
COPY (
	SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, ROUND((CAST(SUM(new_deaths) AS numeric)/SUM(new_cases))*100,2) AS DeathPercentage--, RANK() OVER(ORDER BY DeathPercentage) 
	FROM coviddeaths
	WHERE location = 'Indonesia'
	ORDER BY TotalCases
)
TO 'D:\Portfolio\indonesianumbers-may2022.csv' WITH DELIMITER ',' CSV HEADER;


-- 3. Percentage of Population Infected by Covid for all continent
COPY (
	SELECT continent, location, date, population, total_cases, ROUND((CAST(total_cases AS numeric)/population)*100,3) AS PercentPopulationInfected
	FROM coviddeaths
	WHERE continent IS NOT NULL AND location NOT IN('World', 'European Union', 'International') AND location NOT LIKE '%income%'
	GROUP BY continent, location, date, population, total_cases
	ORDER BY location, date
)
TO 'D:\Portfolio\percentpopulationinfected-may2022.csv' WITH DELIMITER ',' CSV HEADER;

-- 4. Percentage of Population Infected by Covid per country
COPY (
	SELECT location, population, MAX(total_cases) AS HighestInfectionNumber, ROUND((CAST(MAX(total_cases) AS numeric)/population)*100,2) AS PercentPopulationInfected
	FROM coviddeaths
	WHERE continent IS NOT NULL AND location NOT IN('World', 'European Union', 'International') AND location NOT LIKE '%income%'
	GROUP BY location, population
	ORDER BY PercentPopulationInfected DESC NULLS LAST
)
TO 'D:\Portfolio\percentpopulationinfectedpercountry-may2022.csv' WITH DELIMITER ',' CSV HEADER;

-- 5. Total Deaths per country
COPY (
	SELECT location, SUM(new_deaths) AS NumberofTotalDeaths
	FROM coviddeaths
	WHERE continent IS NOT NULL AND location NOT IN('World', 'European Union', 'International') AND location NOT LIKE '%income%'
	GROUP BY location
	ORDER BY NumberofTotalDeaths DESC NULLS LAST
)
TO 'D:\Portfolio\totaldeathcountry-may2022.csv' WITH DELIMITER ',' CSV HEADER;

-- 6. Total Death by continent
COPY (
	SELECT continent, SUM(new_deaths) AS NumberofTotalDeaths
	FROM coviddeaths
	WHERE continent IS NOT NULL
	GROUP BY continent
	ORDER BY NumberofTotalDeaths DESC
)
TO 'D:\Portfolio\totaldeathcontinent-may2022.csv' WITH DELIMITER ',' CSV HEADER;

-- 7a. Growth rate of people vaccinated at least once
COPY (
	WITH grouped_table AS (
		SELECT date, location, people_vaccinated, COUNT(people_vaccinated) OVER (PARTITION BY location ORDER BY date) AS _group
		FROM covidvaccinations
		ORDER BY location, date
	), final_table AS (
		SELECT date, location, people_vaccinated, _group, FIRST_VALUE(people_vaccinated) OVER (PARTITION BY location, _group) AS cumulative_people_vac
		FROM grouped_table
		ORDER BY location, date
	)
	SELECT ppvac.date, ppvac.location, COALESCE(ppvac.cumulative_people_vac, 0) AS cumulative_people_vaccinated, dea.population, ROUND((CAST(COALESCE(ppvac.cumulative_people_vac, 0) AS numeric)/dea.population)*100,2) AS Percentage
	FROM final_table ppvac
	INNER JOIN coviddeaths dea
	ON dea.date = ppvac.date AND dea.location = ppvac.location
	WHERE dea.location NOT IN('Oceania', 'Asia', 'North America', 'South America', 'Africa', 'Europe', 'European Union', 'International') AND dea.location NOT LIKE '%income%'
)
TO 'D:\Portfolio\growthratevaccinatedonce-may2022.csv' WITH DELIMITER ',' CSV HEADER;

-- 7b. Growth rate of people fully vaccinated
COPY (
	WITH grouped_table AS (
		SELECT date, location, people_fully_vaccinated, COUNT(people_fully_vaccinated) OVER (PARTITION BY location ORDER BY date) AS _group
		FROM covidvaccinations
		ORDER BY location, date
	), final_table AS (
		SELECT date, location, people_fully_vaccinated, _group, FIRST_VALUE(people_fully_vaccinated) OVER (PARTITION BY location, _group) AS cumulative_people_fully_vac
		FROM grouped_table
		ORDER BY location, date
	)
	SELECT ppvac.date, ppvac.location, COALESCE(ppvac.cumulative_people_fully_vac, 0) AS cumulative_people_fully_vaccinated, dea.population, ROUND((CAST(COALESCE(ppvac.cumulative_people_fully_vac, 0) AS numeric)/dea.population)*100,2) AS Percentage
	FROM final_table ppvac
	INNER JOIN coviddeaths dea
	ON dea.date = ppvac.date AND dea.location = ppvac.location
	WHERE dea.location NOT IN('Oceania', 'Asia', 'North America', 'South America', 'Africa', 'Europe', 'European Union', 'International') AND dea.location NOT LIKE '%income%'
)
TO 'D:\Portfolio\growthratefullyvaccinated-may2022.csv' WITH DELIMITER ',' CSV HEADER;

-- 7c. Growth rate of people got boosters
COPY (
	WITH grouped_table AS (
		SELECT date, location, total_boosters, COUNT(total_boosters) OVER (PARTITION BY location ORDER BY date) AS _group
		FROM covidvaccinations
		ORDER BY location, date
	), final_table AS (
		SELECT date, location, total_boosters, _group, FIRST_VALUE(total_boosters) OVER (PARTITION BY location, _group) AS cumulative_total_boost
		FROM grouped_table
		ORDER BY location, date
	)
	SELECT ppvac.date, ppvac.location, COALESCE(ppvac.cumulative_total_boost, 0) AS cumulative_total_boosters, dea.population, ROUND((CAST(COALESCE(ppvac.cumulative_total_boost, 0) AS numeric)/dea.population)*100,2) AS Percentage
	FROM final_table ppvac
	INNER JOIN coviddeaths dea
	ON dea.date = ppvac.date AND dea.location = ppvac.location
	WHERE dea.location NOT IN('Oceania', 'Asia', 'North America', 'South America', 'Africa', 'Europe', 'European Union', 'International') AND dea.location NOT LIKE '%income%'
)
TO 'D:\Portfolio\growthrateboosters-may2022.csv' WITH DELIMITER ',' CSV HEADER;

-- 7d. Compilation of Vaccination Tables
-- Create Temporary Tables for each vaccination category:
--		1). At least 1 dose of the Covid-19 vaccine
CREATE TEMP TABLE OneDoseVacTable
AS
WITH grouped_table AS (
	SELECT date, location, people_vaccinated, COUNT(people_vaccinated) OVER (PARTITION BY location ORDER BY date) AS _group
	FROM covidvaccinations
	ORDER BY location, date
), final_table AS (
	SELECT date, location, people_vaccinated, _group, FIRST_VALUE(people_vaccinated) OVER (PARTITION BY location, _group) AS cumulative_people_vac
	FROM grouped_table
	ORDER BY location, date
)
SELECT ppvac.date, ppvac.location, COALESCE(ppvac.cumulative_people_vac, 0) AS cumulative, dea.population, ROUND((CAST(COALESCE(ppvac.cumulative_people_vac, 0) AS numeric)/dea.population)*100,2) AS Percentage, 'At least 1 dose' AS category
FROM final_table ppvac
INNER JOIN coviddeaths dea
ON dea.date = ppvac.date AND dea.location = ppvac.location
WHERE dea.location NOT IN('Oceania', 'Asia', 'North America', 'South America', 'Africa', 'Europe', 'European Union', 'International') AND dea.location NOT LIKE '%income%';

--		2). Fully vaccinated
CREATE TEMP TABLE FullyVacTable
AS
WITH grouped_table AS (
	SELECT date, location, people_fully_vaccinated, COUNT(people_fully_vaccinated) OVER (PARTITION BY location ORDER BY date) AS _group
	FROM covidvaccinations
	ORDER BY location, date
), final_table AS (
	SELECT date, location, people_fully_vaccinated, _group, FIRST_VALUE(people_fully_vaccinated) OVER (PARTITION BY location, _group) AS cumulative_people_fully_vac
	FROM grouped_table
	ORDER BY location, date
)
SELECT ppvac.date, ppvac.location, COALESCE(ppvac.cumulative_people_fully_vac, 0) AS cumulative, dea.population, ROUND((CAST(COALESCE(ppvac.cumulative_people_fully_vac, 0) AS numeric)/dea.population)*100,2) AS Percentage, 'Fully vaccinated' AS category
FROM final_table ppvac
INNER JOIN coviddeaths dea
ON dea.date = ppvac.date AND dea.location = ppvac.location
WHERE dea.location NOT IN('Oceania', 'Asia', 'North America', 'South America', 'Africa', 'Europe', 'European Union', 'International') AND dea.location NOT LIKE '%income%';

--		3). Boosters
CREATE TEMP TABLE BoosterTable
AS
WITH grouped_table AS (
	SELECT date, location, total_boosters, COUNT(total_boosters) OVER (PARTITION BY location ORDER BY date) AS _group
	FROM covidvaccinations
	ORDER BY location, date
), final_table AS (
	SELECT date, location, total_boosters, _group, FIRST_VALUE(total_boosters) OVER (PARTITION BY location, _group) AS cumulative_total_boost
	FROM grouped_table
	ORDER BY location, date
)
SELECT ppvac.date, ppvac.location, COALESCE(ppvac.cumulative_total_boost, 0) AS cumulative, dea.population, ROUND((CAST(COALESCE(ppvac.cumulative_total_boost, 0) AS numeric)/dea.population)*100,2) AS Percentage, 'Boosters given' AS category
FROM final_table ppvac
INNER JOIN coviddeaths dea
ON dea.date = ppvac.date AND dea.location = ppvac.location
WHERE dea.location NOT IN('Oceania', 'Asia', 'North America', 'South America', 'Africa', 'Europe', 'European Union', 'International') AND dea.location NOT LIKE '%income%';

-- Union of 3 vaccination tables
COPY (
	SELECT * FROM OneDoseVacTable
	UNION ALL
	SELECT * FROM FullyVacTable
	UNION ALL
	SELECT * FROM BoosterTable
)
TO 'D:\Portfolio\compilationofvaccinations-may2022.csv' WITH DELIMITER ',' CSV HEADER;


-- 8. Percentage of people fully vaccinated in all countries
COPY (
	SELECT dea.location, dea.population, MAX(vac.people_fully_vaccinated) AS PeopleVaccinated, ROUND((CAST(MAX(vac.people_fully_vaccinated) AS numeric)/dea.population)*100,2) AS PercentVaccinated
	FROM coviddeaths dea
	JOIN covidvaccinations vac
	ON dea.location = vac.location
	WHERE dea.location NOT IN('World', 'European Union', 'International') AND dea.location NOT LIKE '%income%'
	GROUP BY dea.location, dea.population
	ORDER BY PercentVaccinated DESC NULLS LAST
)
TO 'D:\Portfolio\peoplefullyvaccinated-may2022.csv' WITH DELIMITER ',' CSV HEADER;
