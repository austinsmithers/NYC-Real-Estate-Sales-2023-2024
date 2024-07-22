# NYC Real Estate Sales 2023-2024

---

### Project Overview

The goal of this project was to explore residential transactions in NYC to discover trends in both the number of sales and sale prices across multiple variables, including borough, neighborhood, month, and building type. The data set consists of one full year of all market and non-market sales that closed between June 2023 - May 2024. The data includes location information (borough, neighborhood, address, block/lot number, zip code), information about the building (building class/building class category, year built, tax class, square footage) and information on the sale (sale price/date).

### Data Sources

The primary dataset used for this analysis is "rollingsales_nyc.csv" containing detailed information from data.gov on all real estate sale transactions that occurred in New York City from June 2023 to May 2024.

### Tools

- BigQuery - Data Analysis
- Tableau - Creating Report

### Data Cleaning/Preparation
In the initial data preparation phase, I performed the following:
1. Loaded the data and inspected it, removing duplicates.
2. Creaded an ID column to assign a unique ID to each row.
3. Updated columns:
- Updated BOROUGH column to read the full name of each borough, rather than the first letter
- Broke Address and unit number into 2 columns
- Added YEAR and MONTH columns
- Re-named SALE_PRICE to remove unnecessary spacing
4. Removed non-residential buildings, as I intended to focus on residential transactions.
5. Created a second data set that controlled for sale prices in multi-unit transactions. Used this data set for all sale price related EDA
6. I decided to keep all columns, even if they were not used in my EDA, in case I decided to re-visit the project later.

### Exploratory Data Analysis

My EDA involved exploring the data to answer key questions:

- How many sales occurred in each borough and neighborhood? Where do most sales occur?
- How does sale volume change over time?
- How do building characteristics affect sale volume? What building types are trading and where?

### Data Analysis

Through my analaysis, I employed different techniques, including aggregations, CTE's, joins, window functions, case statements, etc. to answer the above questions. The following code uses 2 CTE's and a join to find the transactions that sold in Q1 (January, February or March) at a price above the total average:

```sql
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
```

The following code uses a CTE, cast, CASE statement, and an aggregation to determine in what decades were buildings built that had units sold during this time period, and how many buildings were built in each decade.

```sql
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
ORDER BY b.DECADE
```

### Results/Findings

- How many sales occurred in each borough and neighborhood? Where do most sales occur?
- How does sale volume change over time?
- How do building characteristics affect sale volume? What building types are trading and where?

The analysis results are summarized as follows:
1. Most sales occured in Queens compared to any other borough. Flushing-North, Queens had the most sales of any neighborhood. In contrast, Manhattan had the highest overall average price per transaction.
2. The months with the highest levels of sales were August, June and October. Something to note is that sales are recorded at the time of closing, which comes about 3-4 months after the initial offer/contract signing. This means that buyer interest/activity is spiking roughly in March, May and July.
3. Co-ops in elevator buildings, one-family dwellings, and condos in elevator apartments were the most popular apartments that traded. Additionally, buildings built in the 1920's were the most popular to buyers during this period.

### Implications/Recommendations:

Given the data, I would have different recommendations depending on my role as an agent (advising a buyer or a seller). As a buyer's agent, I would advise my client to look at apartments during months that have less activity if they are looking for a deal. If they want more options, they should look during the busier months. Lastly, if they are flexible on location, I would have them look in boroughs/neighborhoods that are just starting to gain popularity. This could help them build equity over time if they are looking to keep the apartment long-term.
As a sellers agent, I would advise my clients to put their apartment on the market during the months that experience the highest buyer activity (March, May and July). Additionally, I would encourage clients with apartments in single-family homes or co-op/condo elevator buildings from the 1920's-1930's to consider selling now, since that is what people want in today's market.

### Limitations

There were a few limitations within this data set. One limitation was that each row (apartment) included in a multi-sale transaction did not report the individual sale price for that apartment, but rather the sale price for all of the apartments in the multi-sale transaction. This resulted in an inflated sale volume when analyzing the data. Although I was able to control for some of these transactions, others were not controlled for if the transactions did not close on the same day, in the same building, or if the same building address was written differently for different apartments. Therefore, it is important to note that these numbers might be slightly inflated across all boroughs. I mostly included this field in my analysis to understand how boroughs ranked against each other, rather than to determine accurate sale prices. Additionally, I intended to only analyze residential buildings, but the building categories included in the data set did not fully separate residential and commercial buildings. This fact also may be contributing to inflated sales volume, since commercial listings are often more expensive. Since I was mainly looking for trends and practicing my SQL skills, I continued on with my analysis. If I were to actually use this data set with a client, I would focus on a smaller section of the data, making sure to go through and completely control for the multi-sale transactions and remove all commercial buildings.

### References

1. BigQuery
2. [Data.gov](https://data.gov/)
