require 'tzinfo'

WDAY_BY_IDX = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

def weekhour_10_human(weekhour_10)
  hour_period = 6 # six 10-minute-long periods
  day_period = hour_period * 24
  wday = weekhour_10 / day_period
  hour = (weekhour_10 % day_period) / hour_period
  minute = 10* ((weekhour_10 % day_period) % hour_period)
  "%s, %02d:%02d" % [WDAY_BY_IDX[wday], hour, minute]
end

DATETIME_PATTERN = /^(?<year>\d+)-0?(?<month>\d+)-0?(?<day>\d+) 0?(?<hour>\d+):0?(?<minute>\d+):0?(?<second>\d+)$/

tz_server = TZInfo::Timezone.get('Europe/Moscow')
tm_period_counts = $stdin.each_line.lazy.map{|l|
  l.chomp!
  datetime = l
  time_parts = DATETIME_PATTERN.match(datetime).named_captures
  # Timezone got during server_time construction will be ignored by Timezone#local_to_utc.
  # Thus server_time timezone will come from tz_server
  server_time = Time.new(*time_parts.values_at('year', 'month', 'day', 'hour', 'minute', 'second').map(&:to_i))
  tz_server.local_to_utc(server_time) # utc_time
}.each_with_object(Hash.new(0)){|tm, hsh|
  tm_period = 24*6*(tm.yday - 1) + 6*tm.hour + tm.min / 10
  hsh[tm_period] += 1
}

online_count = Hash.new(0)
total_count = Hash.new(0)

(0...366*24*6).each{|tm_period, hsh|
  tm = Time.utc(2017,1,1) + tm_period*60*10
  wday = (tm.wday + 6) % 7
  weekhour_10 = wday * 24*6 + tm.hour * 6 + tm.min / 10

  online_count[weekhour_10] += 1  if tm_period_counts[tm_period] > 0
  total_count[weekhour_10] += 1
}

(0...7*24*6).each{|weekhour_10|
  infos = [
    weekhour_10_human(weekhour_10),
    total_count[weekhour_10],
    online_count[weekhour_10],
    online_count[weekhour_10].to_f / total_count[weekhour_10]
  ]
  puts infos.join("\t")
}
