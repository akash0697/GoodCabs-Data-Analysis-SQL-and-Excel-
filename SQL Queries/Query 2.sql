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