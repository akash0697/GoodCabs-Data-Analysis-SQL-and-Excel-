/*	Business Request - 5: Identify Month with Highest Revenue for Each City
	-	Generate a report that identifies the month with the highest revenue for each city. 
		For each city, display the month_name, the revenue amount for that month, and the percentage contribution of 
        that month's revenue to the city's total revenue.
	Fields
		city_name 
		highest_revenue_month
		revenue 
		percentage_contribution (%)
*/
WITH city_monthly_revenue AS (
		SELECT 
			c.city_name AS City_name,
            MONTH(t.date) AS Months,
			ROUND(SUM(t.fare_amount), 2) AS Revenue
		FROM dim_city c
		JOIN fact_trips t ON c.city_id = t.city_id
		GROUP BY City_name, Months
		),
	city_highest_month_revenue AS (
		SELECT
			City_name,
            Months,
            Revenue,
            ROW_NUMBER() OVER (PARTITION BY City_name ORDER BY Revenue DESC) AS Revenue_rank
        FROM city_monthly_revenue
        ),
	city_total_revenue AS (
		SELECT
			City_name,
            ROUND(SUM(Revenue),2) AS Total_revenue
		FROM city_monthly_revenue
        GROUP BY City_name
        ),
	contibution AS (
		SELECT
			hr.City_name,
            hr.Months AS Highest_revenue_month,
            hr.Revenue,
            ROUND((hr.Revenue / tr.Total_revenue) * 100, 2) AS Percentage_contribution
        FROM city_highest_month_revenue hr
        JOIN city_total_revenue tr ON hr.City_name = tr.City_name
        WHERE hr.Revenue_rank = 1
        )
        
SELECT 
	City_name,
    Highest_revenue_month,
    Revenue,
    Percentage_contribution
FROM contibution
ORDER BY Percentage_contribution DESC
