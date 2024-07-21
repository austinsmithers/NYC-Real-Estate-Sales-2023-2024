--EXPLORATORY DATA ANALYSIS:

--AVG sale price
SELECT ROUND(AVG(SALE_PRICE), 0)
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
WHERE SALE_PRICE > 1000 --Put limit on sale_price for analysis, smaller sale prices not accurate or are considered "non-market" sales. Non-market sales: sales between related parties, auctions, foreclosures and income restricted sales.


--Avg sale price per borough and neighborhood
SELECT BOROUGH_CLEAN, NEIGHBORHOOD, ROUND(AVG(SALE_PRICE), 0) AS AVG_SALE_PRICE
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
WHERE SALE_PRICE > 1000
GROUP BY BOROUGH_CLEAN, NEIGHBORHOOD
ORDER BY AVG_SALE_PRICE desc


--Avg price per Month
SELECT MONTH, ROUND(AVG(SALE_PRICE), 0) AS avg_price
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
WHERE SALE_PRICE > 1000
GROUP BY MONTH
ORDER BY avg_price DESC


--AVG/MAX/MIN/SUM prices and count per neighborhood
SELECT BOROUGH, NEIGHBORHOOD, ROUND(AVG(SALE_PRICE), 0) AS avg_price, ROUND(MAX(SALE_PRICE), 0) AS max_price, ROUND(MIN(SALE_PRICE), 0) AS min_price, ROUND(SUM(SALE_PRICE), 0) AS total_sale_volume
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
WHERE SALE_PRICE > 1000
GROUP BY BOROUGH, NEIGHBORHOOD
ORDER BY total_sale_volume DESC, avg_price DESC, max_price DESC, min_price DESC


--AVG sale price per borough across building types
SELECT BOROUGH_CLEAN, BUILDING_CLASS_CATEGORY, ROUND(AVG(SALE_PRICE), 0) AS avg_price
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
WHERE SALE_PRICE > 1000
GROUP BY BOROUGH_CLEAN, BUILDING_CLASS_CATEGORY
ORDER BY BOROUGH_CLEAN


--Count of Sales by Borough, Including non-market sales
SELECT BOROUGH_CLEAN, COUNT(*) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
GROUP BY BOROUGH_CLEAN
ORDER BY COUNT(*) DESC -- Queens most popular


--Count of Sales by Borough, Excluding non-market sales
WITH a AS (
  SELECT *
  FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
  WHERE SALE_PRICE > 1000)
SELECT BOROUGH_CLEAN, COUNT(*) AS sale_count
FROM a
GROUP BY BOROUGH_CLEAN
ORDER BY COUNT(*) DESC -- slightly more than the above code


--How many transactions am I classifying as 'non-market'?
WITH a AS (
SELECT id, BOROUGH_CLEAN, COUNT(*) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
GROUP BY id, BOROUGH_CLEAN
ORDER BY COUNT(*) DESC -- Queens most popular
),
b AS (
SELECT id, BOROUGH_CLEAN, COUNT(*) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
WHERE SALE_PRICE > 1000
GROUP BY id, BOROUGH_CLEAN
ORDER BY COUNT(*) DESC -- slightly more than the above code
)

SELECT a.id, b.id
FROM a
LEFT JOIN b
ON a.id=b.id
WHERE b.id IS NULL


--Count of sales by Neighborhood
SELECT NEIGHBORHOOD, COUNT(*) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
GROUP BY NEIGHBORHOOD
ORDER BY COUNT(*) DESC -- Flushing-North Queens most popular


--Count of sales per Month
SELECT MONTH, COUNT(*) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
WHERE SALE_PRICE > 1000
GROUP BY MONTH
ORDER BY sale_count DESC


--Count of Sales by Decade
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


--Count of Sales by Building_Type
SELECT BUILDING_CLASS_CATEGORY, COUNT(*) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
WHERE SALE_PRICE > 1000
GROUP BY BUILDING_CLASS_CATEGORY
ORDER BY sale_count desc


--Top building type by Borough
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


--Count of Sales by borough and month
SELECT YEAR, MONTH, BOROUGH_CLEAN, COUNT(*) AS sale_count,
ROW_NUMBER () OVER (
PARTITION BY BOROUGH_CLEAN, YEAR, 
MONTH ORDER BY YEAR, MONTH
) AS row_num
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc`
GROUP BY YEAR, MONTH, BOROUGH_CLEAN
ORDER BY YEAR, MONTH


--Profile of apartments included in multi-sale transactions
SELECT a.id, b.id, a.NEIGHBORHOOD, a.ADDRESS_CLEAN, a.SALE_DATE
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc` as a
LEFT JOIN `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL` as b
ON a.id = b.id
WHERE b.id IS NULL
ORDER BY a.id

--Q1 Sales Above Average Price
WITH above_average_sales AS (
SELECT id, BOROUGH_CLEAN, NEIGHBORHOOD
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
WHERE SALE_PRICE > 1549346.0
),
q1 AS (
SELECT id, BOROUGH_CLEAN, NEIGHBORHOOD, SALE_PRICE
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
WHERE MONTH = 'January' OR MONTH = 'February' OR MONTH = 'March'
)
SELECT above_average_sales.id, above_average_sales.BOROUGH_CLEAN, above_average_sales.NEIGHBORHOOD, q1.SALE_PRICE
FROM above_average_sales
JOIN q1
ON above_average_sales.id = q1.id

--Standardize pricing
SELECT
    MIN(SALE_PRICE) AS min_price,
    MAX(SALE_PRICE) AS max_price
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`

SELECT 
    id,
    BOROUGH_CLEAN,
    SALE_PRICE,
    (SALE_PRICE - 1) / (963000000 - 1) AS price_standardized
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL`
ORDER BY price_standardized desc

