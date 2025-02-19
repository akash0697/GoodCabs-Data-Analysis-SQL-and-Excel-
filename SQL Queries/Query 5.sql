/*	5.	Weekend vs. Weekday Trip Demand by City --
		Compare the total trips taken on weekdays versus weekends for each city over the six-month period. 
        Identify cities with a strong preference for either weekend or weekday trips to understand demand variations.
*/
WITH trip_demand AS (
		SELECT 
			c.city_name AS City_name,
			dt.day_type AS Day_type,
			COUNT(f.trip_id) AS Total_trips
		FROM dim_city c
		JOIN fact_trips f ON c.city_id = f.city_id
		JOIN dim_date dt ON f.date = dt.date
		GROUP BY City_name, Day_type
        ),
	trip_comparison AS (
		SELECT
			City_name,
			SUM(CASE WHEN Day_type = 'Weekday' THEN Total_trips ELSE 0 END) AS Weekday_trips,
			SUM(CASE WHEN Day_type = 'Weekend' THEN Total_trips ELSE 0 END) AS Weekend_trips
		FROM trip_demand
		GROUP BY City_name
)

SELECT 
    City_name,
    Weekday_trips,
    Weekend_trips,
    Weekday_trips - Weekend_trips AS Trip_difference,
    CASE 
        WHEN Weekday_trips > Weekend_trips THEN 'Weekday'
        WHEN Weekday_trips < Weekend_trips THEN 'Weekend'
        ELSE 'Equal Demand'
    END AS Preference
FROM trip_comparison
ORDER BY Trip_difference DESC;