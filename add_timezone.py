import sys
import csv
from timezonefinder import TimezoneFinder
tf = TimezoneFinder()

geocode_places = {('N/A', 'N/A'): (None,None), ('N/A', ''): (None,None) }
with open('geocoded_place_coords.tsv') as f:
    reader = csv.reader(f, delimiter='\t')
    for row in reader:
        country, city, location, lat, lng, *rest = row
        geocode_places[(country, city)] = (lat,lng)

with open('coords_diff_2.tsv') as f:
    reader = csv.reader(f, delimiter='\t')
    reader.__next__() # drop header
    for row in reader:
        try: 
            if len(row) == 4:
                country, city, lat, lng = row
            elif len(row) == 2:
                country, city = row
                lat, lng = None, None
            elif len(row) == 1:
                country = row[0]
                city = ''
                lat, lng = None, None

            if lat == '':
                if city == 'N/A' or city == None:
                    city = ''
                lat, lng = geocode_places[(country, city)]
            if lat != None:
                lat, lng = float(lat), float(lng)

            timezone=tf.certain_timezone_at(lat=lat, lng=lng) # certain_timezone_at
            print(country, city, lat, lng, timezone, sep='\t')
        except Exception:
            pass
            # print(*row, sep="\t")
    


# with open('scihub_stats_2017_refined.tsv') as f:
#     reader = csv.reader(f, delimiter='\t')
#     reader.__next__() # drop header
#     for idx, row in enumerate(reader):
#         month, day, hour, minute, second, dayMinute, weekDay, yearDay, doi, IdByIp, IdByUser, country, city, lat, lng, latRound, lngRound = row
#         if len(lat) > 0:
#             pass
#             # lat, lng = float(lat), float(lng)
#             # timezone=tf.timezone_at(lat=lat, lng=lng) # certain_timezone_at
#         else:

#             timezone='undefined'
#             # print(timezone, row)
#             print(country, city, timezone, sep='\t')
#         if idx == 10000000:
#             break
