/*	6.	Repeat Passenger Frequency and City Contribution Analysis --
		Analyse the frequency of trips taken by repeat passengers in each city (e.g., % of repeat passengers taking 2 trips, 3 trips, etc.). 
		Identify which cities contribute most to higher trip frequencies among repeat passengers, 
		and examine if there are distinguishable patterns between tourism-focused and business-focused cities.
*/
WITH repeat_passengers AS (
		SELECT 
			c.city_name AS City_name,
			r.trip_count AS Trip_count,
			SUM(r.repeat_passenger_count) AS Repeat_passenger_count
		FROM dim_city c
		JOIN dim_repeat_trip_distribution r ON c.city_id = r.city_id
		GROUP BY City_name, Trip_count
		),
	total_passengers AS (
		SELECT 
			City_name,
			Trip_count,
			Repeat_passenger_count,
			SUM(Repeat_passenger_count) OVER (PARTITION BY City_name) AS Total_city_passengers
		FROM repeat_passengers
		)
SELECT 
    City_name,
    ROUND(SUM(CASE WHEN Trip_count = 2 THEN Repeat_passenger_count * 100.0 / Total_city_passengers END), 2) AS '2-Trips',
    ROUND(SUM(CASE WHEN Trip_count = 3 THEN Repeat_passenger_count * 100.0 / Total_city_passengers END), 2) AS '3-Trips',
    ROUND(SUM(CASE WHEN Trip_count = 4 THEN Repeat_passenger_count * 100.0 / Total_city_passengers END), 2) AS '4-Trips',
    ROUND(SUM(CASE WHEN Trip_count = 5 THEN Repeat_passenger_count * 100.0 / Total_city_passengers END), 2) AS '5-Trips',
    ROUND(SUM(CASE WHEN Trip_count = 6 THEN Repeat_passenger_count * 100.0 / Total_city_passengers END), 2) AS '6-Trips',
    ROUND(SUM(CASE WHEN Trip_count = 7 THEN Repeat_passenger_count * 100.0 / Total_city_passengers END), 2) AS '7-Trips',
    ROUND(SUM(CASE WHEN Trip_count = 8 THEN Repeat_passenger_count * 100.0 / Total_city_passengers END), 2) AS '8-Trips',
    ROUND(SUM(CASE WHEN Trip_count = 9 THEN Repeat_passenger_count * 100.0 / Total_city_passengers END), 2) AS '9-Trips',
    ROUND(SUM(CASE WHEN Trip_count = 10 THEN Repeat_passenger_count * 100.0 / Total_city_passengers END), 2) AS '10-Trips'
FROM total_passengers
GROUP BY City_name
ORDER BY City_name;