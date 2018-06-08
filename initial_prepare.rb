require 'tzinfo'
require 'date'

DATETIME_PATTERN = /^(?<year>\d+)-0?(?<month>\d+)-0?(?<day>\d+) 0?(?<hour>\d+):0?(?<minute>\d+):0?(?<second>\d+)$/

tz_by_country = {}
File.readlines('country_timezones.tsv').map{|l|
  country, tz = l.chomp.split("\t")
  tz_by_country[country] = tz
}

tz_by_city = {}
File.readlines('city_timezones.tsv').map{|l|
  country, city, tz = l.chomp.split("\t")
  tz_by_city[country] ||= {}
  tz_by_city[country][city] = tz
}

tz_by_coord = {}
File.readlines('timezone_by_coords.tsv').map{|l|
  lat, lng, tz = l.chomp.split("\t")
  tz_by_coord[lat] ||= {}
  tz_by_coord[lat][lng] = tz
}


tz_by_name = Hash.new{|h,k|
  h[k] = TZInfo::Timezone.get(k)
}

tz_server = tz_by_name['Europe/Moscow']

$stdin.each_line{|l|
  datetime, doi, ip,user, country,city, lat,lng = l.chomp.split("\t")
  
  doi_prefix = doi.split("/").first
  tz_name = tz_by_country[country]
  tz_name ||= tz_by_city[country] && tz_by_city[country][city]
  tz_name ||= tz_by_coord[lat] && tz_by_coord[lat][lng]

  # $stderr.puts(tz_name)
  if tz_name
    tz_local = tz_by_name[tz_name]
    time_parts = DATETIME_PATTERN.match(datetime).named_captures
    # Timezone got during server_time construction will be ignored by Timezone#local_to_utc.
    # Thus server_time timezone will come from tz_server
    server_time = Time.new(*time_parts.values_at('year', 'month', 'day', 'hour', 'minute', 'second').map(&:to_i))
    utc_time = tz_server.local_to_utc(server_time)
    local_time = tz_local.utc_to_local(utc_time)
    # local_time doesn't have correct DST flag, so we should get it from timezone info
    dst = tz_local.period_for_utc(utc_time).dst?
    local_time_infos = [*[:year, :month, :day, :hour, :min, :sec, :wday, :yday].map{|meth| local_time.send(meth) }, dst ? 1 : 0]
    
    infos = [country, city, *local_time_infos, doi_prefix, ip, user, datetime, doi, lat, lng]
    
    # here we should recover timezone
    puts infos.join("\t")
  else
    raise "Some info given but tz not found:\n#{l}"  unless (city == 'N/A' && lat == 'N/A' && lng == 'N/A')
    infos = [country, datetime, doi_prefix, ip, user, doi]
    $stderr.puts infos.join("\t")
  end
}
