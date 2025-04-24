use flipkart;

#Find the top 5 cities with the highest number of orders. 

select * from orders;

SELECT 
    city, SUM(quantity) AS 'number_of_orders'
FROM
    (SELECT 
        t1.user_id, t1.city, t2.order_id, t3.quantity
    FROM
        users t1
    JOIN orders t2 ON t1.user_id = t2.user_id
    JOIN order_details t3 ON t2.order_id = t3.order_id) t
GROUP BY city
ORDER BY number_of_orders DESC
LIMIT 5;

# Q2.)Show total profit for each category, sorted by highest profit.

SELECT 
    category, SUM(profit) AS 'Total_profit'
FROM
    (SELECT 
        t1.category_id, t1.category, t2.profit
    FROM
        category t1
    JOIN order_details t2 ON t1.category_id = t2.category_id) t
GROUP BY category
ORDER BY Total_profit desc;


# List all orders that resulted in a loss  along with user name, category, and city.
SELECT 
    t1.name, t4.category, t1.city, t3.profit AS 'loss'
FROM
    users t1
        JOIN
    orders t2 ON t1.user_id = t2.user_id
        JOIN
    order_details t3 ON t2.order_id = t3.order_id
        JOIN
    category t4 ON t3.category_id = t4.category_id
WHERE
    profit < 0
ORDER BY loss ASC;

#Find the most frequently ordered vertical under the Clothing category.

SELECT 
    vertical,
    COUNT(category_id) AS 'frequently_ordered_vertical'
FROM
    (SELECT 
        t4.vertical, t3.category_id
    FROM
        order_details t3
    JOIN category t4 ON t3.category_id = t4.category_id) t
GROUP BY vertical
ORDER BY frequently_ordered_vertical DESC;

#Calculate total revenue (sum of amount) for each month in 2019. 
describe orders;

Alter table orders add column month_ tinyint after order_date;
Alter table orders add column year_ integer after month_;

update orders set month_ = 
    MONTH(STR_TO_DATE(order_date, '%d-%m-%Y')) ;
    
update orders set year_ = 
    YEAR(STR_TO_DATE(order_date, '%d-%m-%Y')) ;
    
SELECT 
    month_, SUM(amount) AS '2019_eachmonth_revenue'
FROM
    (SELECT 
        t1.month_, t1.year_, t2.amount
    FROM
        orders t1
    JOIN order_details t2 ON t1.order_id = t2.order_id) t
WHERE
    year_ = 2019
GROUP BY month_;

## Users with No Orders
SELECT name, city, state
FROM users
WHERE user_id NOT IN (SELECT DISTINCT user_id FROM orders);




#For each city, find the category with the highest total profit.
SELECT city, category, total_profit
FROM (
    SELECT 
        u.city,
        c.category,
        SUM(od.profit) AS total_profit,
        RANK() OVER (PARTITION BY u.city ORDER BY SUM(od.profit) DESC) AS rnk
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN order_details od ON o.order_id = od.order_id
    JOIN category c ON od.category_id = c.category_id
    GROUP BY u.city, c.category
) t
WHERE rnk = 1;

#Find the date with the maximum number of orders placed and how many were placed that day.
SELECT 
    STR_TO_DATE(order_date, '%d-%m-%Y') AS order_day,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_day
ORDER BY total_orders DESC
LIMIT 1;



# Profitability Ratio by Category
SELECT 
    c.category,
    ROUND(SUM(od.profit) / SUM(od.amount), 2) AS profitability_ratio
FROM order_details od
JOIN category c ON od.category_id = c.category_id
GROUP BY c.category
ORDER BY profitability_ratio DESC;


