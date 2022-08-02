-- Creating data base
DROP DATABASE IF EXISTS `Case_Study_2`;
CREATE DATABASE `Case_Study_2`; 
USE `Case_Study_2`;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- creating table
DROP TABLE IF EXISTS `CovidDeaths`;
CREATE TABLE `CovidDeaths`
		(iso_code CHAR(10),
        continent CHAR(20),
		location CHAR(50),
		date DATE,
		population INT,
		total_cases INT,
		new_cases INT,
		new_cases_smoothed DOUBLE,
		total_deaths INT,
		new_deaths INT,
		new_deaths_smoothed DOUBLE,
		total_cases_per_million DOUBLE,
		new_cases_per_million DOUBLE,
		new_cases_smoothed_per_million DOUBLE,
		total_deaths_per_million DOUBLE,
		new_deaths_per_million DOUBLE,
		new_deaths_smoothed_per_million DOUBLE,
		reproduction_rate DOUBLE,
		icu_patients INT,
		icu_patients_per_million DOUBLE,
		hosp_patients INT,
		hosp_patients_per_million DOUBLE,
		weekly_icu_admissions INT,
		weekly_icu_admissions_per_million DOUBLE,
		weekly_hosp_admissions INT,
		weekly_hosp_admissions_per_million DOUBLE)
        ; 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Uploading data into the table
LOAD DATA LOCAL INFILE 
"C:/Users/naily/git/CASE-STUDY-2-COVID_PORTFOLIO_PROJECT/CovidDeaths.csv"
INTO TABLE CovidDeaths 
FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- creating table
DROP TABLE IF EXISTS `CovidVaccination`;
CREATE TABLE `CovidVaccination`
		(iso_code CHAR(10),
        continent CHAR(20),
		location CHAR(50),
		date DATE,
        total_tests INT,
		new_tests INT,
		total_tests_per_thousand DOUBLE,
		new_tests_per_thousand DOUBLE,
		new_tests_smoothed INT,
		new_tests_smoothed_per_thousand DOUBLE,
		positive_rate DOUBLE,
		tests_per_case DOUBLE,
		tests_units CHAR (20),
		total_vaccinations INT,
		people_vaccinated INT,
		people_fully_vaccinated INT,
		total_boosters INT,
		new_vaccinations INT,
		new_vaccinations_smoothed INT,
		total_vaccinations_per_hundred DOUBLE,
		people_vaccinated_per_hundred DOUBLE,
		people_fully_vaccinated_per_hundred DOUBLE,
		total_boosters_per_hundred DOUBLE,
		new_vaccinations_smoothed_per_million INT,
		new_people_vaccinated_smoothed INT,
		new_people_vaccinated_smoothed_per_hundred DOUBLE,
		stringency_index DOUBLE,
		population_density DOUBLE,
		median_age DOUBLE,
		aged_65_older DOUBLE,
		aged_70_older DOUBLE,
		gdp_per_capita DOUBLE,
		extreme_poverty DOUBLE,
		cardiovasc_death_rate DOUBLE,
		diabetes_prevalence DOUBLE,
		female_smokers DOUBLE,
		male_smokers DOUBLE,
		handwashing_facilities DOUBLE,
		hospital_beds_per_thousand DOUBLE,
		life_expectancy DOUBLE,
		human_development_index DOUBLE,
		excess_mortality_cumulative_absolute DOUBLE,
		excess_mortality_cumulative DOUBLE,
		excess_mortality DOUBLE,
		excess_mortality_cumulative_per_million DOUBLE)
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Uploading data into the table
LOAD DATA LOCAL INFILE 
"C:/Users/naily/git/CASE-STUDY-2-COVID_PORTFOLIO_PROJECT/CovidVaccination.csv"
INTO TABLE CovidVaccination
FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Visualizing the table's data
SELECT *
FROM Case_Study_2.CovidDeaths
WHERE continent <> ''
ORDER BY location, date
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Select the data I'm going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Looking at total_cases vs total_deaths in Canada
SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE location = 'Canada' AND continent IS NOT NULL
ORDER BY location, date
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Looking at total_cases vs Canada population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS population_infected_percentage
FROM CovidDeaths
WHERE location = 'Canada' AND continent IS NOT NULL
ORDER BY location, date
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Looking at countries with the highest number of deaths
SELECT location,
	   MAX(total_deaths) AS highest_death
FROM CovidDeaths
WHERE continent <> ''
GROUP BY location
ORDER BY highest_death DESC
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Looking countries with the highest death compared to population
SELECT location, 
	   population, 
       MAX(total_cases) AS highest_infection, 
       MAX((total_cases/population))*100 AS population_infected_percentage
FROM CovidDeaths
WHERE continent <> ''
GROUP BY location, population
ORDER BY population_infected_percentage DESC
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Looking at continents with the highest number of deaths
SELECT continent,
	   MAX(total_deaths) AS highest_death
FROM CovidDeaths
WHERE continent <> ''
GROUP BY continent
ORDER BY highest_death DESC
;
SELECT location,
	   MAX(total_deaths) AS highest_death
FROM CovidDeaths
WHERE continent = '' AND location NOT IN ('High income', 'Upper middle income', 'Lower middle income', 'Low income','European Union')
GROUP BY location
ORDER BY highest_death DESC
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global numbers
SELECT 
	   date, 
       SUM(new_cases) AS total_cases,
       SUM(new_deaths) AS total_deaths,
       SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE continent <> ''
GROUP BY date
ORDER BY date
;

SELECT 
       SUM(new_cases) AS total_cases,
       SUM(new_deaths) AS total_deaths,
       SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE continent <> ''
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Visualizing the table's data
SELECT *
FROM Case_Study_2.CovidVaccination
WHERE continent <> ''
ORDER BY location, date
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Join CovidDeaths and CovidVaccination tables
SELECT cd.continent, 
	   cd.location, 
       cd.date, 
       cd.population, 
       cv.new_vaccinations,
       SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS total_people_vaccinated
FROM CovidDeaths cd
JOIN CovidVaccination cv
	USING (location, date, iso_code, continent)
    WHERE continent <> ''
    ORDER BY cd.continent, cd.location, cd.date
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Temp table: Percentage_population_vaccinated

DROP TABLE IF EXISTS Percentage_population_vaccinated;
CREATE TABLE Percentage_population_vaccinated
	(
    continent CHAR(20),
    location CHAR(50),
    date DATE,
    population INT,
    new_vaccinations INT,
    total_people_vaccinated INT
    )
;
ALTER TABLE Percentage_population_vaccinated
MODIFY COLUMN total_people_vaccinated BIGINT
;
INSERT INTO Percentage_population_vaccinated
(SELECT 
	   cd.continent, 
	   cd.location, 
       cd.date, 
       cd.population, 
       cv.new_vaccinations,
       SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS total_people_vaccinated
FROM CovidDeaths cd
JOIN CovidVaccination cv
	USING (location, date, iso_code, continent)
)
;
SELECT *, (total_people_vaccinated/population)*100 AS percentage_population_vaccinated
FROM Percentage_population_vaccinated
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creating view to store data for later visualizations
DROP VIEW IF EXISTS percentage_population_vaccinated_view;
CREATE VIEW percentage_population_vaccinated_view AS 
SELECT cd.continent, 
	   cd.location, 
       cd.date, 
       cd.population, 
       cv.new_vaccinations,
       SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS total_people_vaccinated
		FROM CovidDeaths cd
		JOIN CovidVaccination cv
			USING (location, date, iso_code, continent)
		WHERE continent <> ''
		;