/*	Business Request - 4: Identify Cities with Highest and Lowest Total New Passengers
	-	Generate a report that calculates the total new passengers for each city and ranks them based on this value. 
    -	Identify the top 3 cities with the highest number of new passengers as well as the bottom 3 cities with the lowest number of new passengers, 
		categorising them as "Top 3" or "Bottom 3" accordingly.
	Fields:
		city_name
		total new_passengers
		city_category ("Top 3" or "Bottom 3")
*/
WITH new_passengers AS (
		SELECT 
			c.city_name AS City_name,
			SUM(p.new_passengers) AS New_passengers
		FROM dim_city c
		JOIN fact_passenger_summary p ON c.city_id = p.city_id
		GROUP BY City_name
		),
	city_ranking AS (
		SELECT 
			City_name,
            New_passengers,
			DENSE_RANK() OVER( ORDER BY New_passengers DESC) AS City_ranking_top,
            DENSE_RANK() OVER( ORDER BY New_passengers ASC) AS City_ranking_bottom
		FROM new_passengers
        )

SELECT 
	City_name,
	New_passengers,
	CASE 
		WHEN City_ranking_top <= 3 THEN 'Top 3'
		WHEN City_ranking_bottom <= 3 THEN 'Bottom 3'
	END AS City_category
FROM city_ranking
WHERE City_ranking_top <= 3 OR City_ranking_bottom <= 3
ORDER BY New_passengers DESC