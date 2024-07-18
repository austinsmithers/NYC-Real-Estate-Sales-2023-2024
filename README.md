# NYC Real Estate Sales 2023-2024

---

### Project Overview

The goal of this project was to explore residential transactions in NYC to discover trends in both the number of sales and sale prices across multiple variables, including borough, neighborhood, month, and building type. The data set consists of one full year of all market and non-market sales that closed between June 2023 - May 2024. The data includes location information (borough, neighborhood, address, block/lot number, zip code), information about the building (building class/building class category, year built, tax class, square footage) and information on the sale (sale price/date).

<img width="253" alt="Screen Shot 2024-06-11 at 10 41 54 PM" src="https://github.com/austinsmithers/Project-1/assets/172429232/7fda4439-bd27-4491-86aa-dae2469ac58e">


### Data Sources

The primary dataset used for this analysis is "rollingsales_nyc.csv" containing detailed information from data.gov on all real estate sale transactions that occurred in New York City from June 2023 to May 2024.

### Tools

- SQL Server - Data Analysis
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

Add viz's if possible here for EDA

- How many sales occurred in each borough and neighborhood? Where do most sales occur?
- How does sale volume change over time?
- How do building characteristics affect sale volume? What building types are trading and where?

### Data Analysis

Through my analaysis, I employed different techniques, including aggregations, CTE's, joins, window functions, case statements, etc. to answer the above questions. The following code used a join and an aggregation to find the average price and sale count per building type and borough:

```sql
SELECT a.BOROUGH_CLEAN, a.BUILDING_CLASS_CATEGORY, ROUND(AVG(b.SALE_PRICE), 0) AS avg_price, COUNT(a.id) AS sale_count
FROM `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc` as a
JOIN `polar-ray-420915.Portfolio_Data_Sets.rollingsales_nyc_SALE_PRICE_FINAL` as b
ON a.id = b.id
GROUP BY a.BOROUGH_CLEAN, a.BUILDING_CLASS_CATEGORY
ORDER BY a.BOROUGH_CLEAN, avg_price DESC
```

The following code used a CTE, cast, CASE statement, and an aggregation to determine in what decades were buildings built that had units sold during this time period, and how many buildings were built in each decade.

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

The analysis results are summarized as follows:
1. Although Manhattan and Brooklyn led with the highest crime counts between 1/1/2024-3/31/2024, the Bronx experienced the highest rate of crime when you factor in the population per borough. Additionally, although Staten Island's crime count was an outlier in that it was significantly lower than the others, it's rate of crime was still relatively comparable to the other boroughs. See below for a table that includes the population, crime count, crime count / population, and the standardization score to compare the crime rates:
2. The most likely perpetrator between 1/1/2024-3/31/2024 was a black male between the ages of 25-44.
3. The most common charge overall was "Assault 3". However, In Manhattan and Queens, Assault 3 fell slightly behind the "LARCENY,PETIT FROM OPEN AREAS" charge.

### Implications/Recommendations:

If this project were for the purpose of reducing crime in NYC, based off of the EDA, I would narrow in on the specific locations within each borough with high concentrations of crime. This would require me to pinpoint the specific areas of each borough where crime is the most prevalent. I would also want to evaluate the different "perp characteristics" (age, race, gender) across crime types. By predicting who is most likely to commit certain crimes, we could then conduct further research to determine why some crimes are committed in certain communities vs. others. Ultimately, the goal would be to provide the correct funding or support for programs, education, housing, etc. in order to reduce this crime.

### Limitations

There were a few limitations within this data set. One limitation was that it only spanned a 3 month duration. It would be beneficial to see trends over the years to get an accurate depiction of the crime rate over time. Additionally, the crime descriptions were a little vague. It's possible to look up the meaning of all of them and then add in a new column in the data set, but it would take time. Lastly, it's important to note that this data does not provide much context. It is important not to draw conclusions or form prejudices based on the common "perp profile" that was illustrated. Rather, this EDA should inspire you to learn more about why certain types of people are arrested, predisposed to criminality, and, most importantly, what can be done to help them.

### References

1. SQL for Businesses by werty
2. [Data.gov](https://data.gov/)

Thank you for reading!

| Year | Sales |
| ---------- | ---------- |
| 2010 | $1M |
| 2011 | $4M |

<!--
hello
-->
hello
