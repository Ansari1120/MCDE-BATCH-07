--2.1. Write a query that lists every product with its brand name, using production.products and production.brands.
SELECT p.product_name, b.brand_name FROM production.products as p
inner join production.brands as b on p.brand_id = b.brand_id

--2.2. Using a LEFT JOIN, write a query that finds every store with zero staff currently assigned to it.
SELECT * FROM sales.stores as s 
left join sales.staffs as st on
st.staff_id = s.store_id where st.staff_id is null


--2.3. Explain, in your own words, why the following query returns 
--every product regardless of stock level, and rewrite it so that
--it only returns products with fewer than 5 units in stock at store 1:

--SELECT p.product_name, s.quantity
--FROM production.products AS p
--LEFT JOIN production.stocks AS s
    --ON p.product_id = s.product_id AND s.quantity < 5 AND s.store_id = 1;


--left join gets all data from products table even if you not expect to stock records over the condition.
--quantity and store id only check which stock filters are matching. if product doesnt meet its condition
--its quantity found out as null , but data is still returns.

SELECT p.product_name, s.quantity
FROM production.products AS p
INNER JOIN production.stocks AS s 
ON p.product_id = s.product_id
WHERE s.quantity < 5 AND s.store_id = 1;

--2.4. Write a self join on sales.staffs that lists every manager along with a count placeholder column showing 1 for
--each employee they manage 
--(you will replace this with a real COUNT in Chapter 3); for now, just produce one row per employee-manager pair.

SELECT e.first_name + ' ' + e.last_name AS employee, 
m.first_name + ' ' + m.last_name  AS manager, 
1 AS employee_count
FROM sales.staffs AS e
LEFT JOIN sales.staffs AS m 
ON e.manager_id = m.staff_id;


--2.5. Write a three-table join across sales.orders, sales.order_items, 
--and production.products that lists every item in order #1, including product name 
--and quantity.

SELECT p.product_name , oi.quantity
FROM sales.order_items as oi
inner join production.products as p
on oi.product_id = p.product_id
inner join sales.orders as o
on o.order_id = oi.order_id
WHERE oi.order_id = 1

--2.6. A colleague joins orders to order_items and reports 
--"we received 4,658 orders last year." Explain what actually 
--went wrong with that number and how you would find the true order count instead.

--It counted 4,658 joined rows instead of unique orders. 
--because one order can have multiple items, joining orders with order_items 
--duplicates the order information across rows.

from sales.orders AS o
inner join sales.order_items AS oi
on o.order_id = oi.order_id

--2.7. Think About It: CROSS JOIN is often considered dangerous because 
--it can accidentally produce millions of rows from two innocent-looking tables. 
--Under what real circumstances would you deliberately want a CROSS JOIN, 
--and how would you guard against using one by accident, for example, 
--by forgetting an ON clause that was meant to be there?

--A crossjoin is useful when we deliberately need every possible combination of 
--two datasets, such as matching every product with every store or generating 
--test cases. However, it can produce extremely large results because 
--it multiplies the number of rows in both tables. To avoid accidental cross join, 
--we should use explicit join syntax, always include the correct ON conditions for 
--relationship-based joins, and check row counts before running large queries.