# bike-share-analysis
## Business task
- Analyze the historical bike trip data of *Cyclistic* to identify trends and gain insights into the differences between annual members and casual riders and determine why casual riders would be motivated to but a membership
- The goal is to understand how these two user groups use bikes differently
- This analysis will help the marketing team design effective marketing strategies to convert casual riders into annual members.<br>

``` understand the differences in usage can help the marketing team create targeted incentives and promotions to encourage casual riders to become annual members ```
<br>
<br>
## Data Collection and Transformation
[Data source's link](https://divvy-tripdata.s3.amazonaws.com/index.html) <br>
The data can be downloaded from above [link](https://divvy-tripdata.s3.amazonaws.com/index.html) and is open-source, availabled by Motivate International Inc. under this [license](https://www.divvybikes.com/data-license-agreement).<br>
<br>
In my analysis, I’m using 2 years of dataset since 2021 to the end of 2022 (2021 - 2022) due to its most current and not too small
<br>
<br>
The dataset store in a seperated files (Grouped by month).<br>
<image src="https://github.com/chinxtd/bike-share-analysis/blob/main/pics/original_files.png"> <br>
#### Data Schema / Description
| Field Name          | Type      | Description                                                          |
|---------------------|-----------|----------------------------------------------------------------------|
| ride_id             | STRING    | Identifier for each ride, which can be used to distinguish individual rides in the dataset. |
| rideable_type       | STRING    | Type of bike used for the ride.                                       |
| started_at          | TIMESTAMP | Timestamp indicating the start time of the ride.                      |
| ended_at            | TIMESTAMP | Timestamp indicating the end time of the ride.                        |
| start_station_name  | STRING    | Name of the station where the ride started.                           |
| start_station_id    | STRING    | Identifier for the station where the ride started.                    |
| end_station_name    | STRING    | Name of the station where the ride ended.                             |
| end_station_id      | STRING    | Identifier for the station where the ride ended.                      |
| start_lat           | FLOAT     | Latitude coordinate of the start station location.                    |
| start_lng           | FLOAT     | Longitude coordinate of the start station location.                   |
| end_lat             | FLOAT     | Latitude coordinate of the end station location.                      |
| end_lng             | FLOAT     | Longitude coordinate of the end station location.                     |
| member_casual       | STRING    | Indicates whether the rider is a member or a casual rider.            |
<br>

I decided to combine them into single table since it would be easier to query and i don’t have to join them together later.
- Since the data is about 2GB of size (about 10M rows). I use Python to combined by the following code
```python
import pandas as pd
import glob

# extract csv file
def extract_csv(file):
    dataframe = pd.read_csv(file)
    return dataframe

# combine csv together
def combine_csv(combining_dir_path):
    combine_data = pd.DataFrame()
    for i in glob.glob(combining_dir_path + "/*.csv"):
        combine_data = combine_data._append(extract_csv(i), ignore_index = True)
    return combine_data

# Call this function
# select the directory that store csv file and choose the target path loading to csv
def load_combined_csv(combining_dir_path, target_dir_path):
    combine_csv(combining_dir_path).to_csv(target_dir_path, index = False)

# execute the function
load_combined_csv("bike_share_2021-2022","2021-2022_bike_share_combined.csv")
```
- With glob module, it will search for the .csv files. Using loop and pandas dataframe to join them together then load and export them back to .csv file. <br>
```To use this code without specifying the column names you need to have the same schema so it’s automatically joining together. Otherwise, you need to specify what column names in the dataframe.```

I prefer to use BigQuery as a Data Warehouse and query engine for analysis.<br>
<br>
First, you need to upload the combined .csv file to the Data Lake which is Google Cloud Storage (GCS) because it cannot upload directly to BigQuery since the file’s size is too large.<br>
<image src="https://github.com/chinxtd/bike-share-analysis/blob/main/pics/bs_1_gcs_upload.png"><br>
<br>
Second, create the dataset in the BigQuery.<br>
<image src="https://github.com/chinxtd/bike-share-analysis/blob/main/pics/bs_2_create_bq_dataset.jpg"><br>
Don't forget to choose the same region with the GCS.<br>
<br>
Then create a blanked table in the dataset.
<image src="https://github.com/chinxtd/bike-share-analysis/blob/main/pics/bs_3_create_bq_dataset_table.png"><br>
<br>
Next, open the Cloud Shell Terminal that located on the top of screen.
Type the followeing command:
```bash
bq load --source_format=CSV --autodetect bikeshare_2021_2022.bike_share gs://bike_share_dataset_2021-2022/2021-2022_bike_share_combined.csv
```
This ‘bq’ command will interact with the BigQuery to move the 2021-2022_bike_share_combined.csv that we have uploaded in the GCS to the blanked table in the BigQuery that we have created.<br>
<image src="https://github.com/chinxtd/bike-share-analysis/blob/main/pics/bs_4_mv_gcs_to_bq.jpg"><br>
If everything done, it will show ‘Current status: DONE’ in the Cloud Shell.<br>
<br>
As of now, your data has been created in the BigQuery and is ready for you to query and analyze.<br>
<image src="https://github.com/chinxtd/bike-share-analysis/blob/main/pics/bs_5_bq_table_preview.png"><br>
<br>
Transform the data. I extracted “day of week”, “quarter of year”, and the “ride length” from the data for my analysis.<br>
Create a view for later use.<br>
```sql
CREATE VIEW `pragmatic-byway-387803.bikeshare_2021_2022.bike_share_transformed_view`
AS
WITH transformed_bike_share
    AS
    (
        SELECT rideable_type, 
        FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(TIMESTAMP_DIFF(ended_at, started_at, SECOND))) AS ride_length,
        EXTRACT(DAYOFWEEK FROM started_at) AS day_of_week,
        EXTRACT(QUARTER FROM started_at) AS quarter_of_year,
        member_casual, started_at, start_station_name
        FROM `bikeshare_2021_2022.bike_share`
    ) 
        SELECT member_casual, rideable_type, ride_length, 
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
```
<br>

## Visualization
I use <i>Tableau public</i> to analyze and visualize.<br>
Since it cannot connect directly to BigQuery with Tableau public, we need to export the data to Google drive then connect to Tableau public.<br>
<br>
Change the datatype to useable format.<br>
<img src="https://github.com/chinxtd/bike-share-analysis/blob/main/pics/tablaeu_1.png">
Through my analysis, i created this dashboard.<br>
<img src="https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;bi&#47;bike_share_16871986164140&#47;Casualvs_AnnualDashboard&#47;1_rss.png">
link to dashboard : https://public.tableau.com/views/bike_share_16871986164140/Casualvs_AnnualDashboard?:language=en-US&:display_count=n&:origin=viz_share_link<br>
<br>

## My findings
- Both casual riders and annual members significantly rised in quarters 1 and 2 (beginning in February) before dropping in quarter 4.
- If we focus more on the day of the week, I found that casual members tend to use bikes more on Saturdays and Sundays, especially in quarters 2 and 3.
- The average riding duration of casual riders is significantly higher than annual members.
    - casual member : ~ 0.50 hour/ride (30 minutes)
    - annual member : ~ 0.20 hour/ride (12 minutes)
- The most popular for casual riders is <i>Streeter Dr & Grand Ave</i>.
<br>
## Recommendations
ongoing ...
