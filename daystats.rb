require 'date'
data = ARGF.readlines.map{|l|
  l.chomp.split("\t")[0, 3].map(&:to_i)
}
counts_at_each_hour = data.group_by{|month, day, hour|
  [month, day, hour / 3]
}.map{|(month,day,hour), grp|
  [month, day, hour * 3, grp.size]
}

counts_by_day = counts_at_each_hour.group_by{|month, day, hour, _sz|
  [month,day]
}.map{|(month, day), day_stats|
  day_total = day_stats.map(&:last).sum
  best_hour, best_hour_count = day_stats.max_by{|_month, _day, hour, sz| sz }.values_at(2,3);
  [[month,day], {day_total: day_total, best_hour: best_hour, best_hour_count: best_hour_count}]
}.to_h

stats_nothing = {day_total: 0, best_hour: -10, best_hour_count: 0}

year_days = (Date.new(2017,1,1)...Date.new(2018,1,1)).map{|dt| [dt.month, dt.day] }
year_days.map{|monthday|
  day_stats = counts_by_day.fetch(monthday, stats_nothing)
  # [*monthday, day_stats]
  best_fraction = (day_stats[:best_hour_count] * 100 / day_stats[:day_total]) rescue -1
  [*monthday, *day_stats.values_at(:day_total, :best_hour, :best_hour_count), best_fraction]
}.each{|infos|
  puts infos.join("\t")
}
