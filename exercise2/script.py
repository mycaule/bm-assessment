import pandas as pd
import numpy as np
from requests_futures.sessions import FuturesSession

# Read the database
def read_db():
  # This just reads the csv file with pandas
  # In production, one should consider the CSV loaded in a DB
  # and use a Python driver to connect the DB
  return pd.read_csv(
    'sav_msgs.csv',
    header = 1,
    names = ['ID', 'SENDER_USER_ID', 'MERCHANT_USER_ID', 'MERCHANT_ID', 'DATE_CREATION', 'COUNTRY_CODE', 'SAV_GROUP_ID'],
    parse_dates=['DATE_CREATION']
  )

def log_info(x):
  print(x)

def summarize(df, code):
  df1 = df[df.COUNTRY_CODE == code]
  gb = df1.groupby(['SENDER_USER_ID', 'MERCHANT_USER_ID', 'MERCHANT_ID'])
  return gb.agg({
    'ID' : len,
    'DATE_CREATION' : [np.min, np.max]
  }).sort_values(
    ('ID', 'len'),
    ascending = False
  )

messages = read_db()
log_info(messages.head(10))

# Dealing with every code available
# ['fr-fr' 'es-es' 'fr-be' 'de-de' 'it-it']
for code in messages['COUNTRY_CODE'].unique():
  log_info('SUMMARY FOR ' + code)
  log_info(summarize(messages, code).head(10))

# Write CSV

# Send requests
# to_json(orient="records") by batches of 10

session = FuturesSession(max_workers=10)
fut = session.post('https://httpbin.org/post', data = {'key':'value'})
r = fut.result()
print(r.text)
