# bike-share-analysis
## Business task
- Analyze the historical bike trip data of *Cyclistic* to identify trends and gain insights into the differences between annual members and casual riders and determine why casual riders would be motivated to but a membership
- The goal is to understand how these two user groups use bikes differently
- This analysis will help the marketing team design effective marketing strategies to convert casual riders into annual members.<br>

``` understand the differences in usage can help the marketing team create targeted incentives and promotions to encourage casual riders to become annual members ```
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
### Data Schema / Description
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

ongoing...
