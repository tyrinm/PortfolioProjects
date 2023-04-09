SELECT location, date, total_cases, new_cases, total_deaths, population
FROM "COVID DEATHS"
ORDER BY 1, 2;

// death rate
SELECT location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases*1.0)*100 AS DeathPercentage
FROM "COVID DEATHS"
WHERE location LIKE "%states%"
ORDER BY 1, 2;
// infection rate
SELECT location, date, population, total_cases, (total_cases*1.0/population*1.0)*100 AS InfectionRatePercentage
FROM "COVID DEATHS"
WHERE location LIKE "%states%"
ORDER BY 1, 2;

// Highest infection rate per country
SELECT location, population, MAX(total_cases) as HighestInfectionCount  , MAX(total_cases*1.0/population*1.0)*100 AS InfectionRatePercentage
FROM "COVID DEATHS"
GROUP BY population, location
ORDER BY InfectionRatePercentage DESC;

// Highest death rate per country
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM "COVID DEATHS"
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;

//by continent
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM "COVID DEATHS"
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC;

// global numbers
select date, sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, sum(new_deaths * 1.00)/sum(new_cases * 1.00) *100 as DailyDeathRate
from "COVID DEATHS"
where location is not null
group by date
order by 1,2;

// vaccinations
SELECT * from "COVID DEATHS" dea
join "COVID VAX" vax
on dea.location = vax.location
and dea.date = vax.date;

//total pop vs vax

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
FROM "COVID DEATHS" dea
join "COVID VAX" vax
on dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null
order by 2,3;

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
       sum(vax.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingcount
FROM "COVID DEATHS" dea
join "COVID VAX" vax
on dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null
order by 2,3;

//cte

With popvsvac (continent, location, date, population, new_vaccinations, rollingcount)
    as
    (
    Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
       sum(vax.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingcount
FROM "COVID DEATHS" dea
join "COVID VAX" vax
on dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null
    )
    select *, (rollingcount*1.0/population*1.0)*100
    from popvsvac

// create view

CREATE VIEW totalvaxdpop as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
       sum(vax.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingcount
FROM "COVID DEATHS" dea
join "COVID VAX" vax
on dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null

CREATE VIEW globalnumbers as
select date, sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, sum(new_deaths * 1.00)/sum(new_cases * 1.00) *100 as DailyDeathRate
from "COVID DEATHS"
where location is not null
group by date;

CREATE VIEW maxinfectionbycountry as
    SELECT location, population, MAX(total_cases) as HighestInfectionCount  , MAX(total_cases*1.0/population*1.0)*100 AS InfectionRatePercentage
FROM "COVID DEATHS"
GROUP BY population, location;

CREATE VIEW maxdeathbycountry as
    SELECT location, MAX(total_deaths) as TotalDeathCount
FROM "COVID DEATHS"
WHERE continent is not null
GROUP BY location