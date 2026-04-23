create database customer_shopping_behavior;
USE customer_shopping_behavior_cleaned;
SELECT * FROM customer_shopping_behavior_cleaned;

### Q-1 What is the total revenue gernerated by male vs. female customers?

SELECT 
	gender,
    SUM(purchased_amount)
FROM customer_shopping_behavior_cleaned
GROUP BY gender;

### Q-2 Which customer use a discount band still spent more then the avg purchsed amount?

SELECT 
	customer_id,
    purchased_amount
FROM customer_shopping_behavior_cleaned
WHERE discount_applied = 'Yes' 
	AND purchased_amount >= (select AVG(purchased_amount) from customer_shopping_behavior_cleaned);
    
### Q-3 Which are the top 5 products with the highest avg review rating?

SELECT 
	item_purchased,
    ROUND(AVG(review_rating), 2) AS avg_product_rating
FROM customer_shopping_behavior_cleaned
GROUP BY item_purchased
ORDER BY avg_product_rating DESC
limit 5;

### Q-4 Comapare the avg Purchased amount between Standard and Express Shipping?

SELECT 
	shipping_type,
    ROUND(AVG(purchased_amount), 2)
FROM customer_shopping_behavior_cleaned
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

### Q-5 Do suscribed member spend more? Compare to average spend and total revenue between suscriber and non-suscribers.

SELECT 
	subscription_status,
    COUNT(customer_id) as total_customer,
    ROUND(AVG(purchased_amount), 2) AS avg_spend,
    ROUND(SUM(purchased_amount), 2) AS total_revenue
FROM customer_shopping_behavior_cleaned
GROUP BY subscription_status
ORDER BY total_revenue, avg_spend DESC;

### Q-6 Which 5 product has the highest percentage of purchases with discount applied?

SELECT 
	item_purchased,
    ROUND(SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS discount_rate
FROM customer_shopping_behavior_cleaned
GROUP BY item_purchased
ORDER BY discount_rate DESC
limit 5;

### Q-7 Segement customer into New, Returning and Loyal based on their total number of previous purchases, and show the count of each segment.

WITH customer_type 
AS 
(
	SELECT
		customer_id,
        previous_purchases,
	CASE
		WHEN previous_purchases = 1 THEN 'New'
        WHEN previous_purchases BETWEEN 2 and 10 THEN 'Returning'
        ELSE 'Loyal'
        END AS customer_segment
	FROM customer_shopping_behavior_cleaned
)
SELECT 
	customer_segment,
    COUNT(*) as number_of_customers
FROM customer_type
GROUP BY  customer_segment;

### Q-8 What are the top 3 purchased products within each category?

SELECT 
	category, 
    item_purchased, 
    total_purchases
FROM (
    SELECT 
        category,
        item_purchased,
        COUNT(*) AS total_purchases,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS rank_num
    FROM customer_shopping_behavior_cleaned
    GROUP BY category, item_purchased
) ranked
WHERE rank_num <= 3;

### Q-9 Are customers who are repeat buyers (more than 5 previous purchases) also likely to suscribe?

SELECT 
	subscription_status,
    count(customer_id) AS repeat_buyers
FROM customer_shopping_behavior_cleaned
WHERE previous_purchases > 5
GROUP BY subscription_status;

### Q-10 What is the revenue contribution  each age group?

SELECT 
	age_group,
    SUM(purchased_amount) as total_revenue
FROM customer_shopping_behavior_cleaned
GROUP BY age_group
ORDER BY total_revenue DESC;
