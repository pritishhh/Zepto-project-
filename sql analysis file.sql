use Zepto_sql_project;
drop table if exists zepto;
DROP TABLE IF EXISTS zepto_data;

CREATE TABLE zepto_data (
    sku_ID INT AUTO_INCREMENT PRIMARY KEY,
    Category VARCHAR(100),
    name VARCHAR(255),
    mrp INT,
    discountPercent INT,
    availableQuantity INT,
    discountedSellingPrice INT,
    weightInGms INT,
    outOfStock BOOLEAN,
    quantity INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/zepto_v2.csv'
INTO TABLE zepto_data
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Category, name, mrp, discountPercent, availableQuantity, discountedSellingPrice, weightInGms, @outOfStock, quantity)
SET outOfStock = IF(@outOfStock = 'TRUE', 1, 0);
-- data exploration

-- count of rows
select count(*) from zepto_data;

-- sample data 
select * from zepto_data
limit 10;

-- null values
select * from zepto_data
where name is null
or
Category is null
or
mrp is null
or
discountPercent is null
or
availableQuantity is null
or
discountedSellingPrice is null
or
weightInGms is null
or
outOfStock is null
or
quantity is null ;

-- differenet product categories
SELECT DISTINCT Category
from zepto_data
order by Category;

-- products in stock vs out of stock
select outOfStock , count(sku_id)
from zepto_data
group by outOfStock;

-- check product name present multiple times
select name, count(sku_id) as "number of skus"
from zepto_data
group by name
having count(sku_id) > 1
order by count(sku_ID) desc;

-- data cleaning

-- products with price 0 
select * from zepto_data
where mrp = 0 or discountedSellingPrice = 0;

-- delete that row
delete from zepto_data
WHERE mrp = 0;

-- CONVERT PAISE TO RUPPES
update zepto_data
set mrp = mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;

select mrp , discountedSellingPrice from zepto_data;

-- buisness insights questions 

-- Q1. Find the top 10 best-value products based on the discount percentage.
select distinct name, mrp, discountPercent
from zepto_data
order by discountPercent desc
limit 10;

-- Q2. What are the Products with High MRP but Out of stock
select distinct name , mrp 
from zepto_data
where outOfStock = true and mrp > 300
order by mrp desc;

-- Q3. Calculate Estimated Revenue for each category
select  Category,
sum(discountedSellingPrice * availableQuantity) AS total_revenue
from zepto_data
group by Category
order by total_revenue;

-- Q4. Find all products where MRP is greater than 3500 and discount is less than 10%.
select distinct name, mrp, discountPercent
from zepto_data
where mrp > 500 and discountPercent < 10
order by mrp desc, discountPercent desc;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
select category, 	
round(avg(discountPercent),2) as avg_discount
from zepto_data
group by category
order by avg_discount desc
limit 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
select distinct name, weightInGms, discountedSellingPrice,
Round(discountedSellingprice/weightInGms,2) as price_per_gram
from zepto_data
where weightInGms >= 100
order by price_per_gram;

-- Q7. Group the products into categories like Low, Medium, Bulk.
select distinct name, weightIngms,
case when weightInGms <500 then 'low'
	when weightInGms <1000 then 'medium'
    else 'bulk'
    end as weight_category
from zepto_data;

-- Q8.What is the Total Inventory Weight Per Category
select category,
sum(weightInGms * availableQuantity) as total_weight
from zepto_data
group by Category
order by total_weight;