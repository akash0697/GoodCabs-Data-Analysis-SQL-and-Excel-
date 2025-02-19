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
		GROUP BY City_name, Passenger_type
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
