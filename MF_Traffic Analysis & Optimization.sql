# Skills used: Joins, CTEs, Temp Tables, Aggregate Functions, Date Functions, Case, Pivoting Data with Case

USE mavenfuzzyfactory;

# do a count of sessions and see which ad is driving the most sessions

SELECT 
	utm_content,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
ORDER BY 2 DESC; 


# bring in orders as well

SELECT 
	website_sessions.utm_content,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
ORDER BY 2 DESC; 


# analyse converion rate

SELECT 
	website_sessions.utm_content,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
ORDER BY 2 DESC; 

# assume we have a product luanched on 12 April 2012, finding its  top traffic sources
SELECT 
	utm_source, 
    utm_campaign,
    http_referer, 
    COUNT(DISTINCT website_session_id) AS number_of_sessions
FROM website_sessions
WHERE created_at <'2012-04-12'
GROUP BY 
	utm_source,
	utm_campaign,
	http_referer
ORDER BY number_of_sessions DESC;

# drill deeper into "gsearch nonbrand" campgaign traffic to explore potential optimization opportunities. 
SELECT 
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
FROM website_sessions
	LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-4-14'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand';

# trended analysis of "gsearch nonbrand" brfore 2012-05-10, to see the impact of volume changes
SELECT
    -- YEAR(created_at) AS yr,
    -- WEEK(created_at) AS wk,
    MIN(DATE(created_at)) AS week_started_at,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-05-12' 
	AND utm_source = 'gsearch' 
    AND utm_campaign = 'nonbrand'
GROUP BY 
	YEAR(created_at),
    WEEK(created_at);

# figure out conversion rates within subsegments of traffic - mobile & desktop
SELECT 
	website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt
FROM website_sessions
	LEFT JOIN orders
    ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-05-11'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 1;
## desktop has a conversion rate of 3.7% yet mobile has 0.9%, should increase bid in desktop traffic because it performs better

#pull weekly trands for both desktop and mobile to see the performance after increased biding gsearch nonbrand desktop campaigns up on 2012-04-15
SELECT 
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions
FROM website_sessions
WHERE created_at > '2012-04-19'
	AND created_at < '2012-06-09'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	YEAR(created_at),
    WEEK(created_at);
