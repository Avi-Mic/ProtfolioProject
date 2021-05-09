SELECT *
FROM ProtfolioProject..CovidDeath
ORDER BY 3,4

SELECT *
FROM ProtfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT continent ,date, total_cases, new_cases, total_deaths, population
FROM ProtfolioProject..CovidDeath
ORDER BY 1,2

-- Total cases VS Total deaths

SELECT continent,location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ProtfolioProject..CovidDeath
WHERE continent is not null
ORDER BY 2

-- Total cases VS Population

SELECT continent, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM ProtfolioProject..CovidDeath
--WHERE location like 'Israel'
ORDER BY 1,2


SELECT continent, MAX(total_cases) HighestIfectionRate, population, MAX((total_cases/population))*100 as InfectionPercentage
FROM ProtfolioProject..CovidDeath
--WHERE location like 'Israel'
GROUP BY continent, population
ORDER BY InfectionPercentage DESC

-- Highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM ProtfolioProject..CovidDeath
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC

--Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentages
FROM ProtfolioProject..CovidDeath
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Total population VS Vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM ProtfolioProject..CovidDeath as dea JOIN ProtfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated) 
	as
		(
		SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
		
FROM ProtfolioProject..CovidDeath as dea JOIN ProtfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
		)

SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- Create view for visualization
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM ProtfolioProject..CovidDeath as dea JOIN ProtfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null