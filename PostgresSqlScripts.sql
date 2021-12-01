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

-- 4. Calculate cumulative/running value of GDP per region ordered by income from lowest to highest and country name.


--- 5 Calculate percentage difference in value of GDP year-on-year per country

select "CountryName", "CountryCode",
(("2019"-"2018")*100)/(CASE WHEN "2018"=0 THEN 1 ELSE "2018" END) as "YoY%Change2019",
(("2020"-"2019")*100)/(CASE WHEN "2019"=0 THEN 1 ELSE "2019" END) as "YoY%Change2020",
(("2021"-"2020")*100)/(CASE WHEN "2020"=0 THEN 1 ELSE "2020" END) as "YoY%Change2021",
(("2022"-"2021")*100)/(CASE WHEN "2021"=0 THEN 1 ELSE "2021" END) as "YoY%Change2022" 
from
(select "CountryName", "CountryCode", "IndicatorName","IndicatorCode","2018","2019","2020","2021","2022"
from public."worldBankDataCatalogueGep" 
where "CountryCode" <> ALL (array['AME','EAA','EMD','E19','ECH','LAP','MNH','SAP','SSP','WLT'])) rslt
