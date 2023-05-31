--Select *
--from PortProject..CovidVacinations

-- Join some columns of CovidDeaths and CovidVaccinations 

-- Looking at Total Population Vs Vaccinations
-- What is the total amt of people in the world that have been vaccinated.

select Death.continent, Death.location, Death.date, population, Vaccination.new_vaccinations
, SUM(CONVERT(int, Vaccination.new_vaccinations)) OVER (Partition by Death.location Order by Death.location,
Death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
-- This line will give us an error because we are not able to use this name again.
from PortProject..CovidDeaths as Death
Join PortProject..CovidVacinations as Vaccination
	On Death.location = Vaccination.location
	and Death.date = Vaccination.date
where Death.continent is not null




-- 1st Way Using With to create RollingPeopleVaccinated as a column and find amt of population vaccinated.
-- USE CTE to solve RollingPeopleVaccinated problem

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select Death.continent, Death.location, Death.date, population, Vaccination.new_vaccinations
, SUM(CONVERT(int, Vaccination.new_vaccinations)) OVER (Partition by Death.location Order by Death.location,
Death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
-- This line will give us an error because we are not able to use this name again.
from PortProject..CovidDeaths as Death
Join PortProject..CovidVacinations as Vaccination
	On Death.location = Vaccination.location
	and Death.date = Vaccination.date
where Death.continent is not null
)	
Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
from PopVsVac



-- 2nd Way Using Temp Table to create RollingPeopleVaccinated as a column and find amt of population vaccinated.
-- USE Temp Table to solve RollingPeopleVaccinated problem

-- TEMP Table
-- If you run this table query again, it will give us an error called 
-- "There is already an object named '#PercentPopulationVaccinated' in the database." So write this

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Data datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select Death.continent, Death.location, Death.date, population, Vaccination.new_vaccinations
, SUM(CONVERT(int, Vaccination.new_vaccinations)) OVER (Partition by Death.location Order by Death.location,
Death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
-- This line will give us an error because we are not able to use this name again.
from PortProject..CovidDeaths as Death
Join PortProject..CovidVacinations as Vaccination
	On Death.location = Vaccination.location
	and Death.date = Vaccination.date
where Death.continent is not null

--Query to find out the same table as we did using WITH
Select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


-- Creating a view for later visualization
-- Drop View if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
select Death.continent, Death.location, Death.date, population, Vaccination.new_vaccinations
, SUM(CONVERT(int, Vaccination.new_vaccinations)) OVER (Partition by Death.location Order by Death.location,
Death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
-- This line will give us an error because we are not able to use this name again.
from PortProject..CovidDeaths as Death
Join PortProject..CovidVacinations as Vaccination
	On Death.location = Vaccination.location
	and Death.date = Vaccination.date
where Death.continent is not null

