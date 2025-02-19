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