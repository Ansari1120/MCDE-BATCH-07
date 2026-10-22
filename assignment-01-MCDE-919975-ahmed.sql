--1.1. Write a query that selects product_name, list_price, and a calculated column price_in_thousands (list_price divided by 1000) from production.products.
SELECT p.product_name,p.list_price,(p.list_price / 1000) as price_in_thousands 
FROM production.products as p;

--1.2. Write a query that returns the distinct list of state values from sales.customers.
SELECT DISTINCT c.state 
FROM sales.customers as c order by c.state;

--1.3. Write a query that returns the 5 cheapest products, 
--showing product_name and list_price, sorted appropriately.

SELECT TOP 5 p.product_name,p.list_price as cheapest 
FROM production.products as p 
ORDER by p.list_price ASC;

--1.4. Write a query that returns products priced between 200 and 600, 
--where the category is either 1 or 6. Use BETWEEN and IN together.

SELECT p.product_name,p.list_price, p.category_id
FROM production.products as p 
where p.list_price BETWEEN 200 and 600 
and p.category_id in (1,5);


--1.5. The following query is meant to find affordable mountain or road bikes 
--(categories 1 and 6) under $1000, but it has a bug. Identify 
--it and rewrite it correctly:

--SELECT product_name, category_id, list_price
--FROM production.products
--WHERE category_id = 1 OR category_id = 6 AND list_price < 1000;

--ANSWER:
--becuase "and" is process before "or" if we don't add paranthesis. if we add it, 
--parentheses values process first 
SELECT product_name, category_id, list_price
FROM production.products
WHERE (category_id = 1 OR category_id = 6) AND list_price < 1000;



--1.6. Write a query that finds all customers whose email ends in .com 
--and whose last_name starts with the letter "M".

SELECT * FROM sales.customers as s 
where s.email 
LIKE "%.com" and s.last_name LIKE "M%"


--1.7. Write a query that returns the 11th 
--through 20th most expensive products 
--using OFFSET...FETCH.

SELECT p.product_name, p.list_price 
FROM production.products as p
ORDER BY p.list_price DESC
offset 10 rows fetch next 10 rows only

--1.8. Think About It: A junior engineer writes WHERE discount <> NULL to 
--find order items with a defined discount, and the query returns zero 
--rows even though the table clearly has non-null discount values. 
--Explain why, using three-valued logic, 
--and write the correct version

--Basically Null with comparison is not reliable because it in the backside
--treat it as not known. so order items with discount i.e o.discount < 0 unknown null
--those finding as known are removed, if its not true or found
-- instead letting the user know Truthness or falseness
--so we need to know three value logic which is "True" , "False", "Unknown"
--to check null values we should use "is null" simply instead of where with comparison
--operators.

SELECT oi.discount
FROM order_items as oi
WHERE discount is null;