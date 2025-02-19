/*	1.	Top and Bottom Performing Cities -- 
		Identify the top 3 and bottom 3 cities by total trips over the entire analysis period.
*/
-- Top 3 performing cities by total trips
SELECT  
	c.city_name, 
    count(trip_id) AS Top_3_performance
FROM dim_city c
JOIN fact_trips t ON c.city_id = t.city_id
group by c.city_name
order by Top_3_performance desc
LIMIT 3;

-- Bottom 3 performing cities by total trips
SELECT  
	c.city_name, 
    count(trip_id) AS Bottom_3_performance
FROM dim_city c
JOIN fact_trips t ON c.city_id = t.city_id
group by c.city_name
order by Bottom_3_performance
LIMIT 3; 

----------------------------------------------------------------------------------------------------
/*	2.	Avg fare per trip by city; highest & lowest --
		Calculate the average fare per trip for each city and compare it with the city's average trip distance. 
        Identify the cities with the highest and lowest average fare per trip to assess pricing efficiency across locations.
*/
WITH Avg_fare_per_trip AS (
		SELECT 
			c.city_name AS City_name,
			ROUND(AVG(t.fare_amount), 2) AS Avg_fare,
			ROUND(AVG(t.distance_travelled_km), 2) AS Avg_distance
		FROM dim_city c
		JOIN fact_trips t ON c.city_id = t.city_id
		GROUP BY c.city_name
		),
	City_ranking AS (
		SELECT 
			City_name,
			Avg_fare, 
			Avg_distance,
			RANK() OVER(ORDER BY Avg_fare DESC) AS highest_rank,
			RANK() OVER(ORDER BY Avg_fare ASC) AS lowest_rank
		FROM Avg_fare_per_trip
        )

SELECT 
	City_name, 
    Avg_fare,
    Avg_distance,
    CASE
        WHEN highest_rank = 1 THEN 'Highest'
        WHEN lowest_rank = 1 THEN 'Lowest'
    END AS rank_status
FROM City_ranking
WHERE highest_rank = 1 or lowest_rank = 1
ORDER BY Avg_fare DESC;

----------------------------------------------------------------------------------------------------
/*	3.	Avg Ratings by city & passenger type --
		Calculate the average passenger and driver ratings for each city, segmented by passenger type (new vs. repeat). 
        Identify cities with the highest and lowest average ratings.
*/
WITH Avg_ratings AS (
		SELECT 
			c.city_name AS City_name,
            t.passenger_type AS Passenger_type,
			ROUND(AVG(t.passenger_rating), 2) AS Avg_passenger_rating,
			ROUND(AVG(t.driver_rating), 2) AS Avg_driver_rating
		FROM dim_city c
		JOIN fact_trips t ON c.city_id = t.city_id
		GROUP BY c.city_name, t.passenger_type
		),
	rating_ranking AS (
		SELECT 
			City_name,
            Passenger_type,
			Avg_passenger_rating, 
			Avg_driver_rating,
			RANK() OVER( ORDER BY Avg_passenger_rating DESC) AS highest_rank,
			RANK() OVER( ORDER BY Avg_passenger_rating ASC) AS lowest_rank
		FROM Avg_ratings
        )

SELECT 
	City_name, 
    Passenger_type,
	Avg_passenger_rating, 
	Avg_driver_rating,
    CASE
        WHEN highest_rank = 1 THEN 'Highest'
        WHEN lowest_rank = 1 THEN 'Lowest'
    END AS rank_status
FROM rating_ranking
WHERE highest_rank = 1 or lowest_rank = 1
ORDER BY City_name, Avg_passenger_rating DESC;

----------------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------
/*	8.	Highest and Lowest Repeat Passenger Rate (RPR%) by City and Month --
		I.	Analyse the Repeat Passenger Rate (RPR%) for each city across the six-month period. 
			Identify the top 2 and bottom 2 cities based on their RPR% to determine which locations have the strongest and weakest rates.
		II.	Similarly, analyse the RPR% by month across all cities and identify the months with the highest and lowest repeat passenger rates. 
			This will help to pin-point any seasonal patterns or months with higher repeat passenger loyalty.
*/
WITH passengers AS (
		SELECT 
			city_id AS City_id, 
			MONTH(month) AS Months,
            SUM(new_passengers) AS New_passengers,
			SUM(repeat_passengers) AS Repeat_passengers
		FROM trips_db.fact_passenger_summary
		GROUP BY city_id, Months
		), 
	Repeat_passenger_rate AS (
		SELECT 
			p.City_id,
            c.city_name AS City_name,
			p.Months,
			p.New_passengers,
			p.Repeat_passengers,
			ROUND((Repeat_passengers*100.0)/(New_passengers + Repeat_passengers),2) AS RPR_Percentage
		FROM passengers p
        JOIN trips_db.dim_city c ON p.City_id = c.city_id
        ),
	Avg_RPR_by_city AS (
		SELECT 
			City_name,
			ROUND(Avg(RPR_Percentage),2) AS RPR_Percentage
		FROM Repeat_passenger_rate
        GROUP BY City_name
        ),
	Avg_RPR_by_month AS (
		SELECT 
			Months,
			ROUND(Avg(RPR_Percentage),2) AS RPR_Percentage
		FROM Repeat_passenger_rate
        GROUP BY Months
        )
        
-- Top and Bottom 2 Cities by RPR%: 
(
SELECT * 
FROM Avg_RPR_by_city
ORDER BY RPR_Percentage DESC
LIMIT 2
)
UNION ALL
(
SELECT * 
FROM Avg_RPR_by_city
ORDER BY RPR_Percentage ASC
LIMIT 2
); 
-- Months with Highest and Lowest RPR%:
(
SELECT *
FROM Avg_RPR_by_month
ORDER BY RPR_Percentage DESC
LIMIT 1
)
UNION ALL
(
SELECT *
FROM Avg_RPR_by_month
ORDER BY RPR_Percentage ASC
LIMIT 1
);