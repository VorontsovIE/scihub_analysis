require 'tzinfo'

year = 2017


tz_by_coord = {'N/A' => {'' => {':' => ''}}}
coords_by_city = {'N/A' => {'' => {lat: nil, lng: nil}}}
File.readlines('city_tz.tsv').map{|l|
  country, city, lat, lng, tz = l.chomp.split("\t")
  tz_by_coord[country] ||= {}
  city = ''  if city == 'N/A'
  tz_by_coord[country][city] ||= {}
  tz_by_coord[country][city]["#{lat}:#{lng}"] = tz
  tz_by_coord[country][city][":"] = tz
  coords_by_city[country] ||= {}
  coords_by_city[country][city] = {lat: lat, lng: lng}
};nil
File.readlines('coords_tz.tsv').map{|l|
  country, city, lat, lng, tz = l.chomp.split("\t")
  lat, lng = Float(lat), Float(lng)  if lat && !lat.empty?
  tz_by_coord[country] ||= {}
  city = ''  if city == 'N/A'
  tz_by_coord[country][city] ||= {}
  tz_by_coord[country][city]["#{lat}:#{lng}"] = tz
};nil


tz = Hash.new{|h,k|
  h[k] = TZInfo::Timezone.get(k)
}

tz_server = tz['Europe/Moscow']


File.open('scihub_stats_2017_refined.tsv'){|f|
  header = f.readline.chomp.split("\t") # drop header
  puts ['timezone', 'latDerived', 'lngDerived', *header].join("\t")
  f.each_line{|l|
    begin
    row = l.chomp.split("\t")
    
    month, day, hour, minute, second, \
     dayMinute, weekDay, yearDay, \
     doi, \
     id_by_ip, id_by_user, \
     country, city, lat, lng, \
     latRound, lngRound = *row
    city = ''  if city == 'N/A'
    lat, lng = Float(lat), Float(lng)  if lat && !lat.empty?
    local_tz_name = tz_by_coord.fetch(country).fetch(city).fetch("#{lat}:#{lng}")
    # month, day, hour, minute, second = month.to_i, day.to_i, hour.to_i, minute.to_i, second.to_i
    lat_derived = lat ? lat : coords_by_city[country][city][:lat]
    lng_derived = lng ? lng : coords_by_city[country][city][:lng]
    puts [local_tz_name && !local_tz_name.empty? ? local_tz_name : 'N/A', lat_derived || 'N/A', lng_derived || 'N/A', *row].join("\t")
    # tz_local.utc_to_local(tz_server.local_to_utc(Time.new(year, month, day, hour, minute)))
    rescue
      $stderr.puts row.inspect
      raise
    end
  }
  # timezone = 'Europe/Berlin'
  # tz_local = tz[timezone]
}


# timezone = TZInfo::Timezone.get(timezone_name)
