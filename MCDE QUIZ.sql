--Q1. (LIKE, IN, ORDER BY with multiple columns) Return the first_name, last_name 
--and city of customers who live in the state NY or CA, whose email ends in .com 
--and whose last_name starts with the letter M. Sort by city ascending, then last_name ascending.


SELECT first_name,last_name,city 
FROM sales.customers where (state = 'NY' or state = 'CA') 
and email like '%.com' 
and last_name like 'M%'
order by city asc , last_name asc

--Q2. (Aliases, calculated column, ORDER BY, pagination) Show product_name, list_price 
--and a calculated column called discounted_price (10% off) for products with a list_price above 500. 
--Skip the 10 most expensive products and return the next 10 (the 11th to 20th most expensive).

SELECT product_name,list_price,(list_price * 0.90) as discounted_price 
from production.products
where list_price > 500  
order by list_price desc
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY

--Q3. (NULL, BETWEEN, AND/OR precedence) Find all orders that are either 
--Pending 3 or Processing 4, have not shipped yet,
--and were placed between 2018-01-01 and 2018-06-30. 
--Return order_id, order_date, required_date and order_status. 
--Your AND/OR logic must be explicitly grouped.


Select order_id,order_date,required_date,order_status 
from sales.orders
where order_status = 4 or order_status = 3 and shipped_date is null
and order_date between '2018-01-01' and '2018-06-30' 


--Chapter 2: Joins
--Q4. (Multi-table INNER JOIN, 5 tables) 
--For all Completed orders placed in 2018,
--return the customer's full name, order_id, order_date, store_name, product
--_name and quantity. Sort by order_date, newest first.


SELECT c.first_name + ' ' +   c.last_name as customer_name ,o.order_id,o.order_date,s.store_name,p.product_name,oi.quantity
from sales.orders as o
inner join sales.order_items as oi 
on o.order_id = oi.order_id
inner join sales.customers as c 
on o.customer_id = c.customer_id
inner join sales.stores as s 
on s.store_id = o.store_id
inner join production.products as p
on	oi.product_id = p.product_id
where o.order_status = 4 --assuming 4 as completed
and o.order_date >= '2018-01-01' and o.order_date < '2019-01-01'
order by o.order_date desc

--Q5. (LEFT JOIN + NULL check, 4 tables) 
--List every product that has never been sold, 
--showing product_name, category_name and brand_name.



SELECT p.product_name,c.category_name,b.brand_name from production.products as p
left join production.categories as c 
on p.category_id = c.category_id
left join production.brands as b
on b.brand_id = p.brand_id
left join sales.order_items as oi
on oi.product_id = p.product_id
where oi.product_id is null


--Q6. (Self join + extra join) Show every staff member's
--full name, their manager's full name 
--(NULL for the top-level person) and the name 
--of the store they work in.



SELECT s.first_name  + ' ' + s.last_name as staff,
m.first_name + ' ' + m.first_name as manager,
st.store_name
from sales.staffs as s
left join sales.staffs as m
on s.staff_id = m.manager_id
left join sales.stores as st 
on s.store_id = st.store_id




--Q7. (CREATE VIEW + query the view)
--(a) Create a view sales.vw_order_details that joins orders, customers,
--order_items and products and exposes: order_id, order_date, order_status, 
--customer_id, first_name, last_name, product_name, quantity 
--and a calculated line_total (quantity × list_price × (1 − discount)).
--(b) Using only that view, return each customer's 
--total spend on Completed orders, and keep only customers 
--who spent more than 10,000. Sort by total spend, highest first.


--(a) answer
alter view sales.vw_order_detail as 
select o.order_id,c.customer_id,c.first_name  + ' ' + c.last_name as customer
,o.order_status,o.order_date,p.product_name,oi.quantity,oi.discount,p.list_price

from sales.customers as c
inner join sales.orders as o on c.customer_id = o.customer_id
inner join sales.order_items as oi on o.order_id = oi.order_id
inner join production.products as p on oi.product_id = p.product_id


--(b) answer

Select     (c.quantity * c.list_price * (1 - c.discount)) AS line_total
from sales.vw_order_detail  as c


--Q8. (GROUP BY on multiple columns, HAVING, COUNT DISTINCT, joins, top N)
--For each combination of category_name and brand_name, return the number of distinct orders and the total revenue. 
--Keep only combinations that appear in at least 20 distinct orders, and return the top 5 by revenue.

select TOP 5  c.category_name, b.brand_name
    , COUNT(DISTINCT o.order_id) AS revenue_orders,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
from sales.orders AS o
inner join sales.order_items AS oi  ON o.order_id = oi.order_id
inner join sales.products AS p  ON oi.product_id = p.product_id
inner join sales.categories AS c  ON p.category_id = c.category_id
inner join sales.brands AS b
 ON p.brand_id = b.brand_idGROUP BYc.category_name,
    b.brand_name
having COUNT(DISTINCT o.order_id) >= 20
ORDER BY total_revenue DESC;

--Q9. (Aggregation across joins, YEAR(), COUNT DISTINCT) For each store 
--and each order year, return store_name, order_year,
--the number of distinct orders and total revenue. Sort by store_name, then order_year.
select
s.store_name,
YEAR(o.order_date) AS order_year,
COUNT(DISTINCT o.order_id) AS total_orders,
SUM(oi.quantity * oi.list_price) AS total_revenue
FROM sales.stores AS s
LEFT JOIN sales.orders AS o
ON o.store_id = s.store_id
LEFT JOIN sales.order_items AS oi
ON o.order_id = oi.order_id
GROUP BY s.store_name,YEAR(o.order_date)
ORDER BY s.store_name ASC, order_year ASC;
--Q10. (Nested subqueries, 4 levels of IN, no joins) Return the first and last names of
--customers who have ordered at least one product from the brand 'Electra'. Use only nested IN subqueries.
select c.first_name,c.last_name
FROM sales.customers AS c
WHERE c.customer_id IN
(SELECT o.customer_id FROM sales.orders AS oWHERE o.order_id IN (SELECT oi.order_id FROM sales.order_items AS oi
WHERE oi.product_id IN(  SELECT p.product_id
    FROM production.products AS p
  WHERE p.brand_id IN (
 SELECT b.brand_id
      FROM production.brands AS b
  WHERE b.brand_name = 'Electra'
    )
  )
)
);
