require 'tzinfo'

year = 2017

tz = Hash.new{|h,k|
  h[k] = TZInfo::Timezone.get(k)
}

tz_server = tz['Europe/Moscow']

File.open('scihub_local_time.tsv'){|f|
  f.readline # drop header
  # puts ['timezone', 'latDerived', 'lngDerived', *header].join("\t")
  header = [
    'timezone', 'country', 'city',
    'year', 'month', 'day', 'hour', 'min', 'second', 'weekday', 'yearday', 'DST',
    'doi', 'id_by_ip', 'id_by_user',
  ]
  puts header.join("\t")
  f.each_line{|l|
    begin
      row = l.chomp.split("\t")
      local_tz_name, latDerived, lngDerived, \
       month, day, hour, minute, second, \
       dayMinute, weekDay, yearDay, \
       doi, \
       id_by_ip, id_by_user, \
       country, city, lat, lng, \
       latRound, lngRound = *row
      month, day, hour, minute, second = month.to_i, day.to_i, hour.to_i, minute.to_i, second.to_i
      if local_tz_name != 'N/A'
        begin
          tz_local = tz[local_tz_name]
        rescue
          $stderr.puts l
          next
        end
        server_time = Time.new(year, month, day, hour, minute, second)
        utc_time = tz_server.local_to_utc(server_time)
        local_time = tz_local.utc_to_local(utc_time)
        dst = tz_local.period_for_utc(utc_time).dst?

        local_time_fields = [:year, :month, :day, :hour, :min, :sec, :wday, :yday].map{|meth|
          local_time.send(meth)
        }
        infos = [
          local_tz_name, country, city, 
          *local_time_fields, (dst ? 1 : 0),
          doi, id_by_ip, id_by_user,
        ]
        puts infos.join("\t")
      else
        # ignore undefined timezones
      end
    rescue
      $stderr.puts row.inspect
      raise
    end
  }
  # timezone = 'Europe/Berlin'
}


# timezone = TZInfo::Timezone.get(timezone_name)
