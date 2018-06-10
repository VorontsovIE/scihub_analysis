import csv

# resulting dict will have tuple keys like ('Russia',) for countries and ('Russia', 'Moskva') for cities
# also function returns header with interval descriptions
def read_time_counts(counts_filename, mode, counts_by_place_container, header_container=None):
    with open(counts_filename) as f:
        reader = csv.reader(f, delimiter='\t')
        for idx,row in enumerate(reader):
            if idx == 0: # drop header
                timerange_header = row[2:]
                continue

            if mode == 'country':
                country = row[0]
                # total = int(row[1])
                counts = row[2:]
                place = (country,)                
            elif mode == 'city':
                country = row[0]
                city = row[1]
                # total = int(row[2])
                counts = row[3:]
                place = (country, city)
            
            counts_by_place_container[place] = [float(x) for x in counts]
        if header_container != None:
            del header_container[:]
            header_container.extend(timerange_header)

###################################

def read_all_time_counts():
    global rates_weektime10_by_place, WEEKTIME10_HEADER
    global rates_weektime60_by_place, WEEKTIME60_HEADER
    global rates_daytime10_by_place, DAYTIME10_HEADER

    rates_weektime10_by_place, WEEKTIME10_HEADER = {}, []
    read_time_counts('rates/country/weekhour_10.tsv', 'country', rates_weektime10_by_place, WEEKTIME10_HEADER)
    read_time_counts('rates/city/weekhour_10.tsv', 'city', rates_weektime10_by_place)

    rates_weektime60_by_place, WEEKTIME60_HEADER = {}, []
    read_time_counts('rates/country/weekhour.tsv', 'country', rates_weektime60_by_place, WEEKTIME60_HEADER)
    read_time_counts('rates/city/weekhour.tsv', 'city', rates_weektime60_by_place)

    rates_daytime10_by_place, DAYTIME10_HEADER = {},[]
    read_time_counts('rates/country/daytime_10.tsv', 'country', rates_daytime10_by_place, DAYTIME10_HEADER)
    read_time_counts('rates/city/daytime_10.tsv', 'city', rates_daytime10_by_place)

    # It's for presentational reasons only
    WEEKTIME10_HEADER += ['Sun, 24:00'] # Sun, 24:00 is the same as Mon, 00:00
    WEEKTIME60_HEADER += ['Sun, 24:00']
    DAYTIME10_HEADER += ['24:00']  # 24:00 is the same as 00:00
###################################
