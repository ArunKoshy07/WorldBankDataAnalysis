-- 1. List countries with income level of "Upper middle income"
select "name" as "Country Name","adminregionvalue" as "Region", "incomeLevelvalue" as "Income Level" 
from public."worldBankGdpCnty" where "incomeLevelid" = 'UMC'

-- 2. List countries with income level of "Low income" per region.
select "regionid", "adminregionvalue" as "Region", "name" as "Country Name", 
"incomeLevelvalue" as "Income Level" 
from public."worldBankGdpCnty" 
where "incomeLevelid" = 'LIC'
group by (regionid, adminregionvalue,"name", "incomeLevelvalue")
order by regionid


-- 3. Find the region with the highest proportion of "High income" countries.

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
/*
Income value is not provided in any of the tables so query with order by income is not possible. 
The query could be updated to have order by cumulative GDP for a year.  below query shows the regions 
with ascending cumulative GDP for year 2021. 
*/
select final_rslt.regionvalue, final_rslt.sum_2021
from (
select cnty.regionid, cnty.regionvalue, 
ROUND (sum(rslt."2018")::numeric,2) as sum_2018,
ROUND (sum(rslt."2019")::numeric,2) as sum_2019, 
ROUND (sum(rslt."2020")::numeric,2) as sum_2020,
ROUND (sum(rslt."2021")::numeric,2) as sum_2021,
ROUND (sum(rslt."2022")::numeric,2) as sum_2022
from
(select "CountryCode","2018","2019","2020","2021","2022"
from public."worldBankDataCatalogueGep" 
where "CountryCode" <> ALL (array['AME','EAA','EMD','E19','ECH','LAP','MNH','SAP','SSP','WLT'])) rslt  
LEFT JOIN public."worldBankGdpCnty" as cnty on cnty.id = rslt."CountryCode"
GROUP BY (cnty.regionid,cnty.regionvalue)) final_rslt
GROUP BY (final_rslt.regionvalue,final_rslt.sum_2021)
ORDER BY (sum_2021)

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


--- 6 List 3 countries with lowest GDP per region.
select finalrslt.* 
from
(
select cnty.regionid, cnty.regionvalue, cnty.id,
rslt."CountryName", rslt."2021" as "gdp2021", 
RANK() OVER(PARTITION BY cnty.regionid ORDER BY rslt."2021" ASC) as "country_rank" 
from
(select "CountryName", "CountryCode", "IndicatorName","IndicatorCode","2018","2019","2020","2021","2022"
from public."worldBankDataCatalogueGep" 
where "CountryCode" <> ALL (array['AME','EAA','EMD','E19','ECH','LAP','MNH','SAP','SSP','WLT'])) rslt  
LEFT JOIN public."worldBankGdpCnty" as cnty on cnty.id = rslt."CountryCode" ) finalrslt
WHERE finalrslt.country_rank < 4
ORDER BY finalrslt.regionid,finalrslt.country_rank
 
 
--- 7 Provide an interesting fact from dataset
'''
In the below query, GDP growth for maldives is around 9.5 where US is 3.5 for the year 2021, however for the year 2021 the US 
GDP in USD is $20T and Maldives GDP is 5.3B. So, even if the GDP growth numbers are high, for analysis purpose we need it to be 
combined with GDP in USD or in a common currency to show how the various economies are performing. 
(Data Source - https://georank.org/economy/maldives/united-states)
'''
select finalrslt.* 
from
(
select cnty.regionid, cnty.regionvalue, cnty.id,
rslt."CountryName", rslt."2021" as "gdp2021", 
RANK() OVER(PARTITION BY cnty.regionid ORDER BY rslt."2021" DESC) as "country_rank" 
from
(select "CountryName", "CountryCode", "IndicatorName","IndicatorCode","2018","2019","2020","2021","2022"
from public."worldBankDataCatalogueGep" 
where "CountryCode" <> ALL (array['AME','EAA','EMD','E19','ECH','LAP','MNH','SAP','SSP','WLT'])) rslt  
LEFT JOIN public."worldBankGdpCnty" as cnty on cnty.id = rslt."CountryCode" ) finalrslt
WHERE finalrslt.country_rank < 4
ORDER BY finalrslt.gdp2021

--------------------------- Other Queries
-- select * from public."worldBankGdpRegn"
-- select * from public."worldBankGdpCnty"
-- select * from public."worldBankDataCatalogueGep"