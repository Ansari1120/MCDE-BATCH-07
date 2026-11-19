
--Q1. List customers from the state of NY who have no phone number on file. 
--Show their first name, last name, email and city with the aliases First Name, 
--Last Name, Email and City. Sort by last name, then first name, and return only 
--the first 10 rows

SELECT TOP 10 c.first_name as [First Name], c.last_name as [Last Name], c.email,
c.city from sales.customers as c 
order by c.last_name asc,c.first_name asc


--Q2. Find products with a model year of 2017 or 2018, a list price between 500 
--and 1500, whose name contains Trek but does not contain Kids. Show product_id, 
--product_name, model_year and list_price, sorted by list_price from highest to lowest.

SELECT p.product_id,p.product_name,p.model_year,p.list_price
from production.products as p
where p.model_year = 2017 or p.model_year = 2018 and
p.list_price between 500 and 1500
and p.product_name like "%Trek%"
and p.product_name not like "%kids%"
order by p.list_price desc

--Q3. (a) List the distinct values of order_status in sales.orders. 
--(b) List orders that have not been shipped yet, placed at store 1 or 3 during 2018. 
--Show order_id, customer_id, store_id, order_date and required_date, sorted by order_date.

--(a):
select DISTINCT o.order_status 
from sales.orders as o

--(b):
select o.order_id,o.customer_id,o.store_id
,o.order_date, o.required_date from sales.orders as o
where o.shipped_date is null
and o.store_id = 1 or o.store_id = 3 
and o.order_date like "%2018"
order by o.order_date

--Q4. For order_id = 1, show one row per order line with: order_id, order_date, 
--customer full name, product_name, brand_name, category_name, quantity, list_price, 
--discount and line_revenue, where line_revenue = quantity * list_price * (1 - discount) 
--from sales.order_items.

select o.order_id,o.order_date,c.first_name + ' ' + c.last_name as customer_name,
p.product_name,b.brand_name,ct.category_name,oi.quantity,
oi.list_price,oi.discount
,oi.quantity * oi.list_price * (1 - oi.discount) as line_revenue
from sales.customers as c
inner join sales.orders as o 
on c.customer_id = o.customer_id
inner join sales.order_items as oi
on o.order_id = oi.order_id
inner join production.products as p
on oi.product_id = p.product_id
inner join production.brands as b
on p.brand_id = b.brand_id
inner join production.categories as ct
on p.category_id = ct.category_id
WHERE o.order_id = 1


--Q(5): Show every staff member with their store_name and their manager's full name.
--Staff who have no manager must still appear, with the manager shown as 'No Manager'.

select s.staff_id, s.first_name + ' ' + s.last_name as staff_name,st.store_name,
isnull(m.first_name + ' ' + m.last_name, 'No Manager') as manager_name
from sales.staffs as s
inner JOIN sales.stores as st
on st.store_id = s.store_id
left  JOIN sales.staffs as m  
on m.staff_id  = s.manager_id
ORDER BY s.staff_id;

--Q(6): List products that have never been ordered. Show product_id, product_name, 
--brand_name and model_year.

select p.product_id, p.product_name, b.brand_name, p.model_year
from production.products as p
inner join production.brands as b 
on b.brand_id = p.brand_id
left join sales.order_items as oi 
on oi.product_id = p.product_id
where oi.product_id is null
order by p.product_id;


--Q7. (a) Create a view sales.vw_order_line_details that returns the Q4 details for all orders, 
--also including store_name and order_status. (b) Query the view to return all order 
--lines from January 2018, sorted by order_date, then order_id.

create view sales.vw_order_line_details as
select o.order_id,o.order_date,o.order_status
,st.store_name,c.first_name + '' '' + c.last_name AS customer_name,
oi.item_id,p.product_name,b.brand_name,ct.category_name,oi.quantity, oi.list_price,
oi.discount, oi.quantity * oi.list_price * (1 - oi.discount) AS line_revenue
FROM sales.orders AS o
INNER JOIN sales.customers as c  
ON c.customer_id  = o.customer_id
INNER JOIN sales.stores  as st 
ON st.store_id  = o.store_id
INNER JOIN sales.order_items as oi 
ON oi.order_id = o.order_id
INNER JOIN production.products as p  
ON p.product_id = oi.product_id
INNER JOIN production.brands as b  
ON b.brand_id = p.brand_id
INNER JOIN production.categories as ct 
ON ct.category_id = p.category_id
);

select * from sales.vw_order_line_details
where order_date >= '2018-01-01' and order_date <  '2018-02-01'
order by order_date, order_id;


--Q8. (a) Create a view production.vw_product_catalog with product_id, product_name, 
--brand_name, category_name, model_year and list_price. (b) Using only this view, 
--return all Electric Bikes priced above 3000, sorted by price from highest to lowest.

create view production.vw_product_catalog AS
select p.product_id,p.product_name,b.brand_name,ct.category_name,p.model_year,p.list_price
FROM production.products AS p
inner join production.brands  as b  
on b.brand_id = p.brand_id
inner join production.categories as ct 
on ct.category_id = p.category_id


select *
from production.vw_product_catalog
where category_name = 'Electric Bikes'
  and list_price > 3000
order by list_price DESC;

--Q9. Using sales.vw_order_line_details, show the total number of distinct orders 
--and total revenue for each store in each year. Sort by store_name, then year.

select store_name,YEAR(order_date) AS order_year,
count(distinct order_id) as total_orders,SUM(line_revenue) AS total_revenue
from sales.vw_order_line_details
group by store_name, YEAR(order_date)
order by store_name, order_year;

--Q10. For each brand, show the number of products and the minimum, average and 
--maximum list price. Keep only brands with more than 10 products, sorted by 
--average price from highest to lowest.

select b.brand_name,count(*) as product_count, min(p.list_price) AS min_price,
avg(p.list_price) as avg_price, max(p.list_price) as max_price
FROM production.products AS p
inner join production.brands as b 
ON b.brand_id = p.brand_id
GROUP BY b.brand_name
HAVING COUNT(*) > 10
ORDER BY avg_price DESC;

--Q11. Find products whose list price is higher than the average list price 
--of their own category. Show product_name, category_name, list_price 
--and the category's average price.

select p.product_name, ct.category_name, p.list_price, ca.avg_price as category_avg_price
from production.products as p
inner join production.categories as ct on ct.category_id = p.category_id
inner join (select category_id, avg(list_price) as avg_price from production.products group by category_id) as ca on ca.category_id = p.category_id
where p.list_price > ca.avg_price
order by ct.category_name, p.list_price desc;

--Q12. Find customers who placed at least one order in 2016 but no orders in 2018. 
--Show customer_id, full name, email and state. Write the query twice: once with IN / NOT IN 
--and once with EXISTS / NOT EXISTS.

-- (1)
select c.customer_id,c.first_name + ' ' + c.last_name AS full_name,
c.email,c.state
from sales.customers AS c
where c.customer_id in (select o.customer_id from sales.orders AS o
where o.order_date >= '2016-01-01'
and o.order_date <  '2017-01-01')
and c.customer_id not in (select o.customer_id from sales.orders AS o
where o.order_date >= '2018-01-01'
and o.order_date <  '2019-01-01'
and o.customer_id IS NOT NULL)
order by c.customer_id;

-- (2)
select c.customer_id,c.first_name + ' ' + c.last_name AS full_name,c.email,c.state
from sales.customers AS c
where exists (select 1 from sales.orders AS o
where o.customer_id = c.customer_id
and o.order_date >= '2016-01-01'
and o.order_date <  '2017-01-01')
and not exists (select 1 from sales.orders AS o
where o.customer_id = c.customer_id
and o.order_date >= '2018-01-01'
and o.order_date <  '2019-01-01')
order by c.customer_id;

--Q13. Using two CTEs in one WITH clause, first calculate the total revenue for each store, 
--then the average of those store totals. Return only the stores whose revenue is above the 
--average, with store_name, total_revenue, average and the difference.

with store_totals as (select st.store_name, sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue
from sales.orders as o
inner join sales.order_items as oi on oi.order_id = o.order_id
inner join sales.stores as st on st.store_id = o.store_id
group by st.store_name),
avg_total as (select avg(total_revenue) as avg_revenue from store_totals)
select s.store_name, s.total_revenue, a.avg_revenue, s.total_revenue - a.avg_revenue as difference
from store_totals as s
cross join avg_total as a
where s.total_revenue > a.avg_revenue
order by s.total_revenue desc;

--Q14. Using a recursive CTE, build the staff hierarchy starting from the staff member 
--with no manager. Show staff_id, staff full name, manager_id, level (top = 1) 
--and a reporting path such as Fabiola Jackson > Mireya Copeland > Genna Serrano.

WITH staff_tree AS (
-- anchor: the person with no manager
select s.staff_id,s.first_name + ' ' + s.last_name AS staff_name,
s.manager_id,1 AS level,
CAST(s.first_name + ' ' + s.last_name AS VARCHAR(500)) AS reporting_path
FROM sales.staffs AS s
WHERE s.manager_id IS NULL UNION ALL
-- recursive part: people who report to someone already in the tree
select s.staff_id, s.first_name + ' ' + s.last_name, s.manager_id, t.level + 1,
CAST(t.reporting_path + ' > ' + s.first_name + ' ' + s.last_name AS VARCHAR(500))
from sales.staffs AS s
inner join staff_tree AS t ON s.manager_id = t.staff_id
)
select staff_id, staff_name, manager_id, level, reporting_path
from staff_tree
order by reporting_path;


--Q15. (a) Using a CTE with a window function, find the top 3 products by 2017 revenue 
--within each category. Show category_name, product_name, total quantity, total revenue 
--and rank. (b) Using a recursive CTE that generates months 1 to 12, show the total orders 
--and total revenue for every month of 2017, with month number and month name, showing 0 
--for months with no sales.
--(a)
with months as (select 1 as month_num union all select month_num + 1 from months where month_num < 12),
monthly_sales as (select month(o.order_date) as month_num, count(distinct o.order_id) as total_orders, sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue
from sales.orders as o inner join sales.order_items as oi on oi.order_id = o.order_id
where o.order_date >= '2017-01-01' and o.order_date < '2018-01-01'
group by month(o.order_date))
--(b)
select m.month_num, datename(month, datefromparts(2017, m.month_num, 1)) as month_name,
isnull(ms.total_orders, 0) as total_orders, isnull(ms.total_revenue, 0) as total_revenue
from months as m
left join monthly_sales as ms on ms.month_num = m.month_num
order by m.month_num;