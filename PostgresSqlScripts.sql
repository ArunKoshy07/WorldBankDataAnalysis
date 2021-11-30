-- 1. List of countries with income level of "Upper middle income"
select "name" as "Country Name","adminregionvalue" as "Region", "incomeLevelvalue" as "Income Level" 
from public."worldBankGdpCnty" where "incomeLevelid" = 'UMC'

-- 2. List of countries with income level of "Low income" per region.
select "regionid", "adminregionvalue" as "Region", "name" as "Country Name", 
"incomeLevelvalue" as "Income Level" 
from public."worldBankGdpCnty" 
where "incomeLevelid" = 'LIC'
group by (regionid, adminregionvalue,"name", "incomeLevelvalue")
order by regionid


-- 3. The region with the highest proportion of "High income" countries.

select rslt.name as "Region",rslt.noofcountries "No of countries in High Income level",rslt.region_rank as "Region Rank" from(
select cnty.regionid,cnty.noofcountries, RANK() OVER( ORDER BY cnty.noofcountries DESC) as "region_rank" ,reg.name 
from (
select regionid,count(name) as noofcountries
from public."worldBankGdpCnty" 
where "incomeLevelid" = 'HIC'
group by (regionid)) cnty
LEFT JOIN public."worldBankGdpRegn" as reg on reg.id = cnty.regionid ) rslt
where rslt.region_rank = 1;

