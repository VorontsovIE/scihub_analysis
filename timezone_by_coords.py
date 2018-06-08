import sys
import csv
from timezonefinder import TimezoneFinder
tf = TimezoneFinder()

reader = csv.reader(sys.stdin, delimiter='\t')
for row in reader:
    country, city, lat_str, lng_str = row
    lat, lng = float(lat_str), float(lng_str)
    timezone = tf.certain_timezone_at(lat=lat, lng=lng)
    print(lat_str, lng_str, timezone, sep='\t')
