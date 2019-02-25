import pandas as pd
import numpy as np

import schedule
import time
from requests_futures.sessions import FuturesSession

debug = True

# Read the database
def read_db():
  # This just reads the csv file with pandas
  # In production, one should consider the CSV loaded in a DB
  # and use a Python driver to connect the DB
  return pd.read_csv(
    'sav_msgs.csv',
    header = 1,
    names = ['ID', 'SENDER_USER_ID', 'MERCHANT_USER_ID', 'MERCHANT_ID',
      'DATE_CREATION', 'COUNTRY_CODE', 'SAV_GROUP_ID'],
    parse_dates=['DATE_CREATION']
  )

def read_extract(code):
  return pd.read_csv(
    'sav_duration_' + code + '.csv',
    header = 1,
    names = ['MERCHANT_ID', 'exch_nr', 'dt'],
    parse_dates=['dt']
  )

def log_info(x):
  print(x)

def log_error(x):
  print(x)

def merchants_responses(df, code):
  df1 = df[df.COUNTRY_CODE == code]
  df2 = df1[df1.SENDER_USER_ID == df1.MERCHANT_USER_ID]
  return df2.groupby(
    ['MERCHANT_USER_ID', 'MERCHANT_ID']
  ).agg({
    'DATE_CREATION': np.max
  })

def customers_requests(df, code):
  df1 = df[df.COUNTRY_CODE == code]
  df2 = df1[df1.SENDER_USER_ID != df1.MERCHANT_USER_ID]
  return df2.groupby(
    ['SENDER_USER_ID', 'MERCHANT_ID']
  ).agg({
    'ID': len,
    'DATE_CREATION': [np.min, np.max]
  }).sort_values(('ID', 'len'), ascending = False)

def extract_durations():
  messages = read_db()
  log_info(messages.head(10))

  # Dealing with every code available
  # ['fr-fr' 'es-es' 'fr-be' 'de-de' 'it-it']
  for code in messages['COUNTRY_CODE'].unique():
    log_info('SUMMARY FOR ' + code)
    req = customers_requests(messages, code)
    res = merchants_responses(messages, code)
    summary = pd.merge(
      res, req,
      on = 'MERCHANT_ID',
      how = 'inner'
    ).rename(columns = {
      'DATE_CREATION': 'last_answer',
      ('ID', 'len'): 'exch_nr',
      ('DATE_CREATION', 'amin'): 'first_req',
      ('DATE_CREATION', 'amax'): 'last_req'
    }).groupby(
      'MERCHANT_ID'
    ).agg({
      'last_answer': np.max,
      'exch_nr': np.sum,
      'first_req': np.min,
      'last_req': np.max
    })

    summary['dt'] = summary['last_answer'] - summary['last_req']

    if debug:
      log_info(summary[['exch_nr', 'dt']].sample(3))

    # Write CSV
    summary[['exch_nr', 'dt']].to_csv(
      'sav_duration_' + code + '.csv',
      sep = ','
    )

    if not debug:
      send_metrics(code)

def send_metrics(code):
  session = FuturesSession(max_workers=2)

  df = read_extract(code)
  log_info("Sending metrics for " + code)
  for i in range(0, len(df.index), 10):
    records= df[i:i+10].to_json(orient="records")
    fut = session.post('https://httpbin.org/post', data = records)
    r = fut.result()
    if r.status_code == 200:
      log_info("sent 10 records to /metrics")
    else:
      log_error("there was a problem during POST")

# Scheduling using https://github.com/dbader/schedule
if debug:
  extract_durations()
  for code in ['fr-fr']:
    send_metrics(code)
else:
  schedule.every().day.at("08:30").do(extract_durations)

  while True:
    schedule.run_pending()
    time.sleep(1)
