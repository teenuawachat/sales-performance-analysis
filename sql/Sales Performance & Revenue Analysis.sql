
# SALES PERFORMANCE AND REVENUE ANALYSIS 
-- CREATE DATABASE
CREATE DATABASE spra;
USE spra;

-- DATABASE SCHEMA
-- CREATE CUSTOMERS TABLE
CREATE TABLE customers(
customer_id INT PRIMARY KEY,
customer_name VARCHAR(100),
region VARCHAR(50),
signup_date DATE
);
-- CREATE PRODUCTS TABLE
CREATE TABLE products(
product_id INT PRIMARY KEY,
product_name VARCHAR(100),
category VARCHAR(50),
price DECIMAL(10,2)
);
-- CREATE ORDERS TABLE
CREATE TABLE orders(
order_id INT PRIMARY KEY,
customer_id INT,
order_date DATE,
status VARCHAR(50),
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
-- CREATE ORDER ITEMS TABLE
CREATE TABLE order_items(
order_item_id INT PRIMARY KEY,
order_id INT,
product_id INT,
quantity INT,
discount DECIMAL(4,2),
FOREIGN KEY (order_id) REFERENCES orders(order_id),
FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- CREATE PATMENTS TABLE
CREATE TABLE payments(
payment_id INT PRIMARY KEY,
order_id INT,
payment_date DATE,
amount DECIMAL(10,2),
FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
-- INSERTING DATA INTO TABLES
-- CUSTOMERS TABLE
INSERT INTO customers VALUES
(1,'Amit Shah','West','2023-01-10'),
(2,'Neha Verma','North','2023-02-15'),
(3,'Rahul Mehta','South','2023-03-20'),
(4,'Sneha Iyer','East','2023-04-05'),
(5,'Vikas Rao','West','2023-05-12');
-- PRODUCTS TABLE
INSERT INTO products VALUES
(101,'Laptop','Electronics',60000),
(102,'Mobile Phone','Electronics',30000),
(103,'Headphones','Accessories',2000),
(104,'Office Chair','Furniture',8000),
(105,'Desk Lamp','Furniture',1500);
-- ORDERS TABLE
INSERT INTO orders VALUES
(1001,1,'2023-06-01','Completed'),
(1002,2,'2023-06-10','Completed'),
(1003,3,'2023-07-05','Completed'),
(1004,4,'2023-07-18','Cancelled'),
(1005,5,'2023-08-02','Completed');
-- ORDER_ITEMS TABLE
INSERT INTO order_items VALUES
(1,1001,101,1,0.10),
(2,1001,103,2,0.00),
(3,1002,102,1,0.05),
(4,1003,104,1,0.10),
(5,1005,105,3,0.00);
-- PAYMENTS TABLE
INSERT INTO payments VALUES
(501,1001,'2023-06-01',58000),
(502,1002,'2023-06-10',28500),
(503,1003,'2023-07-05',7200),
(504,1005,'2023-08-02',4500);

-- KPI's
-- WHAT IS THE TOTAL REVENUE GENERATED ?
SELECT SUM(amount) AS Total_revenue
FROM payments;

-- WHICH REGION GENERATES THE HIGHEST REVENUE?
SELECT c.region,
SUM(p.amount) AS revenue
FROM payments p
JOIN orders o ON o.order_id=p.order_id
JOIN customers c ON o.customer_id=c.customer_id
GROUP BY c.region
ORDER BY revenue DESC;

-- WHAT IS THE REVENUE BY PRODUCT CATEGORY?
SELECT p.category ,SUM(oi.quantity * p.price *(1-oi.discount)) AS revenue
FROM  orders o 
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p  ON  oi.product_id = p.product_id
WHERE o.status = "Completed" 
GROUP BY p.category
ORDER BY revenue DESC;

-- WHICH ARE TOP 3 CUSTOMERS BY TOTAL REVENUE?
SELECT c.customer_id,c.customer_name,SUM(pa.amount) AS Total_Revenue
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments pa ON o.order_id = pa.order_id
WHERE o.status = "Completed"
GROUP BY c.customer_id,c.customer_name
ORDER BY Total_Revenue DESC LIMIT 3;

-- HOW IS REVENUE TRENDING MONTH OVER MONTH?
WITH Monthly_data AS(
SELECT YEAR(o.order_date) AS Year,
MONTH(o.order_date) AS Month,
SUM(oi.quantity * p.price *(1-oi.discount)) AS Revenue
FROM orders o 
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = "Completed"
GROUP BY Year,Month
)
SELECT Year,Month,
Revenue AS `Current Month Revenue` ,
LAG(Revenue) OVER (ORDER BY Year,Month) AS `Previous Month Revenue`,
ROUND(
(Revenue - LAG(Revenue) OVER (ORDER BY Year,Month)) /
NULLIF(LAG(Revenue) OVER (ORDER BY Year,Month),0) * 100,
2) AS `MoM Growth %`
FROM Monthly_data
ORDER BY Year,Month;

-- ARE DISCOUNTS INCREASING REVENUE OR HURTING PROFITABILITY ?
SELECT p.category,
AVG(oi.discount) AS `Average Discount`,
SUM(oi.quantity * p.price * (1-oi.discount)) AS `Total Revenue`
FROM  orders o 
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = "Completed"
GROUP BY p.category
ORDER BY `Average Discount`,`Total Revenue` DESC;








