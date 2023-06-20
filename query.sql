-- create transformed view from bike_share dataset
CREATE VIEW `pragmatic-byway-387803.bikeshare_2021_2022.bike_share_transformed_view`
AS
WITH transformed_bike_share
    AS
    (
        SELECT rideable_type, 
        TIMESTAMP_DIFF(ended_at, started_at, SECOND) AS ride_length,
        EXTRACT(DAYOFWEEK FROM started_at) AS day_of_week,
        EXTRACT(QUARTER FROM started_at) AS quarter_of_year,
        member_casual, started_at, start_station_name
        FROM `bikeshare_2021_2022.bike_share`
    ) 
        SELECT member_casual, rideable_type, ride_length/3600 AS hourly_ride_length, 
            CASE
                WHEN day_of_week = 1 THEN "Sunday"
                WHEN day_of_week = 2 THEN "Monday"
                WHEN day_of_week = 3 THEN "Tuesday"
                WHEN day_of_week = 4 THEN "Wednesday"
                WHEN day_of_week = 5 THEN "Thursday"
                WHEN day_of_week = 6 THEN "Friday"
                WHEN day_of_week = 7 THEN "Saturday"
                ELSE "Not applicable"
            END AS day_of_week_name,
            quarter_of_year, started_at, start_station_name
        FROM transformed_bike_share;