
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

SELECT location, date, total_cases, new_cases, total_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1,2


-- Total_cases vs Total_Deaths + likelihood of dying

SELECT location, date, total_cases, total_deaths, 
CAST(total_deaths AS decimal)/CAST(total_cases AS decimal)*100 AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
Order by 1,2

-- Total_Cases vs Population + Total population affected by Covid

SELECT location, date, population, total_cases, 
CAST(total_cases AS decimal)/CAST(population AS decimal)*100 AS infection_rate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
Order by 1,2

-- Countries with the highest infection rate

SELECT location, population, MAX(total_cases) AS InfectionCount, 
CAST(MAX(total_cases) AS decimal)/CAST(population AS decimal)*100 AS infection_rate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
Order by 4 DESC

-- Countries with the highest DeathCount

SELECT location, CAST(MAX(total_deaths) as int) AS DeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
Order by DeathCount DESC

-- Highest DeathCount By Continent

SELECT continent, CAST(MAX(total_deaths) as int) AS DeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
Order by DeathCount DESC


-- Global Numbers

SELECT  date, SUM(CAST(new_cases as int)) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_Deaths, 
SUM(CAST(new_deaths as decimal))/SUM(CAST(total_cases as decimal))*100 AS Death_Rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by date
Order by 1,2


-- Totoal population vs Vacinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- Created CTE

With PopvsVas (Continent, Location, Date, Population, New_vaccinations, RollingVacinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT*,(RollingVacinations/Population)*100
FROM PopvsVas


-- Temp Table


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)/Population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


-- Creating Visualizations

Create VIEW PercentpopulationVaccinated AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT*
FROM PercentpopulationVaccinated