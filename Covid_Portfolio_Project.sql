Select * from 
[dbo].[CovidDeaths$]
Where continent is not null
Order By 3,4

--Select * From [dbo].[CovidVaccinations$]
--Order By 3,4

--DATA BEING USED BY LOCATION

Select location, date, total_cases, new_cases, total_deaths, population from 
[dbo].[CovidDeaths$]
Where continent is not null
Order By 1,2

--looking at Total_cases vs Total_deaths
--Shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from 
[dbo].[CovidDeaths$]
Where continent is not null
Order By 1,2

--looking at Total_cases vs population

Select location, date, population,total_cases,(total_cases/population)*100 as Percent_population_infected from 
[dbo].[CovidDeaths$]
where location like '%states%'
and continent is not null
Order By 1,2

--Looking at countries with highest infection rate compared to population

Select location,population, max(total_cases) as Highestinfectioncount,  Max(total_cases/population)*100 as Percent_population_infected from 
[dbo].[CovidDeaths$]
where location like '%states%'
and continent is not null
Group By location,population
Order By 1,2

--Showing countries with highest death count/population

Select location, Max(Cast(Total_deaths as INT)) as TotalDeathcount from 
[dbo].[CovidDeaths$]
--where location like '%states%'
Where continent is  not null
Group By location
Order By TotalDeathcount DESC


--DATA BEING USED BY CONTINENT

Select continent, Max(Cast(Total_deaths as INT)) as TotalDeathcount from 
[dbo].[CovidDeaths$]
--where location like '%states%'
Where continent is not null
Group By continent
Order By TotalDeathcount DESC

-- Global data

Select sum(new_cases) as Total_cases, Sum(cast(new_deaths as int))as total_deaths, SUM(CAST(new_deaths as INT))/SUM(New_cases)*100 as DeathPercentage
FROM [dbo].[CovidDeaths$]
wHERE continent is not null
--Group By date
order by 1,2

--Looking at Total population vs Vaccinations

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
    Sum(Cast(Vac.new_vaccinations As Int)) Over (Partition by Dea.location Order by Dea.location, Dea.Date) as Rolling_People_Vaccinated,
	--(Rolling_People_Vaccinated/population)*100,
FROM [dbo].[CovidDeaths$] as Dea
JOIN [dbo].[CovidVaccinations$] as Vac
ON Dea.location = Vac.Location
and Dea.date = Vac.date
where Dea.continent is not null
Order by 2,3


-- USE CTE

With PopVsVac (Continent, Location, Date, Population,new_vaccinations, Rolling_People_Vaccinated) as 
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
    Sum(Cast(Vac.new_vaccinations As Int)) Over (Partition by Dea.location Order by Dea.location, Dea.Date) as Rolling_People_Vaccinated
	--(Rolling_People_Vaccinated/population)*100,
FROM [dbo].[CovidDeaths$] as Dea
JOIN [dbo].[CovidVaccinations$] as Vac
ON Dea.location = Vac.Location
and Dea.date = Vac.date
where Dea.continent is not null
--Order by 2,3
)

Select *, (Rolling_People_Vaccinated/population)*100 AS PercentOfPeopleVaccinated
From PopVsVac

--USE TempTable

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255), 
location nvarchar (255), 
date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
    Sum(Cast(Vac.new_vaccinations As Int)) Over (Partition by Dea.location Order by Dea.location, Dea.Date) as Rolling_People_Vaccinated
	--(Rolling_People_Vaccinated/population)*100,
FROM [dbo].[CovidDeaths$] as Dea
JOIN [dbo].[CovidVaccinations$] as Vac
ON Dea.location = Vac.Location
and Dea.date = Vac.date
--where Dea.continent is not null
--Order by 2,3

Select *, (Rolling_People_Vaccinated/population)*100 AS PercentOfPeopleVaccinated
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
   Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
    Sum(Cast(Vac.new_vaccinations As Int)) Over (Partition by Dea.location Order by Dea.location, Dea.Date) as Rolling_People_Vaccinated
	--(Rolling_People_Vaccinated/population)*100,
FROM [dbo].[CovidDeaths$] as Dea
JOIN [dbo].[CovidVaccinations$] as Vac
ON Dea.location = Vac.Location
and Dea.date = Vac.date
--where Dea.continent is not null
--Order by 2,3