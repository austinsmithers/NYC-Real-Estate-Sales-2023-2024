--EXPLORATORY DATA ANALYSIS:

--Note on issue with new data set: some buyers didnt close all of their transactions on the same day or in the same building or even the same month, but their total amount spent on all units is still listed for each individual transaction. This would need to be manually fixed, or addressed beyond my expertise.

--AVG sale price
SELECT ROUND(AVG(SALE_PRICE), 0)
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`


--AVG Sales by Neighborhood
SELECT BOROUGH_CLEAN, NEIGHBORHOOD, ROUND(AVG(SALE_PRICE), 0) AS AVG_SALE_PRICE
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
WHERE SALE_PRICE > 1000
GROUP BY BOROUGH_CLEAN, NEIGHBORHOOD
ORDER BY BOROUGH_CLEAN, NEIGHBORHOOD -- put limit on sale_price for analysis because smaller sale prices do not make sense or are considered "non-market" sales.


--Avg sales and count of sales per neighborhood
SELECT BOROUGH_CLEAN, NEIGHBORHOOD, ROUND(AVG(SALE_PRICE), 0) AS AVG_SALE_PRICE
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
WHERE SALE_PRICE > 1000
GROUP BY BOROUGH_CLEAN, NEIGHBORHOOD
ORDER BY AVG_SALE_PRICE desc

SELECT BOROUGH_CLEAN, NEIGHBORHOOD, COUNT(*) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
WHERE SALE_PRICE > 1000
GROUP BY BOROUGH_CLEAN, NEIGHBORHOOD
ORDER BY sale_count desc


--Non-market sales: sales between related parties, auctions, foreclosures and income restricted sales
    --Count by Borough, Including non-market sales
SELECT BOROUGH_CLEAN, COUNT(*) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
GROUP BY BOROUGH_CLEAN
ORDER BY COUNT(*) DESC -- Queens most popular

    --Count by Borough, Excluding non-market sales
WITH a AS (
  SELECT *
  FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
  WHERE SALE_PRICE > 1000)
SELECT BOROUGH_CLEAN, COUNT(*) AS sale_count
FROM a
GROUP BY BOROUGH_CLEAN
ORDER BY COUNT(*) DESC -- Queens most popular
    
    --Count by Neighborhood, Including non-market sales
SELECT NEIGHBORHOOD, COUNT(*) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
GROUP BY NEIGHBORHOOD
ORDER BY COUNT(*) DESC -- Flushing-North Queens most popular

    --Count by Neighborhood, Excluding non-market sales
WITH a AS (
  SELECT *
  FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
  WHERE SALE_PRICE > 10)
SELECT NEIGHBORHOOD, COUNT(*)
FROM a
GROUP BY NEIGHBORHOOD
ORDER BY COUNT(*) DESC -- Flushing-North Queens most popular

    --Count by Month, Including non-market sales
SELECT MONTH, COUNT(*) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
GROUP BY MONTH
ORDER BY sale_count DESC

    --Avg price by month, Including non-market sales
SELECT MONTH, ROUND(AVG(SALE_PRICE), 0) AS avg_price
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
GROUP BY MONTH
ORDER BY avg_price DESC

    --Count of sales and avg sale price by month
SELECT MONTH, ROUND(AVG(SALE_PRICE), 0) AS AVG_SALE_PRICE
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
WHERE SALE_PRICE > 1000
GROUP BY MONTH
ORDER BY AVG_SALE_PRICE desc

SELECT MONTH, COUNT(*) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
WHERE SALE_PRICE > 1000
GROUP BY MONTH
ORDER BY sale_count desc


    --Count by Year_Built, Including non-market sales
WITH a AS (
SELECT *,
  CAST(YEAR_BUILT AS STRING) as string
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
),

b AS (
SELECT id,
  CASE
    WHEN string BETWEEN ('1880') AND ('1889') THEN '1880s'
    WHEN string BETWEEN ('1890') AND ('1899') THEN '1890s'
    WHEN string BETWEEN ('1900') AND ('1909') THEN '1900s'
    WHEN string BETWEEN ('1910') AND ('1919') THEN '1910s'
    WHEN string BETWEEN ('1920') AND ('1929') THEN '1920s'
    WHEN string BETWEEN ('1930') AND ('1939') THEN '1930s'
    WHEN string BETWEEN ('1940') AND ('1949') THEN '1940s'
    WHEN string BETWEEN ('1950') AND ('1959') THEN '1950s'
    WHEN string BETWEEN ('1960') AND ('1969') THEN '1960s'
    WHEN string BETWEEN ('1970') AND ('1979') THEN '1970s'
    WHEN string BETWEEN ('1980') AND ('1989') THEN '1980s'
    WHEN string BETWEEN ('1990') AND ('1999') THEN '1990s'
    WHEN string BETWEEN ('2000') AND ('2009') THEN '2000s'
    WHEN string BETWEEN ('2010') AND ('2019') THEN '2010s'
    WHEN string BETWEEN ('2020') AND ('2024') THEN '2020s'
    ELSE '<1880' END AS DECADE
FROM a
)

SELECT b.DECADE, COUNT(*) AS sale_count
FROM b
GROUP BY b.DECADE
ORDER BY b.DECADE -- pre-war is trending (mid/high rise built between 1900-1939)


--Count and AVG sale price by Building_Type, Including non-market sales
SELECT BUILDING_CLASS_CATEGORY, ROUND(AVG(SALE_PRICE), 0) AS AVG_SALE_PRICE
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
WHERE SALE_PRICE > 1000
GROUP BY BUILDING_CLASS_CATEGORY
ORDER BY AVG_SALE_PRICE desc

SELECT BUILDING_CLASS_CATEGORY, COUNT(*) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
WHERE SALE_PRICE > 1000
GROUP BY BUILDING_CLASS_CATEGORY
ORDER BY sale_count desc


--Top building type by borough
WITH a AS (
    SELECT BOROUGH_CLEAN,
           BUILDING_CLASS_CATEGORY,
           COUNT(*) AS building_type_count,
           ROW_NUMBER() OVER (PARTITION BY BOROUGH_CLEAN ORDER BY COUNT(*) DESC) AS rn
    FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
    GROUP BY BOROUGH_CLEAN, BUILDING_CLASS_CATEGORY
)
SELECT BOROUGH_CLEAN, BUILDING_CLASS_CATEGORY, building_type_count
FROM a
WHERE rn =1
ORDER BY building_type_count DESC

--Does the year the building was built correlate with building category?

--2023-2024 sales by borough and month
SELECT YEAR, MONTH, BOROUGH_CLEAN, COUNT(*) AS sale_count,
ROW_NUMBER () OVER (
PARTITION BY BOROUGH_CLEAN, YEAR, 
MONTH ORDER BY YEAR, MONTH
) AS row_num
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
GROUP BY YEAR, MONTH, BOROUGH_CLEAN
ORDER BY YEAR, MONTH


--AVG/MAX prices and count per neighborhood
SELECT NEIGHBORHOOD, ROUND(AVG(SALE_PRICE), 0) AS avg_price, ROUND(MAX(SALE_PRICE), 0) AS max_price, COUNT(*) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
WHERE SALE_PRICE > 1000
GROUP BY NEIGHBORHOOD
ORDER BY avg_price DESC


--AVG sale price per borough across building types
SELECT BOROUGH_CLEAN, BUILDING_CLASS_CATEGORY, ROUND(AVG(SALE_PRICE), 0) AS avg_price
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
WHERE SALE_PRICE > 1000
GROUP BY BOROUGH_CLEAN, BUILDING_CLASS_CATEGORY
ORDER BY BOROUGH_CLEAN


--AVG sale price and count of sales per BUILDING_CLASS_CATEGORY
SELECT a.BOROUGH_CLEAN, a.BUILDING_CLASS_CATEGORY, ROUND(AVG(b.SALE_PRICE), 0) AS avg_price, COUNT(a.id) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc` as a
JOIN `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL` as b
ON a.id = b.id
GROUP BY a.BOROUGH_CLEAN, a.BUILDING_CLASS_CATEGORY
ORDER BY a.BOROUGH_CLEAN, avg_price DESC

