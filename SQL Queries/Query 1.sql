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