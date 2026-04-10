
--1.List all orders with status shipped ordered by purchase date descending

SELECT 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp
FROM olist_orders_dataset
WHERE order_status = 'shipped'
ORDER BY order_purchase_timestamp DESC;


--2.Find all customers from the state of RJ

SELECT Customer_id,customer_state
FROM olist_customers_dataset
WHERE customer_state = 'RJ';

--3.Show the top 10 most expensive products with their order IDs

SELECT TOP 10
    order_id, payment_value 
FROM olist_order_payments_dataset
ORDER BY payment_value DESC

--4.Find all customers from cities containing the word rio
SELECT customer_id,customer_city
FROM olist_customers_dataset
WHERE customer_city LIKE '%rio%';

--5.Count the total number of orders per customer state, ordered by count descending

SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;
GROUP BY customer_id;

--6.Find the average, min and max price of items per order. Show only orders with more than 3 items

SELECT 
    order_id,
    AVG(price) AS avg_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    COUNT(*) AS item_count
FROM olist_order_items_dataset
GROUP BY order_id
HAVING COUNT(*) > 3;

--7.Show total revenue per payment type

SELECT 
    payment_type,
    SUM(payment_value) AS total_revenue
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_revenue;

--8.Join orders and customers. Show order ID, status, customer city and state for SP customers only

SELECT 
    o.order_id,
    o.order_status,
    c.customer_city,
    c.customer_state
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE c.customer_state = 'SP';

--9.Join order items and products. Show product category name and price for items over 300 reais

SELECT 
    p.product_category_name,
    oi.price
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
WHERE oi.price > 300;

--10.Which sellers have sold more than 100 items? Show seller ID and item count

SELECT 
    seller_id,
    COUNT(*) AS item_count
FROM olist_order_items_dataset
GROUP BY seller_id
HAVING COUNT(*) > 100
ORDER BY item_count;

--11.Show the top 5 product categories by total revenue for delivered orders only

SELECT TOP 5
    p.product_category_name,
    SUM(oi.price) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_revenue;

--Using a LEFT JOIN, find all orders that have no payment record

SELECT 
    o.order_id
FROM olist_orders_dataset o
LEFT JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
WHERE p.order_id IS NULL;














