Create Database Pizza;
use pizza;


CREATE TABLE Orders (
    order_id INT,
    order_date DATE,
    order_time TIME
);



CREATE TABLE Order_Details (
    order_details_id INT,
    order_id INT,
    pizza_id VARCHAR(50),
    quantity INT,
    primary key (order_details_id)
);


CREATE TABLE Pizzas (
    pizza_id VARCHAR(50),
    pizza_type_id VARCHAR(50),
    size CHAR(1),
    price DECIMAL(10,2)
);


CREATE TABLE Pizza_Types (
    pizza_type_id VARCHAR(50),
    name VARCHAR(100),
    category VARCHAR(50),
    ingredients TEXT
);



select * from orders;
select * from order_details;
select * from pizzas;
select * from pizza_types;



# 1 : Calculate the total revenue generated from all pizza sales.
SELECT 
    SUM(order_details.quantity * pizzas.price) AS total_sale
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    

# 2 : Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_order
FROM
    orders;
    
# 3 : Retrieve the total number of pizzas sold.
SELECT 
    SUM(quantity) AS total_pizza
FROM
    order_details;
    
# 4 : Calculate the average order value for pizza sales.
SELECT 
    CEILING(SUM(pizzas.price * order_details.quantity) / COUNT(DISTINCT orders.order_id)) AS Avg_Order_Value
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id;
    
# 5 : Calculate the average number of pizzas per order.
SELECT 
    ROUND(SUM(order_details.quantity) / COUNT(DISTINCT orders.order_id),
            2) AS Avg_Pizza_Order
FROM
    order_details
        JOIN
    orders ON order_details.order_id = orders.order_id;

# 6 : Display all unique pizza categories.
select distinct(category) from pizza_types;

# 7 : Display all unique pizza_name.
select distinct(name) from pizza_types;

# 8 : Identify the highest-priced pizza.
SELECT 
    pt.name AS pizza_name, p.price AS unit_price
FROM
    pizzas AS p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;
    
# 9 : Analyze the daily trend of total orders.
SELECT 
    DAYNAME(order_date) AS Order_day,
    COUNT(DISTINCT order_id) AS total_orders
FROM
    orders
GROUP BY DAYNAME(Order_Date)
ORDER BY Total_Orders;

# 10 : Compare the revenue generated in Weekday vs Weekend.
SELECT 
    CASE
        WHEN DAYNAME(o.order_date) IN ('Saturday' , 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    SUM(od.quantity * p.price) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    orders o ON o.order_id = od.order_id
GROUP BY day_type
ORDER BY total_revenue DESC;

# 11 : Analyze the monthly trend of total orders.
SELECT 
    MONTHNAME(order_date) AS month_name,
    COUNT(DISTINCT order_id) AS total_orders
FROM
    orders
GROUP BY MONTHNAME(order_date) , MONTH(order_date)
ORDER BY MONTH(order_date);

# 12 : Show month-over-month revenue growth.
SELECT 
    month_name,
    ROUND(SUM(monthly_revenue) OVER (ORDER BY month_number),0) AS cumulative_revenue
FROM (
    SELECT 
        MONTHNAME(o.order_date) AS month_name,
        MONTH(o.order_date) AS month_number,
        SUM(od.quantity * p.price) AS monthly_revenue
    FROM order_details AS od
    JOIN pizzas AS p 
        ON od.pizza_id = p.pizza_id
    JOIN orders AS o 
        ON o.order_id = od.order_id
    GROUP BY MONTHNAME(o.order_date), MONTH(o.order_date)
) AS monthly_sales
ORDER BY month_number;

# 13 : Analyze the cumulative revenue generated over Per_day.
SELECT 
    order_date,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT 
        o.order_date,
        SUM(od.quantity * p.price) AS daily_revenue
    FROM order_details AS od
    JOIN pizzas AS p 
        ON od.pizza_id = p.pizza_id
    JOIN orders AS o 
        ON o.order_id = od.order_id
    GROUP BY o.order_date
) AS daily_sales
ORDER BY order_date;

# 14 : Analyze the hourly trend of total orders.
SELECT 
    HOUR(order_time) AS order_timing,
    COUNT(DISTINCT order_id) AS total_orders
FROM
    orders
GROUP BY HOUR(Order_time)
ORDER BY order_timing;

# 15 : Find the hour of the day during which the most pizza orders are placed (busiest hour)
SELECT 
    HOUR(order_time) AS order_timing,
    COUNT(DISTINCT order_id) AS total_orders
FROM
    orders
GROUP BY HOUR(Order_time)
ORDER BY total_orders DESC
LIMIT 1;

# 16 : Calculate the sales percentage by pizza category.
SELECT 
    pt.category,
    SUM(p.price * od.quantity) AS total_revenue,
    ROUND(SUM(p.price * od.quantity) * 100 / (SELECT 
                    SUM(p2.price * od2.quantity)
                FROM
                    order_details od2
                        JOIN
                    pizzas p2 ON od2.pizza_id = p2.pizza_id),
            2) AS Pct_Sale
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

# 17 : Retrieve the total number of pizzas sold by category.
SELECT 
    pt.category, (SUM(od.quantity)) AS total_sold
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category;


# 18 : List the top 5 best-selling pizzas by quantity sold.
SELECT 
    pt.name, SUM(od.quantity) AS total_sold
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_sold DESC
LIMIT 5;

# 19 : List the bottom 5 worst-selling pizzas by quantity sold.
SELECT 
    pt.name, SUM(od.quantity) AS total_sold
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_sold ASC
LIMIT 5;

# 20 :  List the top 5 best-selling pizzas by Revenue.
SELECT 
    pt.name, SUM(p.price * od.quantity) AS total_sold
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_sold DESC
LIMIT 5;

# 21 :  List the Bottom 5 worst-selling pizzas by Revenue.
SELECT 
    pt.name, SUM(p.price * od.quantity) AS total_sold
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_sold ASC
LIMIT 5;


# 22 : Find the top-selling pizza per category based on quantity or revenue.
SELECT 
    category,
    pizza_name,
    total_sold,
    total_revenue
FROM (
    SELECT 
        pt.category,
        pt.name AS pizza_name,
        SUM(od.quantity) AS total_sold,
        Round(SUM(od.quantity * p.price)) AS total_revenue,
        Row_number() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity) DESC) AS rn
    FROM pizzas AS p
    JOIN order_details AS od ON p.pizza_id = od.pizza_id
    JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) AS ranked
WHERE rn = 1
ORDER BY category;


# 23 : Rank pizzas by total sales using a window function.
SELECT 
    pt.name AS pizza_name,
    SUM(od.quantity) AS total_quantity,
    RANK() OVER (ORDER BY SUM(od.quantity) DESC) AS quantity_rank
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY quantity_rank ; 