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

load_combined_csv("bike_share_2021-2022","2021-2022_bike_share_combined.csv")