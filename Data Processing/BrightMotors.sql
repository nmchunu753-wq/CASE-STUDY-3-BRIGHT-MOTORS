------------------------------------------------------------------------------------------------------------------------------------------------------
---Query 1: Checking if the data set works successfully
------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * 
FROM `workspace`.`cars`.`CARSALES`;

------------------------------------------------------------------------------------------------------------------------------------------------------
---Query 2: The total number of sales
--- 558 811 sales
------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT count(*) 
FROM `workspace`.`cars`.`CARSALES`;

------------------------------------------------------------------------------------------------------------------------------------------------------
--- Query 3: The total revenue. NOTE: total revenue = sales * selling price
---7 606 012 287 
------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT sum(sellingprice) AS totl_revenue
FROM `workspace`.`cars`.`CARSALES`;

------------------------------------------------------------------------------------------------------------------------------------------------------
---Query 4: Start and end year of car manufature
--- 1982 to 2015
------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT MIN(year) AS Start_Year_Of_Manufature,
       MAX(year) AS Last_Year_Of_Manufature
FROM `workspace`.`cars`.`CARSALES`;

------------------------------------------------------------------------------------------------------------------------------------------------------
---Query 5: Extracting year, month and date from sale date.
------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT saledate,
       SUBSTR(saledate, 12, 4) AS Sale_Year,
       SUBSTR(saledate, 5, 3) AS Sale_Month,
       SUBSTR(saledate, 9, 2) AS Sale_Day
FROM `workspace`.`cars`.`CARSALES`;
---------------------------------------------------------------------------------------------------------------
--- Query 6:  Finding the first and last year of selling
---2014 to 2015
------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
      MIN(SUBSTR(saledate, 12, 4)) Start_Sale_Year,
      MAX(SUBSTR(saledate, 12, 4)) Last_Sale_Year
FROM `workspace`.`cars`.`CARSALES`;

---------------------------------------------------------------------------------------------------------------------------------------------------------
---Query 7: Which car makes and models generate the most revenue : TOP 10
---------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT make,
       model,
      SUM(sellingprice) AS Total_Revenue
FROM `workspace`.`cars`.`CARSALES`
GROUP BY make, model
ORDER BY SUM(sellingprice) DESC
LIMIT 10;
---------------------------------------------------------------------------------------------------------------------------------------------------------
--- Query 8: The relationship between price, mileage, and year of manufacture 
---Note mileage is odometer.
--newer cars → higher price → lower mileage
---older cars → lower price → higher mileage
---------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    year AS Year_Of_Manufacture,
    ROUND(AVG(sellingprice), 2) AS avg_price,
    ROUND(AVG(odometer), 2) AS avg_mileage
FROM workspace.cars.CARSALES
WHERE year IS NOT NULL
GROUP BY year
ORDER BY year DESC
LIMIT 20;
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--margin tiers
--------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    make, 
    model,
    sellingprice,
    mmr,

    -- Profit margin %
    ROUND((sellingprice - mmr) / sellingprice * 100, 2) AS profit_margin_pct,

    -- Performance tiers
    CASE
        WHEN (sellingprice - mmr) / sellingprice * 100 >= 20 THEN 'High Margin'
        WHEN (sellingprice - mmr) / sellingprice * 100 >= 10 THEN 'Medium Margin'
        WHEN (sellingprice - mmr) / sellingprice * 100 >= 0 THEN 'Low Margin'
        ELSE 'Negative Margin'
    END AS margin_tier

FROM workspace.cars.CARSALES
WHERE sellingprice > 0 AND mmr > 0
LIMIT 20;

---------------------------------------------------------------------------------------------------------------------------------------------------------
---Query 9: Which regions or locations have the highest sales volumes?  NOTE this means the number of cars sold per location.
---TOP 10
---------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT state,
       COUNT(*) AS Number_Of_sales
FROM `workspace`.`cars`.`CARSALES`
GROUP BY state
ORDER BY COUNT(*) DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------
--- Query 10 using output from query 9: Which regions or locations have the highest sales volumes?
---------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    CASE state
        WHEN 'fl' THEN 'Florida'
        WHEN 'ca' THEN 'California'
        WHEN 'pa' THEN 'Pennsylvania'
        WHEN 'tx' THEN 'Texas'
        WHEN 'ga' THEN 'Georgia'
        WHEN 'nj' THEN 'New Jersey'
        WHEN 'il' THEN 'Illinois'
        WHEN 'nc' THEN 'North Carolina'
        WHEN 'oh' THEN 'Ohio'
        WHEN 'tn' THEN 'Tennessee'
        ELSE state
    END AS state_full,
    
    COUNT(*) AS Number_Of_sales

FROM `workspace`.`cars`.`CARSALES`
GROUP BY state
ORDER BY Number_Of_sales DESC
LIMIT 10;



---------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
---EMERGING TRENDS IN CUSTOMER PURCHASING PREFERENCES
---------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
--Query 11: Popular brands: TOP 10
----------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    make,
    COUNT(*) AS total_sales
FROM workspace.cars.CARSALES
GROUP BY make
ORDER BY total_sales DESC
LIMIT 10;

----------------------------------------------------------------------------------------------------------------------------------------------------------
--Query 12: Most preferred car body types: TOP 10
----------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    body,
    COUNT(*) AS total_sales
FROM `workspace`.`cars`.`CARSALES`
WHERE body != 'Unknown_body'
GROUP BY body
ORDER BY total_sales DESC
LIMIT 10;

----------------------------------------------------------------------------------------------------------------------------------------------------------
----Query 13: Transmission preference (Auto vs Manual)
----------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
    IFNULL(transmission, 'UNKNOWN') AS transmission,
    COUNT(*) AS total_sales
FROM workspace.cars.CARSALES
GROUP BY IFNULL(transmission, 'UNKNOWN')
ORDER BY total_sales DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------------
------Query 14: Color preferences TOP 10
----------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    color,
    COUNT(*) AS total_sales
FROM workspace.cars.CARSALES
WHERE color IS NOT NULL
GROUP BY color
ORDER BY total_sales DESC
LIMIT 10;

---------------------------------------------------------------------------------------------------------------------------------------------------------
-------Query 15: Most preferred car interier types
---------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
     interior,
    COUNT(*) AS total_sales
FROM `workspace`.`cars`.`CARSALES`
WHERE interior IS NOT NULL
GROUP BY interior
ORDER BY total_sales DESC
LIMIT 10;

---------------------------------------------------------------------------------------------------------------------------------------------------------
-------Query 16: Price range preference
---------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
CASE
    WHEN sellingprice BETWEEN 1 AND 76666 THEN 'Budget'
    WHEN sellingprice BETWEEN 76667 AND 153333 THEN 'Mid_range'
    WHEN sellingprice BETWEEN 153334 AND 230000 THEN 'Expensive'
    ELSE 'Premium'
END AS price_category,
    COUNT(*) AS total_sales
FROM `workspace`.`cars`.`CARSALES`
GROUP BY price_category
ORDER BY total_sales DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------
-------Query 16: Total sales over months
---------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN SUBSTR(saledate, 5, 3) IS NULL THEN 'Unknown'
        ELSE SUBSTR(saledate, 5, 3)
    END AS Sale_Month,
    COUNT(*) AS total_sales
FROM `workspace`.`cars`.`CARSALES`
GROUP BY 
    CASE 
        WHEN SUBSTR(saledate, 5, 3) IS NULL THEN 'Unknown'
        ELSE SUBSTR(saledate, 5, 3)
    END
ORDER BY total_sales DESC;



---------------------------------------------------------------------------------------------------------------------------------------------------------
-------Query 17: FINAL BIG QUERY
---------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    -- Time dimensions from saledate
    CAST(SUBSTR(saledate, 12, 4) AS INT) AS Sale_Year,
    SUBSTR(saledate, 5, 3) AS Sale_Month,

    -- Vehicle attributes (with COALESCE to handle NULLS)
    year AS Year_Of_Manufacture,
    COALESCE(make, 'Unknown') AS make,
    COALESCE(model, 'Unknown') AS model,
    COALESCE(trim, 'Unknown') AS trim,
    COALESCE(body, 'Unknown') AS body,
    COALESCE(transmission, 'Unknown') AS transmission,
    COALESCE(state, 'Unknown') AS region,
    COALESCE(color, 'Unknown') AS color,
    COALESCE(interior, 'Unknown') AS interior,
    
    COUNT(*) AS total_sales,

    -- Price category
    CASE 
        WHEN sellingprice BETWEEN 1 AND 76666 THEN 'Budget'
        WHEN sellingprice BETWEEN 76667 AND 153333 THEN 'Mid_range'
        WHEN sellingprice BETWEEN 153334 AND 230000 THEN 'Expensive'
        ELSE 'Premium'
    END AS price_category,

    SUM(sellingprice) AS total_revenue,
    SUM(sellingprice - mmr) AS total_profit_dollars,
    
    -- Profit margin percentage
    (SUM(sellingprice - mmr) / NULLIF(SUM(sellingprice), 0)) * 100 AS profit_margin_pct,

    -- Performance tier
    CASE 
        WHEN (SUM(sellingprice - mmr) / NULLIF(SUM(sellingprice), 0)) * 100 >= 20 THEN 'High Margin'
        WHEN (SUM(sellingprice - mmr) / NULLIF(SUM(sellingprice), 0)) * 100 >= 10 THEN 'Medium Margin'
        WHEN (SUM(sellingprice - mmr) / NULLIF(SUM(sellingprice), 0)) * 100 >= 0 THEN 'Low Margin'
        ELSE 'Negative Margin'
    END AS margin_tier

FROM `workspace`.`cars`.`CARSALES`

WHERE sellingprice > 0
  AND sellingprice IS NOT NULL
  AND mmr > 0
  AND mmr IS NOT NULL
  AND year IS NOT NULL

GROUP BY 
    -- Time dimensions
    CAST(SUBSTR(saledate, 12, 4) AS INT),
    SUBSTR(saledate, 5, 3),
       
    -- Vehicle attributes
    year,
    COALESCE(make, 'Unknown'),
    COALESCE(model, 'Unknown'),
    COALESCE(trim, 'Unknown'),
    COALESCE(body, 'Unknown'),
    COALESCE(transmission, 'Unknown'),
    COALESCE(state, 'Unknown'),
    COALESCE(color, 'Unknown'),
    COALESCE(interior, 'Unknown'),

    -- REQUIRED because it's in SELECT
    CASE 
        WHEN sellingprice BETWEEN 1 AND 76666 THEN 'Budget'
        WHEN sellingprice BETWEEN 76667 AND 153333 THEN 'Mid_range'
        WHEN sellingprice BETWEEN 153334 AND 230000 THEN 'Expensive'
        ELSE 'Premium'
    END

ORDER BY 
    Sale_Year DESC,
    Sale_Month;
