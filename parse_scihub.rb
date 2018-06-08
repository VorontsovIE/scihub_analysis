require 'date'
headers = [
  'month', 'day', 'hour', 'minute', 'second',
  'dayMinute', 'weekDay', 'yearDay',
  'doi',
  'IdByIp', 'IdByUser',
  'country', 'city', 'lat', 'lng',
  'latRound', 'lngRound'
]
puts headers.join("\t")

$stdin.each_line{|l|
  datetime, doi, id_by_ip, id_by_user, country, city, lat, lng = l.chomp.split("\t")
  # month = Integer(datetime[5,2], 10)
  # day = Integer(datetime[8,2], 10)
  # hr = Integer(datetime[11,2], 10)
  # min = Integer(datetime[14,2], 10)
  # sec = Integer(datetime[17,2], 10)
  date = DateTime.parse(datetime)
  lat = (lat == 'N/A') ? nil : lat
  lng = (lng == 'N/A') ? nil : lng
  infos = [
    date.month, date.day, date.hour, date.minute, date.second, 
    date.hour*60 + date.minute,
    (date.wday - 1) % 7 + 1,
    date.yday,
    doi,
    id_by_ip, id_by_user,
    country, city, lat, lng,
    lat && Float(lat).round, lng && Float(lng).round
  ]
  puts infos.join("\t")
  # puts [month, day, hr, min, sec, hr*60+min, doi, id_by_ip, id_by_user, country, city, lat, lng, lat && Float(lat).round, lng && Float(lng).round].join("\t")
}
