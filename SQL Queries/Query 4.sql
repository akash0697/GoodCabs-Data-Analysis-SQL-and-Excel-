/*	4.	Peak and Low Demand Months by City --
		For each city, identify the month with the highest total trips (peak demand) and the month with the lowest total trips (low demand). 
        This analysis will help Goodcabs understand seasonal patterns and adjust resources accordingly.
*/
WITH trips_by_months AS (
		SELECT 
			c.city_name AS City_name, 
			MONTH(t.date) AS Months,
			COUNT(trip_id) AS Total_trips
		FROM dim_city c
		JOIN fact_trips t ON c.city_id = t.city_id
		GROUP BY City_name, Months
		), 
	demand_rank AS (
		SELECT 
			City_name,
            Months,
			Total_trips, 
			RANK() OVER(PARTITION BY City_name ORDER BY Total_trips DESC) AS Peak_demand,
			RANK() OVER(PARTITION BY City_name ORDER BY Total_trips ASC) AS Low_demand
		FROM trips_by_months
        )
        
SELECT 
	City_name, 
    Months,
	Total_trips, 
    CASE
        WHEN Peak_demand = 1 THEN 'Peak'
        WHEN Low_demand = 1 THEN 'Low'
    END AS Demand
FROM demand_rank
WHERE Peak_demand = 1 or Low_demand = 1
ORDER BY City_name, Total_trips DESC;