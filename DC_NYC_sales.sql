--DATA CLEANING:

--Load in the data
SELECT *
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`

--Delete duplicates
CREATE OR REPLACE TABLE `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
AS
SELECT DISTINCT * FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`


--Create ID column
CREATE OR REPLACE TABLE `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
AS
SELECT
  ROW_NUMBER() OVER() AS id,
  *
FROM
  `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`


--Update Borough Column
CREATE OR REPLACE TABLE `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc` AS
SELECT *,
   CASE WHEN CAST(BOROUGH AS STRING) = '1' THEN 'Manhattan'
        WHEN CAST(BOROUGH AS STRING) = '2' THEN 'Bronx'
        WHEN CAST(BOROUGH AS STRING) = '3' THEN 'Brooklyn'
        WHEN CAST(BOROUGH AS STRING) = '4' THEN 'Queens'
        WHEN CAST(BOROUGH AS STRING) = '5' THEN 'Staten Island'
  END AS BOROUGH_CLEAN
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`


--Break Address into 2 columns
CREATE OR REPLACE TABLE `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc` AS
WITH split_data AS (
  SELECT *,
    SPLIT(ADDRESS, ',') AS STREET_ADDRESS
  FROM 
    `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
)

SELECT 
  *,
  IF(
    ARRAY_LENGTH(STREET_ADDRESS) >= 2,
    STREET_ADDRESS[OFFSET(0)],
    ADDRESS
  ) AS ADDRESS_CLEAN,
  IF(
    ARRAY_LENGTH(STREET_ADDRESS) >= 2,
    STREET_ADDRESS[OFFSET(1)],
    NULL
  ) AS UNIT_CLEAN
FROM 
  split_data


--Create year column
CREATE OR REPLACE TABLE `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc` AS
SELECT *,
   CASE WHEN DATE_STRING LIKE '2024%' THEN '2024'
        WHEN DATE_STRING LIKE '2023%' THEN '2023'
  END AS YEAR
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`


--Add month column
CREATE OR REPLACE TABLE `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc` AS 
WITH a AS (
select *, cast(format_date('%Y%m%d', SALE_DATE) as STRING) AS DATE_STRING
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
)

SELECT *,
  CASE
  WHEN a.DATE_STRING LIKE ('202401%') OR a.DATE_STRING LIKE ('202301%') THEN 'January'
	WHEN a.DATE_STRING LIKE ('202402%') OR a.DATE_STRING LIKE ('202302%') THEN 'February'
  WHEN a.DATE_STRING LIKE ('202403%') OR a.DATE_STRING LIKE ('202303%') THEN 'March'
	WHEN a.DATE_STRING LIKE ('202404%') OR a.DATE_STRING LIKE ('202304%') THEN 'April'
	WHEN a.DATE_STRING LIKE ('202405%') OR a.DATE_STRING LIKE ('202305%') THEN 'May'
	WHEN a.DATE_STRING LIKE ('202406%') OR a.DATE_STRING LIKE ('202306%') THEN 'June'
	WHEN a.DATE_STRING LIKE ('202407%') OR a.DATE_STRING LIKE ('202307%') THEN 'July'
	WHEN a.DATE_STRING LIKE ('202408%') OR a.DATE_STRING LIKE ('202308%') THEN 'August'
	WHEN a.DATE_STRING LIKE ('202409%') OR a.DATE_STRING LIKE ('202309%') THEN 'September'
	WHEN a.DATE_STRING LIKE ('202410%') OR a.DATE_STRING LIKE ('202310%') THEN 'October'
	WHEN a.DATE_STRING LIKE ('202411%') OR a.DATE_STRING LIKE ('202311%') THEN 'November'
	WHEN a.DATE_STRING LIKE ('202412%') OR a.DATE_STRING LIKE ('202312%') THEN 'December'
  ELSE a.DATE_STRING
END AS MONTH
FROM a

--Rename SALE PRICE
ALTER TABLE `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
  RENAME COLUMN ` SALE_PRICE ` TO SALE_PRICE;

--Only include one/two family dwellings, walk up apartents, elevator apartments, condominiums, and primarily residential mixed-use buildings. Found the corresponding codes from https://www.nyc.gov/assets/finance/jump/hlpbldgcode.html 
CREATE OR REPLACE TABLE `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc` AS
SELECT *
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
WHERE BUILDING_CLASS_AT_TIME_OF_SALE LIKE 'A%' OR BUILDING_CLASS_AT_TIME_OF_SALE LIKE 'B%' OR BUILDING_CLASS_AT_TIME_OF_SALE LIKE 'C%' OR BUILDING_CLASS_AT_TIME_OF_SALE LIKE 'D%' OR BUILDING_CLASS_AT_TIME_OF_SALE LIKE 'R%' OR BUILDING_CLASS_AT_TIME_OF_SALE LIKE 'S%'


--Full list of all multi-unit transactions within the same building:
WITH b AS (
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY BLOCK,
LOT,
SALE_PRICE,
SALE_DATE
) AS row_num
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
ORDER BY BLOCK, LOT
)

SELECT *
FROM b
WHERE Row_num =2 AND SALE_PRICE > 1000 -- 107

--List of all multi-unit transactions within the same building of 3 or more units:
WITH b AS (
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY BLOCK,
LOT,
SALE_PRICE,
SALE_DATE
) AS row_num
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
ORDER BY BLOCK, LOT
)

SELECT *
FROM b
WHERE Row_num =3 AND SALE_PRICE > 1000 --33


--Delete all but 1 sale from multi-sale transactions to get more accurate sale $'s, since every row within a multi sale transaction lists the total amount of the combined transaction. Create a second data set for this. Found one of these multi-sale transactions here: https://therealdeal.com/new-york/2023/10/04/columbia-seminary-buys-campus-condos/ 
SELECT *
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`

CREATE OR REPLACE TABLE `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL` AS
WITH b AS (
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY BLOCK, LOT,
SALE_PRICE,
SALE_DATE
) AS row_num
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
ORDER BY BLOCK, LOT
)

SELECT *
FROM b
WHERE Row_num = 1 AND SALE_PRICE > 0


--Sale price accuracy is still limited in the data, because the issue with sale price in multi-sale transactions is still not controlled for sales that took place on different days/months or in different buildings. Even though certain deals didn't close on the same day/in the same building, they are still considered multi-sale transactions. The above code only controls for sales that occurred in the same building and on the same day.
SELECT a.id, a.ADDRESS_CLEAN, a.MONTH, b.MONTH
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc` a
JOIN `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL` b
ON a.ADDRESS_CLEAN=b.ADDRESS_CLEAN 
WHERE a.SALE_PRICE = b.SALE_PRICE AND a.MONTH <> b.MONTH

SELECT a.id, a.DATE_STRING, a.ADDRESS_CLEAN, b.ADDRESS_CLEAN
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc` a
JOIN `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL` b
ON a.DATE_STRING=b.DATE_STRING 
WHERE a.SALE_PRICE = b.SALE_PRICE AND a.ADDRESS_CLEAN <> b.ADDRESS_CLEAN
