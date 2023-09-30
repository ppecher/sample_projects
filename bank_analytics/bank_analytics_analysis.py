# 2. Part - EDA and machine learning

import pandas as pd



#read table numbers of days per month -> neccesary for analysis

path_d_m = "days_month.csv"

days_month = pd.read_csv(path_d_m, sep=";")



#read raw data from account (csv) - workaround until data pipeline is build
raw_data = "dkb_file.csv"

account_data_raw = pd.read_csv(raw_data)

#drop columns which are not neccessary

account_data_raw.drop(account_data_raw.iloc[:, 8:12], inplace=True, axis=1)


#renaming colums in more convenient style

account_data_raw.columns = ["transfer_date","valuta_date","transfer_type","receipient","transfer_reason","account_no","bank_no","amount"]


#change data types of raw file for further processes


#date time
account_data_raw["transfer_date"] = pd.to_datetime(account_data_raw["transfer_date"],dayfirst=True)
account_data_raw["valuta_date"] = pd.to_datetime(account_data_raw["valuta_date"],dayfirst=True)

#generate month and year

account_data_raw["month_num"] = pd.DatetimeIndex(account_data_raw['valuta_date']).month
account_data_raw["valuta_year"] = pd.DatetimeIndex(account_data_raw['valuta_date']).year

account_data_raw["transfer_month"] = pd.DatetimeIndex(account_data_raw['transfer_date']).month
account_data_raw["transfer_year"] = pd.DatetimeIndex(account_data_raw['transfer_date']).year
#string
#not neccessary?



#float

#pandas can't handle commas in floating numbers. Thus, commas need to be replaced by points befor converting to float

account_data_raw["amount"] = account_data_raw["amount"].str.replace(".","", regex=True)
account_data_raw["amount"] = account_data_raw["amount"].str.replace(",",".", regex=True)


account_data_raw["amount"] = pd.to_numeric(account_data_raw["amount"])


#merging of two dfs to daily amounts


account_data_month = account_data_raw.groupby(["month_num", "valuta_year"], as_index= False)["amount"].sum()


account_data = account_data_month.merge(days_month, on = 'month_num', how = 'left')

account_data["av_amount_day"] = account_data["amount"].div(account_data["days_month"])

print(account_data) 