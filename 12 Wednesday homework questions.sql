--1.Show all orders along with the customer city and state. Only show orders that have a status of delivered.

SELECT 
    o.order_id,
    o.order_status,
    c.customer_city,
    c.customer_state
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';

--2.Find all order items with their product category name. Only show items priced above 300 reais, ordered by price descending.

SELECT 
    oi.order_id,
    oi.product_id,
    p.product_category_name,
    oi.price
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
WHERE oi.price > 300
ORDER BY oi.price DESC;

--3.Which orders have no review at all? Show the order ID and order status.

SELECT 
    o.order_id,
    o.order_status
FROM olist_orders_dataset o
LEFT JOIN olist_order_reviews_dataset r
    ON o.order_id = r.order_id
WHERE r.order_id IS NULL;

--4.Find all customers who placed an order in 2017. Use a subquery. Show their city and state.

SELECT DISTINCT
    c.customer_city,
    c.customer_state
FROM olist_customers_dataset c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM olist_orders_dataset o
    WHERE YEAR(o.order_purchase_timestamp) = 2017);

--5.Who sold the single most expensive item on the platform? Use a subquery to find them.

SELECT 
    seller_id,
    price
FROM olist_order_items_dataset
WHERE price = (
    SELECT MAX(price)
    FROM olist_order_items_dataset);

--6.Label every order as High Value, Medium Value, or Low Value based on payment amount. High is over 500 reais, Medium is 100 to 500, Low is under 100.

SELECT 
    order_id,
    payment_value,
    CASE 
        WHEN payment_value > 500 THEN 'High Value'
        WHEN payment_value BETWEEN 100 AND 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS order_value_category
FROM olist_order_payments_dataset;

--7.For each state show how many orders were delivered, canceled, and shipped as separate columns.

SELECT 
    c.customer_state,
    COUNT(CASE WHEN o.order_status = 'delivered' THEN 1 END) AS delivered,
    COUNT(CASE WHEN o.order_status = 'canceled' THEN 1 END) AS canceled,
    COUNT(CASE WHEN o.order_status = 'shipped' THEN 1 END) AS shipped
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state;

--8.Rank all sellers by total revenue using RANK. Show seller ID, total revenue, and their rank. Top 20 only.

SELECT TOP 20
    seller_id,
    SUM(price) AS total_revenue,
    RANK() OVER (ORDER BY SUM(price) DESC) AS seller_rank
FROM olist_order_items_dataset
GROUP BY seller_id
ORDER BY total_revenue DESC;


--9.Show monthly revenue for 2017 and 2018. Add a column showing the change from the previous month using LAG.

SELECT 
    year_month,
    total_revenue,
    total_revenue - LAG(total_revenue) OVER (ORDER BY year_month) AS revenue_change
FROM (
    SELECT 
        LEFT(o.order_purchase_timestamp, 7) AS year_month,
        SUM(p.payment_value) AS total_revenue
    FROM olist_orders_dataset o
    JOIN olist_order_payments_dataset p
        ON o.order_id = p.order_id
    WHERE o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2019-01-01'
    GROUP BY LEFT(o.order_purchase_timestamp, 7)) t
ORDER BY year_month;

--10.Within each product category rank sellers by total items sold using ROW_NUMBER with PARTITION BY. Show only the number one ranked seller in each category.

SELECT 
    product_category_name,
    seller_id,
    total_items_sold
FROM (
    SELECT 
        p.product_category_name,
        oi.seller_id,
        COUNT(*) AS total_items_sold,
        ROW_NUMBER() OVER (
            PARTITION BY p.product_category_name
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    GROUP BY 
        p.product_category_name,
        oi.seller_id) t
WHERE rn = 1
ORDER BY product_category_name;


--11.Write a CTE that calculates total revenue and total orders per state. In the main query calculate revenue per order for each state and only show states where revenue per order is above 150 reais. Order by revenue per order descending.

WITH state_summary AS (
    SELECT 
        c.customer_state,
        SUM(p.payment_value) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id
    JOIN olist_order_payments_dataset p
        ON o.order_id = p.order_id
    GROUP BY c.customer_state)
SELECT 
    customer_state,
    total_revenue,
    total_orders,
    total_revenue * 1.0 / total_orders AS revenue_per_order
FROM state_summary
WHERE total_revenue * 1.0 / total_orders > 150
ORDER BY revenue_per_order DESC;

--12.Write two CTEs — one that calculates average delivery time in days per state, and one that calculates average review score per state. Join them together and show which states have delivery under 10 days AND an average review score above 4. These are your best performing states.

WITH delivery_cte AS (
    SELECT
        c.customer_state,
        AVG(DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date) * 1.0) AS avg_delivery_days
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
    GROUP BY c.customer_state),
review_cte AS (
    SELECT
        c.customer_state,
        AVG(r.review_score * 1.0) AS avg_review_score
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id
    JOIN olist_order_reviews_dataset r
        ON o.order_id = r.order_id
    GROUP BY c.customer_state)
SELECT
    d.customer_state,
    d.avg_delivery_days,
    r.avg_review_score
FROM delivery_cte d
JOIN review_cte r
    ON d.customer_state = r.customer_state
WHERE d.avg_delivery_days < 10
  AND r.avg_review_score > 4
ORDER BY d.avg_delivery_days, r.avg_review_score DESC;


















    
    
    
    
    
    