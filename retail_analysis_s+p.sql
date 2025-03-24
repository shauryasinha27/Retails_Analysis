create database RETAIL;
use RETAIL;
CREATE TABLE retails_data (  order_id int,
							 order_date date,
                             ship_mode char(20),
                             segment char(20),
                             country char(30),
                             city char(20),
                             state char(20),
                             postal_code int,
                             region char(20),
                             category char(20),
                             sub_category char(20),
                             product_id varchar(30),
                             list_price int,
                             quantity int,
                             sale_price double,
                             profit double);
select * from retails_data;
-- top 10 highest revenue generating products
select product_id, ROUND(sum(sale_price),2) as sales
from retails_data
group by 1
order by 2 desc
limit 10;

-- top 5 highest selling products in each region
with top5 as(
select product_id, region, round(sum(sale_price),2) as sales,
ROW_NUMBER() OVER (Partition by region order by sum(sale_price) desc) as rn
from retails_data
group by 1,2)
select *
from top5
having rn <=5;

-- find month over month comparison for 2022 and 2023 sales

WITH monthly_sales AS (
    SELECT 
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(sale_price) AS total_sales
    FROM retails_data
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    month,
    round(SUM(CASE WHEN year = 2022 THEN total_sales ELSE 0 END),2) AS sales_22,
    round(SUM(CASE WHEN year = 2023 THEN total_sales ELSE 0 END),2) AS sales_23
FROM monthly_sales
GROUP BY month
ORDER BY month;

-- for each category, which month had highest sales?
with quac as(
select category, month(order_date),year(order_date), sum(sale_price),
RANK() OVER (PARTITION BY category order by sum(sale_price) desc) as rr
from retails_data
group by 1,2,3
)
select *
from quac
where rr=1;

-- which subcategory had highest growth by profit in 2023 compared to 2022
WITH cte AS (
    SELECT 
		sub_category,
        YEAR(order_date) AS year,
        SUM(profit) AS total_profit
    FROM retails_data
    GROUP BY sub_category, YEAR(order_date)
)
, cte2 as(
SELECT 
    sub_category,
    round(SUM(CASE WHEN year = 2022 THEN total_profit ELSE 0 END),2) AS profit_22,
    round(SUM(CASE WHEN year = 2023 THEN total_profit ELSE 0 END),2) AS profit_23
FROM cte
GROUP BY sub_category
)
select *, Round((profit_23-profit_22)*100.0/profit_22,3) as Growth
from cte2
order by Growth desc
limit 1;