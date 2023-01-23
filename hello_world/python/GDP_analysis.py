import requests
import os


api_key = os.environ["FRED_API_KEY"]
print(api_key)

r = requests.get(f"https://api.stlouisfed.org/fred/series/observations?series_id=GDPC1&api_key={api_key}&file_type=json")
print(r.status_code)
print(r.json())

