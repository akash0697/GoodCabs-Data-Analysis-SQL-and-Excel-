/*	Business Request - 1: City-Level Fare and Trip Summary Report
	Generate a report that displays the total trips, average fare per km, average fare per trip, 
    and the percentage contribution of each city's trips to the overall trips. 
    This report will help in assessing trip volume, pricing efficiency, and each city's contribution to the overall trip count.
	Fields:
		city_name 	
		total_trips
		avg_fare_per_km 
		avg_fare_per_trip
		%_contribution_to_total_trips
*/
WITH trip_summary AS (
		SELECT 
			c.city_name AS City_name,
            COUNT(t.trip_id) AS Total_trips,
			ROUND(AVG(t.fare_amount), 2) AS Avg_fare,
			ROUND(AVG(t.distance_travelled_km), 2) AS Avg_distance,
			ROUND(SUM(t.fare_amount) / NULLIF(SUM(t.distance_travelled_km), 0), 2) AS avg_fare_per_km,
            ROUND(SUM(t.fare_amount) / NULLIF(COUNT(*), 0), 2) AS avg_fare_per_trip,
            ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM fact_trips), 0), 2) AS percentage_contribution_to_total_trips
		FROM dim_city c
		JOIN fact_trips t ON c.city_id = t.city_id
		GROUP BY City_name
		)
        
SELECT 
	City_name,
    Total_trips,
    avg_fare_per_km,
    avg_fare_per_trip,
    percentage_contribution_to_total_trips
FROM trip_summary
        
        
        
