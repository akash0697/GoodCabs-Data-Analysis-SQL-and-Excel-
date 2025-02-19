/*	Business Request - 6: Repeat Passenger Rate Analysis
	-	Generate a report that calculates two metrics:
			1.	Monthly Repeat Passenger Rate: Calculate the repeat passenger rate for each city and 
				month by comparing the number of repeat passengers to the total passengers.
			2.	City-wise Repeat Passenger Rate: Calculate the overall repeat passenger rate for each city, 
				considering all passengers across months.
	-	These metrics will provide insights into monthly repeat trends as well as the overall repeat behaviour for each city.
	Fields:
		city_name 
		month
		total_passengers
		repeat_passengers
		monthly_repeat_passenger_rate (%): Repeat passenger rate at the city and month level
		city_repeat_passenger_rate (%): Overall repeat passenger rate for each city, aggregated across months
*/
WITH passengers AS (
		SELECT 
			c.city_name AS City_name,
			MONTH(month) AS Months,
            SUM(new_passengers) AS New_passengers,
			SUM(repeat_passengers) AS Repeat_passengers
		FROM trips_db.fact_passenger_summary f
        JOIN trips_db.dim_city c ON f.city_id = c.city_id
		GROUP BY City_name, Months
		), 
	Monthly_RPR AS (
		SELECT 
			City_name,
			Months,
			New_passengers,
			Repeat_passengers,
            New_passengers + Repeat_passengers AS Total_passengers,
			ROUND((Repeat_passengers*100.0)/(New_passengers + Repeat_passengers),2) AS Monthly_RPR_Percentage
		FROM passengers 
        ),
	total_RPR AS (
		SELECT 
			City_name,
            SUM(Repeat_passengers) AS Total_repeat_passengers,
			SUM(New_passengers + Repeat_passengers) AS Total_passengers,
            ROUND((SUM(Repeat_passengers) * 100.0) / SUM(New_passengers + Repeat_passengers), 2) AS City_RPR_Percentage
		FROM passengers
        GROUP BY City_name
        ),
	final_report AS (
		SELECT 
			m.City_name,
			m.Months,
			m.Total_passengers,
			m.Repeat_passengers,
			m.Monthly_RPR_Percentage,
			t.City_RPR_Percentage
		FROM Monthly_RPR m
		JOIN total_RPR t ON m.City_name = t.City_name
        )
        
SELECT
	City_name,
	Months,
	Total_passengers,
	Repeat_passengers,
	Monthly_RPR_Percentage,
	City_RPR_Percentage
FROM final_report
ORDER BY City_name, Months
