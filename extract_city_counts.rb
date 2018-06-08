require 'fileutils'
FileUtils.mkdir_p 'counts/city/'
FileUtils.mkdir_p 'rates/city/'

wday_by_idx = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
total_by_zone = {}
yday_by_zone, wday_by_zone, daytime_10_by_zone, hour_by_zone, weekhour_by_zone, weekhour_10_by_zone, doi_prefix_by_zone, mean_daytime_by_zone = {}, {}, {}, {}, {}, {}, {}, {}
yday_range = [366] + (1..365).to_a # 366 is for leap year (end of 2016 was 366-th)
wday_range = (0..6) # Monday - Sunday
daytime_range_10 = (0 ... 6*24) # six 10-minute intervals per time
hour_range = (0 ... 24)
weekhour_range = (0 ... 24*7)
weekhour_10_range = (0 ... 6*24*7)
doi_prefixes = File.readlines('doi_prefixes.tsv').map(&:chomp).sort

daytime_10_header = daytime_range_10.map{|bin| h,m = (bin * 10) / 60, (bin * 10) % 60; "%02d:%02d" % [h,m] }
wday_header = wday_range.map{|wday_idx| wday_by_idx[wday_idx] }
yday_header = yday_range.map{|yday|
  tm = Time.new(2017,1,1) + (yday - 1)*24*3600
  yday == 366 ? 'Dec, 31' : tm.strftime('%b, %d') # 2016 was a leap year and contributed to 366-th day
}
hour_header = hour_range.map{|hour| "%02d:00" % hour }
weekhour_10_header = weekhour_10_range.map{|weekhour_10|
  hour_period = 6 # six 10-minute-long periods
  day_period = hour_period * 24
  wday = weekhour_10 / day_period
  hour = (weekhour_10 % day_period) / hour_period
  minute = 10* ((weekhour_10 % day_period) % hour_period)
  "%s, %02d:%02d" % [wday_by_idx[wday], hour, minute]
}
weekhour_header = weekhour_range.map{|weekhour|
  wday = weekhour / 24
  hour = weekhour % 24
  "%s, %02d:00" % [wday_by_idx[wday], hour]
}

Dir.glob('by_city/**/*.tsv').sort.each{|fn|
  $stderr.puts(fn)
  total = 0
  sum_daytime = Hash.new(0) # necessary to calculate mean time along each day
  wday_counts = Hash.new(0)
  yday_counts = Hash.new(0)
  daytime_counts_10 = Hash.new(0)
  hour_counts = Hash.new(0)
  weekhour_counts = Hash.new(0)
  weekhour_10_counts = Hash.new(0)
  doi_prefix_counts = Hash.new(0)

  country, city = nil, nil

  File.open(fn){|f|
    f.each_line{|l|
      row = l.chomp.split("\t")
      country, city,
        year, month, day, hour, min, sec, unnormed_wday, yday, dst,
        doi_prefix, ip, user, datetime, doi, lat, lng = *row

      unnormed_wday = Integer(unnormed_wday) # 0 - Sunday
      wday = (unnormed_wday + 6) % 7 # starts from monday - 0th day, ends at sunday - 6th day
      yday = Integer(yday)

      hour = Integer(hour)
      min = Integer(min)
      daytime = hour * 60 + min

      total += 1
      wday_counts[wday] += 1
      yday_counts[yday] += 1
      daytime_counts_10[daytime / 10] += 1
      hour_counts[hour] += 1
      weekhour_counts[wday * 24 + hour] += 1
      weekhour_10_counts[6 * (wday * 24 + hour) + (min / 10)] += 1
      doi_prefix_counts[doi_prefix] += 1
      sum_daytime[yday] += daytime
    }
  }
  

  zone = [country, city]
  total_by_zone[zone] = total
  yday_by_zone[zone]  = yday_range.map{|yday| yday_counts[yday] }
  wday_by_zone[zone]  = wday_range.map{|wday| wday_counts[wday] }
  daytime_10_by_zone[zone] = daytime_range_10.map{|idx| daytime_counts_10[idx] }
  hour_by_zone[zone]       = hour_range.map{|idx| hour_counts[idx] }
  weekhour_by_zone[zone]  = weekhour_range.map{|idx| weekhour_counts[idx] }
  weekhour_10_by_zone[zone]  = weekhour_10_range.map{|idx| weekhour_10_counts[idx] }
  doi_prefix_by_zone[zone] = doi_prefixes.map{|doi_prefix| doi_prefix_counts[doi_prefix] }
  mean_daytime_by_zone[zone] = yday_range.map{|yday| 
    # rounding here is ok, we don't need precision more than a minute
    (yday_counts[yday] == 0) ? 0 : sum_daytime[yday] / yday_counts[yday]
  }
}

###############

def save_counts(filename, counts_by_zone, header, skip_total: false)
  File.open(filename, 'w'){|fw|
    if skip_total
      fw.puts ['country', 'city', *header].join("\t")
    else
      fw.puts ['country', 'city', 'total', *header].join("\t")
    end
    counts_by_zone.sort.each{|zone, row|
      if skip_total
        fw.puts [*zone, *row].join("\t")
      else
        total = row.sum
        fw.puts [*zone, total, *row].join("\t")
      end
    }
  }
end

def save_rates(filename, counts_by_zone, header, rounding: 5)
  File.open(filename, 'w'){|fw|
    fw.puts ['country', 'city', 'total', *header].join("\t")
    counts_by_zone.sort.each{|zone, row|
      total = row.sum
      normed_row = row.map{|x| (x.to_f / total).round(rounding) }
      fw.puts [*zone, total, *normed_row].join("\t")
    }
  }
end

def save_counts_and_rates(basename, counts_by_zone, header, rates_rounding: 5)
  save_counts("counts/city/#{basename}", counts_by_zone, header)
  save_rates("rates/city/#{basename}", counts_by_zone, header, rounding: rates_rounding)
end

save_counts_and_rates('yday.tsv', yday_by_zone, yday_header)
save_counts_and_rates('wday.tsv', wday_by_zone, wday_header)
save_counts_and_rates('hour.tsv', hour_by_zone, hour_header)
save_counts_and_rates('weekhour.tsv', weekhour_by_zone, weekhour_header)
save_counts_and_rates('weekhour_10.tsv', weekhour_10_by_zone, weekhour_10_header)
save_counts_and_rates('daytime_10.tsv', daytime_10_by_zone, daytime_10_header)
save_counts_and_rates('doi_prefix.tsv', doi_prefix_by_zone, doi_prefixes)
save_counts('counts/city/mean_daytime.tsv', mean_daytime_by_zone, yday_header, skip_total: true)
