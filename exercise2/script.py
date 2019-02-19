import pandas as pd
from requests_futures.sessions import FuturesSession

# load the CSV
data = pd.read_csv('sav_msgs.csv')
print(data.head(3).to_json(orient="records"))

# todo compute dt and exch_nr


# write CSV

# send requests
session = FuturesSession(max_workers=10)
fut = session.post('https://httpbin.org/post', data = {'key':'value'})
r = fut.result()
print(r.text)
