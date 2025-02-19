/*	7.	Monthly Target Achievement Analysis for Key Metrics --
		For each city, evaluate monthly performance against targets for total trips, new passengers, and average passenger ratings 
        from targets db. Determine if each metric met, exceeded, or missed the target, and calculate the percentage difference. 
        Identify any consistent patterns in target achievement, particularly across tourism versus business-focused cities.
*/
WITH passengers AS (
		SELECT 
			city_id, 
			MONTH(month) AS Months,
			SUM(new_passengers) AS Actual_new_passengers
		FROM trips_db.fact_passenger_summary
		GROUP BY city_id, Months
		),
	trips AS (
		SELECT  
			t.city_id AS City_id,
			MONTH(t.date) AS Months,
			count(t.trip_id) AS Actual_trips,
			ROUND(AVG(t.passenger_rating),2) AS Actual_avg_passenger_rating
		FROM trips_db.fact_trips t
		GROUP BY city_id, Months
        ), 
	total_trips AS (
		SELECT 
			t.City_id, 
			t.Months,
			t.Actual_trips,
			t.Actual_avg_passenger_rating,
			p.Actual_new_passengers
		FROM trips t
		JOIN passengers p ON t.City_id=p.city_id
			AND t.Months=p.Months
            ),
	Actual_trips AS (
		SELECT  
			t.City_id,
			c.city_name AS City_name,
			t.Months,
			t.Actual_trips,
			t.Actual_new_passengers,
			t.Actual_avg_passenger_rating
		FROM total_trips t
		JOIN trips_db.dim_city c ON t.City_id = c.city_id
        ),
	target AS (
		SELECT 
			t.city_id AS City_id,
			MONTH(t.month) AS Months,
			t.total_target_trips AS Total_target_trips,
			p.target_new_passengers AS Target_new_passengers
		FROM monthly_target_trips t
		JOIN monthly_target_new_passengers p ON t.city_id = p.city_id
			AND t.month = p.month
        ),
	target_trips AS (
		SELECT 
			t.City_id,
			t.Months,
			t.Total_target_trips,
			t.Target_new_passengers,
			r.target_avg_passenger_rating AS Target_avg_passenger_rating
		FROM target t
		JOIN city_target_passenger_rating r ON t.City_id = r.city_id
        ),
	comparison AS (
		SELECT  
			t.city_id,
			c.city_name AS City_name,
			t.Months,
			t.Total_target_trips,
			total.Actual_trips,
			ROUND((total.Actual_trips - t.Total_target_trips) * 100.0 / t.Total_target_trips, 2) AS Trip_Percent_Diff,
			CASE 
				WHEN total.Actual_trips >= t.Total_target_trips THEN 'Met/Exceeded'
				ELSE 'Missed'
			END AS Trip_Target_Status,
			t.Target_new_passengers,
			total.Actual_new_passengers,
			ROUND((total.Actual_new_passengers - t.Target_new_passengers) * 100.0 / t.Target_new_passengers, 2) AS Passenger_Percent_Diff,
			CASE 
				WHEN total.Actual_new_passengers >= t.Target_new_passengers THEN 'Met/Exceeded'
				ELSE 'Missed'
			END AS Passenger_Target_Status,
			t.Target_avg_passenger_rating,
			total.Actual_avg_passenger_rating,
			ROUND((total.Actual_avg_passenger_rating - t.Target_avg_passenger_rating) * 100.0 / t.Target_avg_passenger_rating, 2) AS Rating_Percent_Diff,
			CASE 
				WHEN total.Actual_avg_passenger_rating >= t.Target_avg_passenger_rating THEN 'Met/Exceeded'
				ELSE 'Missed'
			END AS Rating_Target_Status
		FROM target_trips t
		JOIN total_trips total 
			ON t.city_id = total.city_id AND t.Months = total.Months
		JOIN trips_db.dim_city c 
			ON t.city_id = c.city_id
		)
    
SELECT 
    City_name,
    Months,
    Total_target_trips,
    Actual_trips,
    Trip_Percent_Diff AS 'Trip_%_Diff',
    Trip_Target_Status,
    Target_new_passengers,
    Actual_new_passengers,
    Passenger_Percent_Diff AS 'Passenger_%_Diff',
    Passenger_Target_Status,
    Target_avg_passenger_rating,
    Actual_avg_passenger_rating,
    Rating_Percent_Diff AS 'Rating_%_Diff',
    Rating_Target_Status
FROM comparison;