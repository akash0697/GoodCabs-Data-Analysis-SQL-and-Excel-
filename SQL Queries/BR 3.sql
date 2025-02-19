/*	Business Request - 3: City-Level Repeat Passenger Trip Frequency Report
	- 	Generate a report that shows the percentage distribution of repeat passengers by the number of trips they have taken in each city. 
		Calculate the percentage of repeat passengers who took 2 trips, 3 trips, and so on, up to 10 trips.
	-	Each column should represent a trip count category, displaying the percentage of repeat passengers who fall into that category out of 
		the total repeat passengers for that city.
	This report will help identify cities with high repeat trip frequency, which can indicate strong customer loyalty or frequent usage patterns.
	Fields: 
		city_name 
		2-Trips 
		3-Trips 
		4-Trips 
		5-Trips 
		6-Trips 
		7-Trips 
		8-Trips 
		9-Trips 
		10-Trips
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